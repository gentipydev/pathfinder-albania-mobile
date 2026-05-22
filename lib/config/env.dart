import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Dev convenience only — release builds must set API_BASE_URL explicitly so a
  // forgotten .env entry cannot ship pointing at a dev backend.
  static const _devApiBaseUrl = 'https://travel-buddy-backend-0khg.onrender.com';

  static String get apiBaseUrl {
    final override = dotenv.env['API_BASE_URL'] ?? '';
    if (override.isNotEmpty) return override;
    if (kDebugMode) return _devApiBaseUrl;
    throw StateError(
      'API_BASE_URL is required in release builds. '
      'Add API_BASE_URL=... to your .env file.',
    );
  }

  static void assertValid() {
    if (supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL missing. Add SUPABASE_URL=... to your .env file '
        '(copy .env.example to .env and fill in the values).',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY missing. Add SUPABASE_ANON_KEY=... to your .env file '
        '(copy .env.example to .env and fill in the values).',
      );
    }
  }
}
