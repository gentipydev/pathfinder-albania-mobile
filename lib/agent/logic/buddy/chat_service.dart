import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_route.dart';
import 'package:pathfinder_albania/agent/logic/buddy/chat_stream_event.dart';
import 'package:pathfinder_albania/agent/logic/buddy/live_stop.dart';
import 'package:pathfinder_albania/logic/common/dio_client.dart';
import 'package:pathfinder_albania/utils/dlog.dart';

const String _channel = 'chat.stream';

class ChatService {
  Stream<ChatStreamEvent> stream({
    required String message,
    String? conversationId,
    String? bearerToken,
    List<String>? imageUrls,
    String? tripId,
  }) async* {
    // Server now owns conversation history. We only send the current message
    // plus, when resuming, the conversation_id; the backend hydrates history
    // from the conversations table for authenticated requests.
    final body = <String, dynamic>{
      'message': message,
    };
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversation_id'] = conversationId;
    }
    if (imageUrls != null && imageUrls.isNotEmpty) {
      body['images'] = imageUrls;
    }
    if (tripId != null && tripId.isNotEmpty) {
      // Refine-with-Buddy: backend loads the trip (auth-checked), injects its
      // serialized state into the system prompt, and on a successful
      // emit_itinerary tool call replaces the trip in place and streams back
      // `event: trip_refined` instead of `event: itinerary`.
      body['trip_id'] = tripId;
    }

    final start = DateTime.now();
    dlog(
      'POST /chat/stream start (token=${bearerToken != null && bearerToken.isNotEmpty}, '
      'conv=${conversationId ?? '-'}, scoped=${tripId != null && tripId.isNotEmpty}, '
      'imgs=${imageUrls?.length ?? 0}, msgChars=${message.length})',
      name: _channel,
      level: LogLevel.info,
    );

    Response<ResponseBody> resp;
    try {
      // 90s covers a scale-from-zero cold-start on the first request after
      // the backend instance has been idle.
      resp = await appDio.post<ResponseBody>(
        '/chat/stream',
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
            if (bearerToken != null && bearerToken.isNotEmpty)
              'Authorization': 'Bearer $bearerToken',
          },
          receiveTimeout: const Duration(seconds: 90),
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (err) {
      final ms = DateTime.now().difference(start).inMilliseconds;
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        dlog('timeout after ${ms}ms', name: _channel, level: LogLevel.error);
        yield const StreamError('Request timed out');
        return;
      }
      dlog('network error after ${ms}ms', name: _channel, level: LogLevel.error, error: err);
      yield StreamError('Network error: $err');
      return;
    } catch (err) {
      final ms = DateTime.now().difference(start).inMilliseconds;
      dlog('network error after ${ms}ms', name: _channel, level: LogLevel.error, error: err);
      yield StreamError('Network error: $err');
      return;
    }

    final ms = DateTime.now().difference(start).inMilliseconds;
    final code = resp.statusCode ?? -1;
    if (code == 429) {
      // Rate-limited: server emits Retry-After (seconds). Body is JSON
      // with `retry_after_seconds` as well — the header wins because
      // it's the HTTP-spec channel. Falls back to 60s on either side.
      final retryHeader = resp.headers.value('retry-after');
      final retrySecs = int.tryParse(retryHeader ?? '') ?? 60;
      dlog('connect → 429 retry_after=${retrySecs}s (${ms}ms)',
          name: _channel, level: LogLevel.warning);
      yield RateLimitedEvent(retryAfter: Duration(seconds: retrySecs));
      return;
    }
    if (code != 200) {
      dlog('connect → HTTP $code (${ms}ms)',
          name: _channel, level: LogLevel.warning);
      yield StreamError('HTTP $code', statusCode: code);
      return;
    }
    dlog('connect → 200 (${ms}ms), parsing SSE', name: _channel, level: LogLevel.info);

    final responseBody = resp.data;
    if (responseBody == null) {
      yield const StreamError('Empty response stream');
      return;
    }

    // SSE-spec parser: an event consists of one `event:` line (optional) plus
    // one or more `data:` lines, terminated by a blank line. Multi-line values
    // are split across consecutive `data:` lines and the receiver MUST rejoin
    // them with `\n`. The backend in main.py:253 produces this format whenever
    // a chunk contains a newline; the prior parser yielded each line as its
    // own TextDelta and dropped the separators, flattening markdown to a
    // single line on the client.
    String? eventType;
    final dataLines = <String>[];
    final lines = responseBody.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    try {
      await for (final line in lines) {
        if (line.isEmpty) {
          if (dataLines.isEmpty && eventType == null) continue;
          final data = dataLines.join('\n');
          final type = eventType;
          dataLines.clear();
          eventType = null;

          dlog('event=${type ?? 'message'} bytes=${data.length}', name: _channel);
          if (data == '[DONE]') {
            dlog('stream done after ${DateTime.now().difference(start).inMilliseconds}ms',
                name: _channel, level: LogLevel.info);
            yield const StreamDone();
            return;
          }
          if (type == 'error') {
            dlog('stream error event: $data', name: _channel, level: LogLevel.error);
            yield StreamError(data);
            return;
          }
          if (type == 'conversation_id') {
            // Server emits this once per request when it auto-creates a new
            // conversation. The id is the literal UUID string in `data`.
            if (data.isNotEmpty) yield ConversationIdEvent(data);
            continue;
          }
          if (type == 'persist_failed') {
            // Reply streamed fine but the server couldn't durably store it.
            // BuddyLogic marks the bubble notSaved; we don't fail the stream.
            yield const PersistFailed();
            continue;
          }
          if (type == 'place_card') {
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                yield PlaceCardEvent(parsed);
              }
            } catch (_) {
              // malformed payload — skip silently, don't break the stream
            }
            continue;
          }
          if (type == 'itinerary') {
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                yield ItineraryStreamEvent(
                  ItineraryDraft.fromToolJson(parsed),
                );
              }
            } catch (_) {
              // malformed payload — skip silently, don't break the stream
            }
            continue;
          }
          if (type == 'itinerary_invalid') {
            // Server tried to emit an itinerary but its TripCreate validation
            // rejected it. The natural-language reply is already on screen;
            // the bubble will render a soft footer instead of a Save CTA.
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                final reason = (parsed['reason'] as String?) ?? '';
                yield ItineraryInvalidStreamEvent(reason);
              }
            } catch (_) {
              // malformed payload — skip silently, don't break the stream
            }
            continue;
          }
          if (type == 'itinerary_stream_start') {
            // No payload — the frame itself is the signal.
            yield const ItineraryStreamStartEvent();
            continue;
          }
          if (type == 'itinerary_stop') {
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                final stop = LiveStop.tryParse(parsed);
                // Unmappable stop (no id/name/coords) — skip the marker, keep
                // the stream. The plan still arrives whole via `itinerary`.
                if (stop != null) yield ItineraryStopEvent(stop);
              }
            } catch (_) {
              // malformed payload — skip silently, don't break the stream
            }
            continue;
          }
          if (type == 'itinerary_routes') {
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                final raw = parsed['routes'];
                if (raw is List) {
                  final routes = raw
                      .whereType<Map<String, dynamic>>()
                      .map(TripRoute.fromJson)
                      .toList(growable: false);
                  if (routes.isNotEmpty) yield ItineraryRoutesEvent(routes);
                }
              }
            } catch (_) {
              // malformed payload — the straight connectors simply remain
            }
            continue;
          }
          if (type == 'itinerary_preview') {
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                yield ItineraryPreviewEvent(Trip.fromJson(parsed));
              }
            } catch (_) {
              // malformed payload — map stays empty; text + Save are intact
            }
            continue;
          }
          if (type == 'trip_refined') {
            // Refine-with-Buddy: server applied the validated itinerary to
            // the saved trip and is shipping the canonical post-replace Trip.
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                yield TripRefinedStreamEvent(Trip.fromJson(parsed));
              }
            } catch (_) {
              // malformed payload — skip silently, don't break the stream
            }
            continue;
          }
          if (type == 'refine_failed') {
            // Claude emitted a valid itinerary but the server-side replace
            // failed. Soft inline indicator; trip on disk unchanged.
            try {
              final parsed = jsonDecode(data);
              if (parsed is Map<String, dynamic>) {
                final reason = (parsed['reason'] as String?) ?? '';
                yield RefineFailedStreamEvent(reason);
              }
            } catch (_) {
              // malformed payload — skip silently, don't break the stream
            }
            continue;
          }
          if (data.isNotEmpty) yield TextDelta(data);
          continue;
        }
        if (line.startsWith(':')) {
          // SSE comment / keepalive — ignore.
          continue;
        }
        if (line.startsWith('event:')) {
          eventType = line.substring(line.length > 6 && line[6] == ' ' ? 7 : 6).trim();
          continue;
        }
        if (line.startsWith('data:')) {
          // Spec: a single optional space after the colon is stripped.
          dataLines.add(line.length > 5 && line[5] == ' '
              ? line.substring(6)
              : line.substring(5));
          continue;
        }
        // Other SSE fields (id:, retry:) are ignored.
      }
      // EOF without trailing blank: flush any buffered data.
      if (dataLines.isNotEmpty) {
        final data = dataLines.join('\n');
        if (data == '[DONE]') {
          dlog('stream done (EOF) after ${DateTime.now().difference(start).inMilliseconds}ms',
              name: _channel, level: LogLevel.info);
          yield const StreamDone();
          return;
        }
        if (data.isNotEmpty) yield TextDelta(data);
      }
    } catch (err) {
      dlog('stream interrupted after ${DateTime.now().difference(start).inMilliseconds}ms',
          name: _channel, level: LogLevel.error, error: err);
      yield StreamError('Stream interrupted: $err');
      return;
    }

    dlog('stream end (no DONE marker) after ${DateTime.now().difference(start).inMilliseconds}ms',
        name: _channel, level: LogLevel.info);
    yield const StreamDone();
  }
}
