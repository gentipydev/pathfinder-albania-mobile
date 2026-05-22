import 'dart:async';

import 'package:dio/dio.dart';

/// Recovers from a single 401 by refreshing the Supabase access token via
/// [refreshAccessToken] and replaying the original request with the new
/// bearer. Concurrent failing requests share one in-flight refresh through a
/// [Completer] so the auth server is hit at most once per cluster.
///
/// Pass-through (no refresh attempt) cases:
///   - response status is not 401
///   - original request had no `Authorization: Bearer …` header
///   - request already carries the retry marker (prevents recursion)
///   - refresh resolves to null/empty (refresh token expired or revoked)
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required Future<String?> Function() refreshAccessToken,
    required Dio dio,
  })  : _refresh = refreshAccessToken,
        _dio = dio;

  final Future<String?> Function() _refresh;
  final Dio _dio;

  Completer<String?>? _inFlight;

  static const String retriedExtraKey = '_authRetried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final auth = req.headers['Authorization'];
    final hadBearer = auth is String && auth.startsWith('Bearer ');
    final alreadyRetried = req.extra[retriedExtraKey] == true;

    if (err.response?.statusCode != 401 || !hadBearer || alreadyRetried) {
      return handler.next(err);
    }

    final newToken = await _refreshShared();
    if (newToken == null || newToken.isEmpty) {
      return handler.next(err);
    }

    try {
      final retryResponse = await _dio.fetch<dynamic>(
        req.copyWith(
          headers: {...req.headers, 'Authorization': 'Bearer $newToken'},
          extra: {...req.extra, retriedExtraKey: true},
        ),
      );
      return handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  Future<String?> _refreshShared() {
    final existing = _inFlight;
    if (existing != null) return existing.future;
    final completer = Completer<String?>();
    _inFlight = completer;
    _refresh().then(
      completer.complete,
      onError: (_) => completer.complete(null),
    ).whenComplete(() {
      if (_inFlight == completer) _inFlight = null;
    });
    return completer.future;
  }
}
