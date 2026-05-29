import 'dart:async';

import 'package:dio/dio.dart';

/// Retries **idempotent GETs** on transient failures with exponential backoff.
///
/// Deliberately narrow so it can never change server state:
///   * Only `GET` is retried — never POST/PATCH/PUT/DELETE, which may not be
///     idempotent (e.g. POST /trips creates a row).
///   * Only *transient* failures qualify: connect/send/receive timeouts,
///     low-level connection errors, and `5xx` responses. A `4xx` (including
///     `401`, which [AuthRefreshInterceptor] already handles, and `429`,
///     which the app surfaces with its `Retry-After`) is never retried —
///     retrying a client error just burns latency.
///
/// Backoff is `baseDelay * 2^attempt` (300ms → 600ms → 1200ms by default),
/// capped at [maxRetries] extra attempts. Attempt count rides on
/// `RequestOptions.extra` so a retried request can't recurse forever.
///
/// Ordering: add this AFTER `AuthRefreshInterceptor` so a `401` is resolved by
/// the auth refresh (which re-issues the original request) before this
/// interceptor ever sees it — and `401` isn't retryable here anyway. Retries
/// are re-issued through the same [dio], so the full chain (auth, logging)
/// still applies to each attempt.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 300),
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep ?? Future.delayed;

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Future<void> Function(Duration) _sleep;

  static const _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = baseDelay * (1 << attempt); // baseDelay * 2^attempt
    await _sleep(delay);

    options.extra[_attemptKey] = attempt + 1;
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode ?? 0;
        return code >= 500 && code < 600;
      default:
        return false;
    }
  }
}
