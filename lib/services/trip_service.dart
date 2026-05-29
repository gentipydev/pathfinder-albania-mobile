import 'package:dio/dio.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/logic/common/dio_client.dart';
import 'package:travel_buddy/logic/common/service_exception.dart';

/// One page of GET /trips. `nextCursor` is null when no more pages remain.
/// The cursor is opaque (`"{updated_at_iso}|{uuid}"`) — clients must not parse it.
class TripsPage {
  const TripsPage({required this.items, required this.nextCursor});
  final List<Trip> items;
  final String? nextCursor;

  static const empty = TripsPage(items: <Trip>[], nextCursor: null);
}

class TripService {
  TripService({Dio? dio}) : _dio = dio ?? appDio;

  final Dio _dio;

  Map<String, dynamic> _headers(String? bearerToken) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (bearerToken != null && bearerToken.isNotEmpty)
      'Authorization': 'Bearer $bearerToken',
  };

  Options _opts(String? bearerToken, {Duration? receiveTimeout}) => Options(
        headers: _headers(bearerToken),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 60),
        validateStatus: (_) => true,
      );

  Future<Trip> createTrip(
    Map<String, dynamic> body, {
    required String? bearerToken,
  }) async {
    final res = await _dio.post<dynamic>(
      '/trips',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// GET /trips — keyset-paginated. Pass [cursor] (returned as `nextCursor`
  /// from the prior page) to fetch the next page; omit to fetch the first
  /// page. 401 is treated as "logged out" and returns [TripsPage.empty]
  /// (same idempotent behavior as the pre-pagination signature).
  Future<TripsPage> listTrips({
    required String? bearerToken,
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<dynamic>(
      '/trips',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
      options: _opts(bearerToken),
    );
    final code = res.statusCode ?? -1;
    if (code == 401) return TripsPage.empty;
    if (code < 200 || code >= 300) {
      throw TripServiceException(code, _bodyAsString(res));
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) return TripsPage.empty;
    final rawItems = decoded['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(Trip.fromJson)
            .toList(growable: false)
        : const <Trip>[];
    return TripsPage(
      items: items,
      nextCursor: decoded['next_cursor'] as String?,
    );
  }

  Future<Trip> getTrip(
    String tripId, {
    required String? bearerToken,
  }) async {
    final res = await _dio.get<dynamic>(
      '/trips/$tripId',
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  Future<void> deleteTrip(
    String tripId, {
    required String? bearerToken,
  }) async {
    final res = await _dio.delete<dynamic>(
      '/trips/$tripId',
      options: _opts(bearerToken),
    );
    final code = res.statusCode ?? -1;
    if (code < 200 || code >= 300) {
      throw TripServiceException(code, _bodyAsString(res));
    }
  }

  /// PATCH /trips/{tripId} — partial update of trip-level fields. To clear a
  /// nullable field (e.g., `start_date`), include the key with explicit
  /// `null`; omit the key entirely to leave it unchanged. The backend uses
  /// `model_dump(exclude_unset=True)` to honor that distinction.
  Future<Trip> patchTrip(
    String tripId,
    Map<String, dynamic> body, {
    required String? bearerToken,
  }) async {
    final res = await _dio.patch<dynamic>(
      '/trips/$tripId',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// POST /trips/{tripId}/days — add a new day. `body` must include
  /// `day_number` (≥1, unique within the trip — server returns 409 on dup).
  Future<Trip> addDay(
    String tripId,
    Map<String, dynamic> body, {
    required String? bearerToken,
  }) async {
    final res = await _dio.post<dynamic>(
      '/trips/$tripId/days',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// DELETE /trips/{tripId}/days/{dayId} — cascade-deletes its stops.
  Future<Trip> deleteDay(
    String tripId,
    String dayId, {
    required String? bearerToken,
  }) async {
    final res = await _dio.delete<dynamic>(
      '/trips/$tripId/days/$dayId',
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// POST /trips/{tripId}/days/{dayId}/stops — add a new stop. Omit
  /// `sort_order` in the body to append; provide it to insert at a position
  /// (existing stops at that position and beyond are shifted up).
  Future<Trip> addStop(
    String tripId,
    String dayId,
    Map<String, dynamic> body, {
    required String? bearerToken,
  }) async {
    final res = await _dio.post<dynamic>(
      '/trips/$tripId/days/$dayId/stops',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// PATCH /trips/{tripId}/stops/{stopId} — partial update. Same null-vs-omit
  /// semantics as patchTrip. Note: backend rejects explicit-null on `name`
  /// and `kind` (NOT NULL in DB) with a 422.
  Future<Trip> patchStop(
    String tripId,
    String stopId,
    Map<String, dynamic> body, {
    required String? bearerToken,
  }) async {
    final res = await _dio.patch<dynamic>(
      '/trips/$tripId/stops/$stopId',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// DELETE /trips/{tripId}/stops/{stopId} — does NOT compact remaining
  /// `sort_order` values; gaps stay in place.
  Future<Trip> deleteStop(
    String tripId,
    String stopId, {
    required String? bearerToken,
  }) async {
    final res = await _dio.delete<dynamic>(
      '/trips/$tripId/stops/$stopId',
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// PATCH /trips/{tripId}/days/{dayId}/reorder — supply the COMPLETE new
  /// ordering. Server validates the set matches the day's current stops
  /// (409 on mismatch) and that sort_order values are 0..N-1 contiguous.
  ///
  /// When [recomputeTimes] is true, server discards any per-item time
  /// fields in `order` and forward-walks realistic times using cached
  /// travel durations. Use this for user-initiated drag-drop reorders;
  /// leave it false for refine-tool callers that emit explicit times.
  Future<Trip> reorderStops(
    String tripId,
    String dayId,
    List<Map<String, dynamic>> order, {
    required String? bearerToken,
    bool recomputeTimes = false,
  }) async {
    final body = <String, dynamic>{'order': order};
    if (recomputeTimes) body['recompute_times'] = true;
    final res = await _dio.patch<dynamic>(
      '/trips/$tripId/days/$dayId/reorder',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// PATCH /trips/{tripId}/days/{dayId} — patch day metadata (title /
  /// base_city). Mirrors the backend's `TripDayUpdate` semantics: keys
  /// present with null clear the column, absent keys leave it untouched.
  /// `day_number` is intentionally not patchable.
  Future<Trip> updateDay(
    String tripId,
    String dayId,
    Map<String, dynamic> patch, {
    required String? bearerToken,
  }) async {
    final res = await _dio.patch<dynamic>(
      '/trips/$tripId/days/$dayId',
      data: patch,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  /// PATCH /trips/{tripId}/stops/{stopId}/move — move a stop to another day
  /// within the same trip. Server preserves `stop.id`, times, `completed_at`,
  /// and enrichment; source day's sort_orders are compacted automatically.
  /// `sortOrder` omitted appends to the target day. Rejects same-day moves
  /// with 400 (use [reorderStops] instead).
  ///
  /// When [recomputeTimes] is true, the destination day's times are
  /// forward-walked after the move (source day untouched). When
  /// [autoPosition] is true AND `sortOrder` is null, the server picks the
  /// destination index via nearest-insertion using cached travel durations
  /// instead of appending at the end; ignored if `sortOrder` is provided.
  Future<Trip> moveStop(
    String tripId,
    String stopId, {
    required String targetDayId,
    int? sortOrder,
    required String? bearerToken,
    bool recomputeTimes = false,
    bool autoPosition = false,
  }) async {
    final body = <String, dynamic>{'target_day_id': targetDayId};
    if (sortOrder != null) body['sort_order'] = sortOrder;
    if (recomputeTimes) body['recompute_times'] = true;
    if (autoPosition) body['auto_position'] = true;
    final res = await _dio.patch<dynamic>(
      '/trips/$tripId/stops/$stopId/move',
      data: body,
      options: _opts(bearerToken),
    );
    return _decodeTrip(res);
  }

  Trip _decodeTrip(Response<dynamic> res) {
    final code = res.statusCode ?? -1;
    if (code < 200 || code >= 300) {
      throw TripServiceException(code, _bodyAsString(res));
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) {
      throw TripServiceException(code, 'Unexpected response shape');
    }
    return Trip.fromJson(decoded);
  }

  String _bodyAsString(Response<dynamic> res) {
    final data = res.data;
    if (data is String) return data;
    return data?.toString() ?? '';
  }
}

class TripServiceException implements ServiceException {
  TripServiceException(this.statusCode, this.body);
  @override
  final int statusCode;
  final String body;

  @override
  String toString() => 'TripServiceException($statusCode): $body';
}
