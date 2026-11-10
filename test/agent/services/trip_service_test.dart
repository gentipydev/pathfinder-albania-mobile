import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/logic/common/service_exception.dart';
import 'package:travel_buddy/agent/services/trip_service.dart';

/// Returns a canned JSON body + status for every request and records the
/// [RequestOptions] it saw, so tests can assert on query params / headers /
/// method without a real network. `validateStatus: (_) => true` in the
/// service means non-2xx still arrives as a Response, not a DioException —
/// the service's own status checks do the mapping under test here.
class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this.body, this.statusCode);

  final String body;
  final int statusCode;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    // Only advertise JSON when the body is JSON; otherwise Dio's transformer
    // would FormatException on a plain-text error body before the service's
    // own status-code check (the thing under test) ever runs.
    final isJson = body.startsWith('{') || body.startsWith('[');
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        if (isJson) Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_CannedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('listTrips', () {
    test('parses items + next_cursor and sends limit/cursor + auth header',
        () async {
      final adapter = _CannedAdapter(
        '{"items":[{"id":"t1","title":"A"},{"id":"t2","title":"B"}],'
        '"next_cursor":"2026-05-01T00:00:00Z|uuid-2"}',
        200,
      );
      final page = await TripService(dio: _dioWith(adapter)).listTrips(
        bearerToken: 'tok',
        cursor: '2026-05-02T00:00:00Z|uuid-1',
        limit: 10,
      );

      expect(page.items.map((t) => t.id), ['t1', 't2']);
      expect(page.nextCursor, '2026-05-01T00:00:00Z|uuid-2');

      // Cursor (with its `|`) and limit ride as query params, verbatim.
      expect(adapter.captured!.method, 'GET');
      expect(adapter.captured!.path, '/trips');
      expect(adapter.captured!.queryParameters['limit'], 10);
      expect(adapter.captured!.queryParameters['cursor'],
          '2026-05-02T00:00:00Z|uuid-1');
      expect(adapter.captured!.headers['Authorization'], 'Bearer tok');
    });

    test('omits cursor on the first page', () async {
      final adapter = _CannedAdapter('{"items":[],"next_cursor":null}', 200);
      await TripService(dio: _dioWith(adapter))
          .listTrips(bearerToken: 'tok');
      expect(adapter.captured!.queryParameters.containsKey('cursor'), isFalse);
    });

    test('401 returns an empty page rather than throwing', () async {
      final adapter = _CannedAdapter('', 401);
      final page =
          await TripService(dio: _dioWith(adapter)).listTrips(bearerToken: null);
      expect(page.items, isEmpty);
      expect(page.nextCursor, isNull);
    });

    test('5xx throws a TripServiceException carrying the code', () async {
      final adapter = _CannedAdapter('boom', 503);
      await expectLater(
        () => TripService(dio: _dioWith(adapter)).listTrips(bearerToken: 'tok'),
        throwsA(
          isA<TripServiceException>()
              .having((e) => e.statusCode, 'statusCode', 503),
        ),
      );
    });
  });

  group('createTrip', () {
    test('409 surfaces as a ServiceException with the conflict code',
        () async {
      final adapter = _CannedAdapter('{"detail":"trip_limit_reached"}', 409);
      await expectLater(
        () => TripService(dio: _dioWith(adapter))
            .createTrip({'title': 'x'}, bearerToken: 'tok'),
        // Also asserts the shared base type — createTrip's error is catchable
        // as a ServiceException, not just the concrete subclass.
        throwsA(
          isA<ServiceException>()
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('200 decodes the returned trip', () async {
      final adapter = _CannedAdapter('{"id":"t9","title":"New"}', 201);
      final trip = await TripService(dio: _dioWith(adapter))
          .createTrip({'title': 'New'}, bearerToken: 'tok');
      expect(trip.id, 't9');
      expect(adapter.captured!.method, 'POST');
    });
  });

  group('getTrip / deleteTrip', () {
    test('getTrip 404 throws TripServiceException(404)', () async {
      final adapter = _CannedAdapter('not found', 404);
      await expectLater(
        () => TripService(dio: _dioWith(adapter))
            .getTrip('missing', bearerToken: 'tok'),
        throwsA(
          isA<TripServiceException>()
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('deleteTrip 204 completes; 500 throws', () async {
      await TripService(dio: _dioWith(_CannedAdapter('', 204)))
          .deleteTrip('t1', bearerToken: 'tok');

      await expectLater(
        () => TripService(dio: _dioWith(_CannedAdapter('', 500)))
            .deleteTrip('t1', bearerToken: 'tok'),
        throwsA(isA<TripServiceException>()),
      );
    });
  });
}
