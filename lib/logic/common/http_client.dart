import 'package:dio/dio.dart';
import 'package:travel_buddy/logic/common/dio_client.dart';

enum NetErrorType {
  none,
  disconnected,
  timedOut,
  denied,
}

class HttpClient {
  static Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    try {
      final res = await appDio.getUri<String>(
        Uri.parse(url),
        options: Options(
          headers: headers,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      return HttpResponse.fromDio(res);
    } on DioException catch (e) {
      final type = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          NetErrorType.timedOut,
        _ => NetErrorType.disconnected,
      };
      return HttpResponse.error(type);
    }
  }
}

class HttpResponse {
  HttpResponse({
    required this.statusCode,
    this.body,
    this.headers,
    NetErrorType? errorType,
  }) : errorType = errorType ?? _classify(statusCode);

  factory HttpResponse.fromDio(Response<dynamic> r) {
    final data = r.data;
    final body = data is String ? data : data?.toString();
    final headers = <String, String>{};
    r.headers.forEach((k, v) => headers[k] = v.join(', '));
    return HttpResponse(
      statusCode: r.statusCode ?? -1,
      body: body,
      headers: headers,
    );
  }

  factory HttpResponse.error(NetErrorType type) =>
      HttpResponse(statusCode: -1, errorType: type);

  final int statusCode;
  final String? body;
  final Map<String, String>? headers;
  final NetErrorType errorType;

  bool get success => errorType == NetErrorType.none;

  static NetErrorType _classify(int code) {
    if (code >= 200 && code <= 299) return NetErrorType.none;
    if (code >= 400 && code < 500) return NetErrorType.denied;
    if (code >= 500 && code < 600) return NetErrorType.timedOut;
    return NetErrorType.disconnected;
  }
}
