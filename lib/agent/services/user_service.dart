import 'package:dio/dio.dart';
import 'package:pathfinder_albania/logic/common/dio_client.dart';
import 'package:pathfinder_albania/logic/common/service_exception.dart';

/// Calls into `/users/*` on the backend. Today's only call is the idempotent
/// sync that creates a row in the local `users` table for a Supabase user, so
/// downstream `require_local_user`-protected endpoints (POST /trips, etc.) can
/// resolve them by `supabase_uid`.
class UserService {
  UserService({Dio? dio}) : _dio = dio ?? appDio;

  final Dio _dio;

  Map<String, dynamic> _headers(String? bearerToken) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (bearerToken != null && bearerToken.isNotEmpty)
      'Authorization': 'Bearer $bearerToken',
  };

  /// POST /users/me/sync — idempotent. Silent no-op when the caller is
  /// anonymous (no bearer); the backend would 401 anyway and unsynced is the
  /// correct state for an anon session.
  Future<void> sync({required String? bearerToken}) async {
    if (bearerToken == null || bearerToken.isEmpty) return;
    final res = await _dio.post<dynamic>(
      '/users/me/sync',
      options: Options(
        headers: _headers(bearerToken),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    if (code < 200 || code >= 300) {
      final body = res.data;
      throw UserServiceException(code, body is String ? body : (body?.toString() ?? ''));
    }
  }

  /// DELETE /users/me — cascading account delete. Wipes the user's photos
  /// (chat-attachments bucket), local users row (FK CASCADE handles trips,
  /// conversations, prefs), and Supabase auth user. The caller should then
  /// call `Supabase.instance.client.auth.signOut()` so the local session
  /// store is cleared.
  Future<void> deleteAccount({required String? bearerToken}) async {
    if (bearerToken == null || bearerToken.isEmpty) {
      throw UserServiceException(401, 'no bearer token');
    }
    final res = await _dio.delete<dynamic>(
      '/users/me',
      options: Options(
        headers: _headers(bearerToken),
        validateStatus: (_) => true,
      ),
    );
    final code = res.statusCode ?? -1;
    // The backend swallows storage + auth failures and still returns 204;
    // a non-204 here means the DB delete (or earlier) blew up.
    if (code != 204) {
      final body = res.data;
      throw UserServiceException(
        code,
        body is String ? body : (body?.toString() ?? ''),
      );
    }
  }
}

class UserServiceException implements ServiceException {
  UserServiceException(this.statusCode, this.body);
  @override
  final int statusCode;
  final String body;

  @override
  String toString() => 'UserServiceException($statusCode): $body';
}
