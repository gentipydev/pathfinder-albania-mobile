import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Which parts of the app are switched on, chosen with `APP_MODE` in `.env`.
enum AppMode {
  /// Only the destinations showcase (home carousel + destination details).
  /// No chat, trips, profile or sign-in, and Supabase is never initialized.
  showcase,

  /// Showcase plus the agent side (bottom nav, Buddy chat, My Trips, Profile).
  full,
}

class Env {
  /// `APP_MODE=showcase` or `APP_MODE=full`. Missing or empty means `full`,
  /// so builds that don't set it keep today's behavior. Unlike
  /// [bypassLogin], this works in release builds too.
  static AppMode get appMode => parseAppMode(dotenv.env['APP_MODE']);

  /// True when the agent side (chat, trips, profile, auth) is switched on.
  static bool get agentEnabled => appMode == AppMode.full;

  @visibleForTesting
  static AppMode parseAppMode(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    return switch (value) {
      '' || 'full' => AppMode.full,
      'showcase' => AppMode.showcase,
      _ => throw StateError(
        'APP_MODE="$raw" is not valid. Use APP_MODE=showcase or APP_MODE=full in your .env file.',
      ),
    };
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Dev convenience only — release builds must set API_BASE_URL explicitly so a
  // forgotten .env entry cannot ship pointing at a dev backend. A release build
  // without it gets an empty base URL: the backend-backed screens show their
  // empty / bundled fallbacks instead of the app crashing on launch.
  //
  // The backend runs locally; no host is deployed. This default suits the iOS
  // Simulator, which shares the Mac's loopback. Other targets need an explicit
  // API_BASE_URL in .env: the Android emulator reaches the host at
  // http://10.0.2.2:8000, and a physical device needs the Mac's LAN IP with
  // uvicorn bound to --host 0.0.0.0.
  static const _devApiBaseUrl = 'http://127.0.0.1:8000';

  static String get apiBaseUrl => resolveApiBaseUrl(dotenv.env['API_BASE_URL'], isDebug: kDebugMode);

  /// False only in a release build with no API_BASE_URL. Callers skip their
  /// requests then rather than calling a relative URL.
  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;

  @visibleForTesting
  static String resolveApiBaseUrl(String? override, {required bool isDebug}) {
    final value = (override ?? '').trim();
    if (value.isNotEmpty) return value;
    return isDebug ? _devApiBaseUrl : '';
  }

  /// Mapbox public access token (`pk.…`) used by every map surface. Optional
  /// on purpose: a missing token leaves the map blank rather than crashing the
  /// app, matching how the rest of the app degrades when a service is absent.
  /// Deliberately NOT checked in [assertValid].
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  /// TEMPORARY dev escape hatch: `BYPASS_LOGIN=true` in .env stops the app
  /// from routing to the login screen (bootstrap, router auth gate, end of
  /// intro). Auth itself is untouched — there is still no session, so the
  /// token-gated backend endpoints (chat, trips, conversations, preferences)
  /// return 401. Debug builds only, so it can never ship enabled.
  static bool get bypassLogin =>
      kDebugMode && (dotenv.env['BYPASS_LOGIN'] ?? '').toLowerCase() == 'true';

  static void assertValid() {
    // Throws on a typo such as APP_MODE=showcse instead of silently
    // falling back to full mode.
    parseAppMode(dotenv.env['APP_MODE']);
    if (!hasApiBaseUrl) {
      debugPrint(
        'WARNING: API_BASE_URL is not set, so photos, artifacts'
        '${agentEnabled ? ' and chat' : ''} will be unavailable. '
        'Add API_BASE_URL=... to your .env file.',
      );
    }
    // Supabase only backs the agent side (auth, trips, chat attachments).
    if (!agentEnabled) return;
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
