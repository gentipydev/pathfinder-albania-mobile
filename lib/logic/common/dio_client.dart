import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_buddy/config/env.dart';
import 'package:travel_buddy/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/logic/common/auth_refresh_interceptor.dart';
import 'package:travel_buddy/logic/common/dio_logger_interceptor.dart';
import 'package:travel_buddy/logic/common/retry_interceptor.dart';

final Dio appDio = _buildAppDio();

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
      refreshAccessToken: () => GetIt.I<AuthBloc>().refreshAccessToken(),
    ),
  );
  // Last: transient-failure retry for idempotent GETs. After auth so a 401 is
  // resolved by the refresh path (and 401 isn't retryable here regardless).
  dio.interceptors.add(RetryInterceptor(dio: dio));
  return dio;
}
