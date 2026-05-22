import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/logic/common/auth_refresh_interceptor.dart';

void main() {
  group('AuthRefreshInterceptor', () {
    late _MockAdapter adapter;
    late Dio dio;

    Dio buildDio(Future<String?> Function() refresh) {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      adapter = _MockAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthRefreshInterceptor(dio: dio, refreshAccessToken: refresh),
      );
      return dio;
    }

    test('passes 401 through when request had no Bearer header', () async {
      var refreshCalls = 0;
      buildDio(() async {
        refreshCalls++;
        return 'never-issued';
      });
      adapter.respondWith = (_) => _resp(401, {'detail': 'expired'});

      await expectLater(
        dio.get<dynamic>('/anon'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      expect(refreshCalls, 0, reason: 'anonymous requests must not refresh');
      expect(adapter.calls, 1);
    });

    test('refreshes on 401, retries with new bearer, surfaces retry response',
        () async {
      var refreshCalls = 0;
      buildDio(() async {
        refreshCalls++;
        return 'fresh-token';
      });

      adapter.respondWith = (req) {
        final auth = req.headers['Authorization'];
        if (auth == 'Bearer stale-token') return _resp(401, {'detail': 'expired'});
        if (auth == 'Bearer fresh-token') return _resp(200, {'ok': true});
        return _resp(500, {'detail': 'unexpected auth: $auth'});
      };

      final res = await dio.get<dynamic>(
        '/me',
        options: Options(headers: {'Authorization': 'Bearer stale-token'}),
      );

      expect(res.statusCode, 200);
      expect(refreshCalls, 1);
      expect(adapter.calls, 2);
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer fresh-token',
        reason: 'retried request must carry the refreshed bearer',
      );
      expect(
        adapter.requests.last.extra[AuthRefreshInterceptor.retriedExtraKey],
        true,
        reason: 'retry must be marked to prevent re-recursion',
      );
    });

    test('propagates 401 when refresh resolves null', () async {
      var refreshCalls = 0;
      buildDio(() async {
        refreshCalls++;
        return null;
      });
      adapter.respondWith = (_) => _resp(401, {'detail': 'expired'});

      await expectLater(
        dio.get<dynamic>(
          '/me',
          options: Options(headers: {'Authorization': 'Bearer stale-token'}),
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      expect(refreshCalls, 1);
      expect(adapter.calls, 1, reason: 'no retry should fire after null refresh');
    });

    test('does not recurse: retried request 401 passes through', () async {
      var refreshCalls = 0;
      buildDio(() async {
        refreshCalls++;
        return 'fresh-token';
      });
      // Both attempts return 401 — confirms a single retry cap.
      adapter.respondWith = (_) => _resp(401, {'detail': 'expired'});

      await expectLater(
        dio.get<dynamic>(
          '/me',
          options: Options(headers: {'Authorization': 'Bearer stale-token'}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(refreshCalls, 1, reason: 'refresh should run exactly once');
      expect(adapter.calls, 2, reason: 'one original + one retry, no third');
    });

    test('propagates non-401 errors untouched', () async {
      var refreshCalls = 0;
      buildDio(() async {
        refreshCalls++;
        return 'fresh-token';
      });
      adapter.respondWith = (_) => _resp(500, {'detail': 'boom'});

      await expectLater(
        dio.get<dynamic>(
          '/me',
          options: Options(headers: {'Authorization': 'Bearer stale-token'}),
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
      expect(refreshCalls, 0);
      expect(adapter.calls, 1);
    });

    test('concurrent 401s share a single in-flight refresh', () async {
      var refreshCalls = 0;
      final gate = Completer<void>();
      buildDio(() async {
        refreshCalls++;
        await gate.future; // hold the refresh so both requests arrive at await
        return 'fresh-token';
      });

      adapter.respondWith = (req) {
        final auth = req.headers['Authorization'];
        if (auth == 'Bearer stale-token') return _resp(401, {'detail': 'expired'});
        return _resp(200, {'ok': true});
      };

      final f1 = dio.get<dynamic>(
        '/a',
        options: Options(headers: {'Authorization': 'Bearer stale-token'}),
      );
      final f2 = dio.get<dynamic>(
        '/b',
        options: Options(headers: {'Authorization': 'Bearer stale-token'}),
      );

      // Let both initial requests resolve to 401 and enter _refreshShared.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      gate.complete();

      final results = await Future.wait([f1, f2]);
      expect(results.every((r) => r.statusCode == 200), isTrue);
      expect(refreshCalls, 1, reason: 'second 401 must coalesce onto in-flight refresh');
      expect(adapter.calls, 4, reason: '2 initial 401s + 2 retried 200s');
    });
  });
}

ResponseBody _resp(int code, Map<String, dynamic> body) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    code,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _MockAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options) respondWith = (_) =>
      _resp(200, {});
  final List<RequestOptions> requests = [];
  int get calls => requests.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    requests.add(options);
    return respondWith(options);
  }

  @override
  void close({bool force = false}) {}
}
