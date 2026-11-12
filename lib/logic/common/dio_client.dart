import 'package:dio/dio.dart';
import 'package:pathfinder_albania/config/env.dart';
import 'package:pathfinder_albania/logic/common/auth_refresh_interceptor.dart';
import 'package:pathfinder_albania/logic/common/dio_logger_interceptor.dart';
import 'package:pathfinder_albania/logic/common/retry_interceptor.dart';

final Dio appDio = _buildAppDio();

/// Returns a fresh access token after a 401. Set by `AgentModule` when the
/// agent side is on; stays null in showcase mode, where no request carries
/// a bearer token and there is nothing to refresh.
Future<String?> Function()? accessTokenRefresher;

Dio _buildAppDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
    ),
  );
  // Logger first so it sees the original 401 in onError before
  // AuthRefreshInterceptor swallows it via handler.resolve on a successful retry.
  dio.interceptors.add(DioLoggerInterceptor());
  dio.interceptors.add(
    AuthRefreshInterceptor(
      dio: dio,
      refreshAccessToken: () async => accessTokenRefresher?.call(),
    ),
  );
  // Last: transient-failure retry for idempotent GETs. After auth so a 401 is
  // resolved by the refresh path (and 401 isn't retryable here regardless).
  dio.interceptors.add(RetryInterceptor(dio: dio));
  return dio;
}
