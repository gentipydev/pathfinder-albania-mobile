import 'package:dio/dio.dart';
import 'package:travel_buddy/logic/buddy/conversations_service.dart' show HttpException;
import 'package:travel_buddy/logic/common/dio_client.dart';
import 'package:travel_buddy/logic/preferences/user_preferences.dart';

class PreferencesService {
  Map<String, dynamic> _headers(String? bearerToken, {bool isJson = false}) {
    final h = <String, dynamic>{'Accept': 'application/json'};
    if (isJson) h['Content-Type'] = 'application/json';
    if (bearerToken != null && bearerToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearerToken';
    }
    return h;
  }

  /// Returns null for 404 (user has no preferences row yet); throws on
  /// any other non-200.
  Future<UserPreferences?> getMine({String? bearerToken}) async {
    final res = await appDio.get<dynamic>(
      '/preferences/me',
      options: Options(
        headers: _headers(bearerToken),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code == 404) return null;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) return null;
    return UserPreferences.fromJson(decoded);
  }

  Future<void> save(UserPreferences prefs, {String? bearerToken}) async {
    final res = await appDio.post<dynamic>(
      '/preferences',
      data: prefs.toJson(),
      options: Options(
        headers: _headers(bearerToken, isJson: true),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
  }

  /// Persona-picker write path: takes a raw map, drops null values before
  /// serializing, and POSTs. Caller is responsible for including
  /// `language` in the map.
  Future<void> savePreferencesMap(
    Map<String, dynamic> prefs, {
    String? bearerToken,
  }) async {
    final body = <String, dynamic>{};
    prefs.forEach((k, v) {
      if (v != null) body[k] = v;
    });
    final res = await appDio.post<dynamic>(
      '/preferences',
      data: body,
      options: Options(
        headers: _headers(bearerToken, isJson: true),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
  }

  /// Calls Claude server-side; takes ~2-5s. Returns the new persona text.
  Future<String> generatePersona({String? bearerToken}) async {
    final res = await appDio.post<dynamic>(
      '/preferences/persona',
      options: Options(
        headers: _headers(bearerToken),
        receiveTimeout: const Duration(seconds: 90),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code != 200) {
      throw HttpException('HTTP $code', code);
    }
    final decoded = res.data;
    if (decoded is! Map<String, dynamic>) {
      throw HttpException('Malformed persona response', code);
    }
    return (decoded['travel_persona'] as String?) ?? '';
  }
}
