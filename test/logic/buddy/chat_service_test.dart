import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/logic/buddy/chat_service.dart';
import 'package:travel_buddy/logic/buddy/chat_stream_event.dart';
import 'package:travel_buddy/logic/common/dio_client.dart';

/// Replays a canned SSE response through the real `ChatService` parser by
/// standing in for the network adapter on the shared `appDio`. [chunks] lets a
/// test split the payload at arbitrary byte boundaries to prove the parser
/// reassembles lines across chunks (utf8 + LineSplitter buffering).
class _FakeSseAdapter implements HttpClientAdapter {
  _FakeSseAdapter(
    this.chunks, {
    this.statusCode = 200,
    this.headers = const {},
  });

  final List<String> chunks;
  final int statusCode;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final stream = Stream<Uint8List>.fromIterable(
      chunks.map((c) => Uint8List.fromList(utf8.encode(c))),
    );
    return ResponseBody(stream, statusCode, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `appDio` is built lazily and reads `Env.apiBaseUrl` from dotenv; seed a
  // value so first access doesn't throw NotInitializedError.
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=https://test.example.com',
      isOptional: true,
    );
  });

  late HttpClientAdapter original;
  setUp(() => original = appDio.httpClientAdapter);
  tearDown(() => appDio.httpClientAdapter = original);

  Future<List<ChatStreamEvent>> run(
    List<String> chunks, {
    int statusCode = 200,
    Map<String, List<String>> headers = const {},
  }) {
    appDio.httpClientAdapter =
        _FakeSseAdapter(chunks, statusCode: statusCode, headers: headers);
    return ChatService().stream(message: 'hi').toList();
  }

  test('plain text frame then [DONE]', () async {
    final events = await run(['data: Hello\n\ndata: [DONE]\n\n']);
    expect(events, hasLength(2));
    expect((events[0] as TextDelta).text, 'Hello');
    expect(events[1], isA<StreamDone>());
  });

  test('multi-line data is rejoined with newlines', () async {
    final events = await run(['data: line1\ndata: line2\n\ndata: [DONE]\n\n']);
    expect((events.first as TextDelta).text, 'line1\nline2');
  });

  test('conversation_id event', () async {
    final events = await run(
      ['event: conversation_id\ndata: conv-123\n\ndata: [DONE]\n\n'],
    );
    expect((events.first as ConversationIdEvent).id, 'conv-123');
  });

  test('place_card event parses JSON payload', () async {
    final events = await run(
      ['event: place_card\ndata: {"id":"p1","name":"Berat"}\n\ndata: [DONE]\n\n'],
    );
    final pc = events.first as PlaceCardEvent;
    expect(pc.data['name'], 'Berat');
  });

  test('itinerary event yields an ItineraryStreamEvent', () async {
    final events = await run(
      ['event: itinerary\ndata: {"title":"Trip","days":[]}\n\ndata: [DONE]\n\n'],
    );
    expect(events.first, isA<ItineraryStreamEvent>());
  });

  test('itinerary_invalid carries its reason', () async {
    final events = await run(
      ['event: itinerary_invalid\ndata: {"reason":"days: required"}\n\ndata: [DONE]\n\n'],
    );
    expect((events.first as ItineraryInvalidStreamEvent).reason, 'days: required');
  });

  test('error event ends the stream with no [DONE]', () async {
    final events = await run(['event: error\ndata: boom\n\n']);
    expect(events, hasLength(1));
    expect((events.first as StreamError).message, 'boom');
  });

  test('persist_failed does not end the stream', () async {
    final events = await run(
      ['data: hi\n\nevent: persist_failed\ndata: x\n\ndata: [DONE]\n\n'],
    );
    expect(events[0], isA<TextDelta>());
    expect(events[1], isA<PersistFailed>());
    expect(events[2], isA<StreamDone>());
  });

  test('events are emitted in arrival order (out-of-order interleave)',
      () async {
    final events = await run([
      'data: a\n\n'
          'event: conversation_id\ndata: c1\n\n'
          'data: b\n\n'
          'data: [DONE]\n\n',
    ]);
    expect((events[0] as TextDelta).text, 'a');
    expect((events[1] as ConversationIdEvent).id, 'c1');
    expect((events[2] as TextDelta).text, 'b');
    expect(events[3], isA<StreamDone>());
  });

  test('HTTP 429 yields RateLimitedEvent with Retry-After from header',
      () async {
    final events = await run(
      [''],
      statusCode: 429,
      headers: {
        'retry-after': ['30'],
      },
    );
    expect(events, hasLength(1));
    expect((events.first as RateLimitedEvent).retryAfter,
        const Duration(seconds: 30));
  });

  test('non-200 status yields a StreamError carrying the code', () async {
    final events = await run([''], statusCode: 500);
    final err = events.single as StreamError;
    expect(err.statusCode, 500);
  });

  test('EOF without a [DONE] flushes buffered text then completes', () async {
    // No trailing blank line and no [DONE] sentinel.
    final events = await run(['data: tail']);
    expect((events[0] as TextDelta).text, 'tail');
    expect(events.last, isA<StreamDone>());
  });

  test('comment / keepalive lines are ignored', () async {
    final events = await run([': keepalive\n\ndata: hi\n\ndata: [DONE]\n\n']);
    expect((events.first as TextDelta).text, 'hi');
  });

  test('reassembles a frame split across chunk boundaries mid-line', () async {
    final events = await run(['data: Hel', 'lo\n\ndata: [DONE]\n\n']);
    expect((events.first as TextDelta).text, 'Hello');
  });
}
