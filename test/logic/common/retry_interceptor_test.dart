import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/logic/common/retry_interceptor.dart';

/// HttpClientAdapter stub that replays a queued list of responses (or throws)
/// and counts how many times it was hit, so we can assert retry behavior
/// without real network or real backoff delays.
class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this._steps);

  /// Each step either returns a [ResponseBody] or throws (e.g. a timeout).
  final List<ResponseBody Function()> _steps;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final step = _steps[calls < _steps.length ? calls : _steps.length - 1];
    calls++;
    return step();
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_QueueAdapter adapter, {int maxRetries = 3}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxRetries: maxRetries,
      // No-op sleep so backoff doesn't slow the test.
      sleep: (_) async {},
    ),
  );
  return dio;
}

ResponseBody _ok() => ResponseBody.fromString('ok', 200);
ResponseBody _status(int code) => ResponseBody.fromString('', code);

void main() {
  group('RetryInterceptor', () {
    test('retries a GET on 5xx then succeeds', () async {
      final adapter = _QueueAdapter([
        () => _status(503),
        () => _status(503),
        _ok,
      ]);
      final dio = _dioWith(adapter);

      final res = await dio.get<String>(
        '/trips',
        options: Options(responseType: ResponseType.plain),
      );

      expect(res.statusCode, 200);
      expect(adapter.calls, 3); // 1 initial + 2 retries
    });

    test('retries a GET on a connection timeout', () async {
      final adapter = _QueueAdapter([
        () => throw DioException(
              requestOptions: RequestOptions(path: '/trips'),
              type: DioExceptionType.receiveTimeout,
            ),
        _ok,
      ]);
      final dio = _dioWith(adapter);

      final res = await dio.get<String>(
        '/trips',
        options: Options(responseType: ResponseType.plain),
      );

      expect(res.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('does NOT retry a GET on 4xx', () async {
      final adapter = _QueueAdapter([() => _status(404)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.get<String>('/trips',
            options: Options(responseType: ResponseType.plain)),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1); // never retried
    });

    test('does NOT retry a non-GET (POST) on 5xx', () async {
      final adapter = _QueueAdapter([() => _status(503)]);
      final dio = _dioWith(adapter);

      await expectLater(
        dio.post<String>('/trips',
            options: Options(responseType: ResponseType.plain)),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1); // POST is not idempotent — never retried
    });

    test('gives up after maxRetries and surfaces the error', () async {
      final adapter = _QueueAdapter([() => _status(503)]); // always 503
      final dio = _dioWith(adapter, maxRetries: 3);

      await expectLater(
        dio.get<String>('/trips',
            options: Options(responseType: ResponseType.plain)),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 4); // 1 initial + 3 retries
    });
  });
}
