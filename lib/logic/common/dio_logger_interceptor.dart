import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:travel_buddy/utils/dlog.dart';

const String _channel = 'http';
const String _startTimeKey = '_dlogStart';

const int _bodyMaxChars = 4 * 1024;

const Set<String> _sensitiveHeaderKeys = {'authorization', 'cookie'};
const Set<String> _sensitiveBodyKeyParts = {
  'password',
  'secret',
  'token',
  'bearer',
  'apikey',
  'api_key',
};

class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now();
    final lines = <String>['${options.method} ${options.uri}'];
    if (options.headers.isNotEmpty) {
      lines.add('  headers: ${_redactHeaders(options.headers)}');
    }
    final body = _formatRequestBody(options);
    if (body != null) lines.add(_indentBodyBlock(body));
    dlog(lines.join('\n'), name: _channel);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final ms = _elapsedMs(response.requestOptions);
    final code = response.statusCode ?? -1;
    final lvl = code >= 500
        ? LogLevel.error
        : code >= 400
            ? LogLevel.warning
            : LogLevel.info;
    final size = _bodySize(response);
    final sizePart = size >= 0 ? ', ${size}B' : '';
    final lines = <String>[
      '${response.requestOptions.method} ${response.requestOptions.uri} → $code (${ms}ms$sizePart)',
    ];
    final headers = _redactDioHeaders(response.headers);
    if (headers.isNotEmpty) lines.add('  headers: $headers');
    final body = _formatResponseBody(response);
    if (body != null) lines.add(_indentBodyBlock(body));
    dlog(lines.join('\n'), name: _channel, level: lvl);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ms = _elapsedMs(err.requestOptions);
    final code = err.response?.statusCode;
    final codePart = code != null ? ' → $code' : '';
    final lines = <String>[
      '${err.requestOptions.method} ${err.requestOptions.uri}$codePart FAILED after ${ms}ms (${err.type.name})',
    ];
    final resp = err.response;
    if (resp != null) {
      final headers = _redactDioHeaders(resp.headers);
      if (headers.isNotEmpty) lines.add('  headers: $headers');
      final body = _formatResponseBody(resp);
      if (body != null) lines.add(_indentBodyBlock(body));
    }
    dlog(
      lines.join('\n'),
      name: _channel,
      level: LogLevel.error,
      error: err,
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[_startTimeKey];
    if (start is! DateTime) return -1;
    return DateTime.now().difference(start).inMilliseconds;
  }

  int _bodySize(Response response) {
    final data = response.data;
    if (data is List<int>) return data.length;
    if (data is String) return data.length;
    final cl = response.headers.value(Headers.contentLengthHeader);
    return int.tryParse(cl ?? '') ?? -1;
  }

  String? _formatRequestBody(RequestOptions options) {
    final data = options.data;
    if (data == null) return null;
    if (data is FormData) {
      return '[FormData fields=${data.fields.length}, files=${data.files.length}]';
    }
    if (data is Stream) return '[Stream]';
    return _renderBody(data);
  }

  String? _formatResponseBody(Response response) {
    if (response.requestOptions.responseType == ResponseType.stream) {
      return '[stream]';
    }
    final data = response.data;
    if (data == null) return null;
    if (data is List<int>) return '[bytes=${data.length}]';
    return _renderBody(data);
  }

  String _renderBody(Object data) {
    String text;
    if (data is Map || data is List) {
      try {
        final redacted = _redactBody(data);
        text = const JsonEncoder.withIndent('  ').convert(redacted);
      } catch (_) {
        text = data.toString();
      }
    } else if (data is String) {
      text = data;
    } else {
      text = data.toString();
    }
    if (text.length > _bodyMaxChars) {
      final more = text.length - _bodyMaxChars;
      text = '${text.substring(0, _bodyMaxChars)}… (truncated, $more more chars)';
    }
    return text;
  }

  Object? _redactBody(Object? value) {
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((k, v) {
        final keyStr = k.toString();
        if (_isSensitiveBodyKey(keyStr)) {
          out[keyStr] = '<redacted>';
        } else {
          out[keyStr] = _redactBody(v);
        }
      });
      return out;
    }
    if (value is List) {
      return value.map(_redactBody).toList();
    }
    return value;
  }

  bool _isSensitiveBodyKey(String key) {
    final k = key.toLowerCase();
    for (final s in _sensitiveBodyKeyParts) {
      if (k.contains(s)) return true;
    }
    return false;
  }

  String _indentBodyBlock(String body) {
    final lines = body.split('\n');
    if (lines.length == 1) return '  body: ${lines.first}';
    final buf = StringBuffer('  body: ${lines.first}');
    for (var i = 1; i < lines.length; i++) {
      buf.write('\n  ${lines[i]}');
    }
    return buf.toString();
  }

  Map<String, String> _redactDioHeaders(Headers headers) {
    final out = <String, String>{};
    headers.forEach((k, v) {
      final lk = k.toLowerCase();
      if (_sensitiveHeaderKeys.contains(lk) || lk.contains('token')) {
        out[k] = '<redacted>';
      } else {
        out[k] = v.join(', ');
      }
    });
    return out;
  }
}

Map<String, String> _redactHeaders(Map<String, dynamic> headers) {
  final out = <String, String>{};
  for (final e in headers.entries) {
    final k = e.key.toLowerCase();
    final v = e.value;
    final stringified = v is List ? v.join(', ') : v.toString();
    if (_sensitiveHeaderKeys.contains(k) || k.contains('token')) {
      out[e.key] = '<redacted>';
    } else {
      out[e.key] = stringified;
    }
  }
  return out;
}
