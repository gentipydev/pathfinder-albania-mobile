import 'package:dio/dio.dart';
import 'package:travel_buddy/logic/buddy/chat_message.dart';
import 'package:travel_buddy/logic/common/dio_client.dart';
import 'package:travel_buddy/logic/common/service_exception.dart';

/// Lightweight summary returned by GET /conversations.
class ConversationSummary {
  ConversationSummary({
    required this.id,
    required this.title,
    required this.tripId,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  final String id;
  final String? title;
  final String? tripId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int messageCount;

  factory ConversationSummary.fromJson(Map<String, dynamic> j) {
    DateTime? parse(String? s) =>
        (s == null || s.isEmpty) ? null : DateTime.tryParse(s);
    return ConversationSummary(
      id: j['id'] as String,
      title: j['title'] as String?,
      tripId: j['trip_id'] as String?,
      createdAt: parse(j['created_at'] as String?),
      updatedAt: parse(j['updated_at'] as String?),
      messageCount: (j['message_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// One page of GET /conversations. `nextCursor` is null when no more pages
/// remain. The cursor is opaque (`"{updated_at_iso}|{uuid}"`) — don't parse it.
class ConversationsPage {
  const ConversationsPage({required this.items, required this.nextCursor});
  final List<ConversationSummary> items;
  final String? nextCursor;

  static const empty = ConversationsPage(items: <ConversationSummary>[], nextCursor: null);
}

/// Result of POST /trips/{tripId}/conversation — the trip's 1:1 refine
/// conversation, created if not present.
class TripConversationRef {
  TripConversationRef({required this.id, this.tripId, this.title});
  final String id;
  final String? tripId;
  final String? title;

  factory TripConversationRef.fromJson(Map<String, dynamic> j) =>
      TripConversationRef(
        id: j['id'] as String,
        tripId: j['trip_id'] as String?,
        title: j['title'] as String?,
      );
}

class ConversationsService {
  Map<String, dynamic> _headers(String? bearerToken) {
    final h = <String, dynamic>{'Accept': 'application/json'};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearerToken';
    }
    return h;
  }

  /// GET /conversations — keyset-paginated. Pass [cursor] (returned as
  /// `nextCursor` from the prior page) to fetch the next page; omit to fetch
  /// the first page.
  Future<ConversationsPage> list({
    String? bearerToken,
    String? cursor,
    int limit = 20,
  }) async {
    final res = await appDio.get<dynamic>(
      '/conversations',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
      options: Options(
        headers: _headers(bearerToken),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) return ConversationsPage.empty;
    final rawItems = decoded['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(ConversationSummary.fromJson)
            .toList()
        : const <ConversationSummary>[];
    return ConversationsPage(
      items: items,
      nextCursor: decoded['next_cursor'] as String?,
    );
  }

  /// Returns the conversation's hydrated messages in display order. Server
  /// stores no rich content (place_cards, image attachments) — those fields
  /// come back null on rehydration, which is the contract.
  Future<List<ChatMessage>> get(String id, {String? bearerToken}) async {
    final res = await appDio.get<dynamic>(
      '/conversations/$id',
      options: Options(
        headers: _headers(bearerToken),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) return const [];
    final raw = decoded['messages'];
    if (raw is! List) return const [];
    final out = <ChatMessage>[];
    for (final m in raw) {
      if (m is! Map) continue;
      final role = (m['role'] as String?) == 'user'
          ? ChatRole.user
          : ChatRole.assistant;
      final ts = m['timestamp'] as String?;
      out.add(ChatMessage(
        id: '${id}_${out.length}',
        role: role,
        content: (m['content'] as String?) ?? '',
        createdAt:
            ts == null ? DateTime.now() : DateTime.tryParse(ts) ?? DateTime.now(),
      ));
    }
    return out;
  }

  /// POST /trips/{tripId}/conversation — idempotent. Returns the existing
  /// or newly-created chat thread bound 1:1 to this saved trip. The buddy
  /// chat hydrates history off this id immediately so the user sees prior
  /// refine turns when they return to the same trip.
  Future<TripConversationRef> getOrCreateForTrip(
    String tripId, {
    String? bearerToken,
  }) async {
    final headers = _headers(bearerToken)..['Content-Type'] = 'application/json';
    final res = await appDio.post<dynamic>(
      '/trips/$tripId/conversation',
      options: Options(
        headers: headers,
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) {
      throw HttpException('Unexpected response shape', code);
    }
    return TripConversationRef.fromJson(decoded);
  }

  Future<void> delete(String id, {String? bearerToken}) async {
    final res = await appDio.delete<dynamic>(
      '/conversations/$id',
      options: Options(
        headers: _headers(bearerToken),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200 && code != 204) {
      throw HttpException('HTTP $code', code);
    }
  }

  /// Deletes every conversation belonging to the caller. Fans out single
  /// deletes over the existing endpoint (no batch endpoint exists yet).
  /// Returns the count of conversations removed.
  ///
  /// Pages through `GET /conversations` until exhausted — otherwise users
  /// with >`limit` conversations would have a "Clear all" that silently
  /// leaves a tail behind.
  Future<int> clearAll({String? bearerToken}) async {
    var removed = 0;
    String? cursor;
    while (true) {
      final page = await list(bearerToken: bearerToken, cursor: cursor);
      for (final s in page.items) {
        await delete(s.id, bearerToken: bearerToken);
        removed += 1;
      }
      if (page.nextCursor == null) break;
      cursor = page.nextCursor;
    }
    return removed;
  }
}

class HttpException implements ServiceException {
  HttpException(this.message, this.statusCode);
  final String message;
  @override
  final int statusCode;
  @override
  String toString() => message;
}
