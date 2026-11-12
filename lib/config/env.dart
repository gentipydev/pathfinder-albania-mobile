import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration read from the bundled `.env` (see `.env.example`).
///
/// Only one key is left: the app's content ships inside the binary (see
/// `assets/backend_snapshot/README.md`), so there is no backend URL and no
/// sign-in to configure.
class Env {
  Env._();

  /// Mapbox public access token (`pk.…`) used by the destination maps.
  /// Optional on purpose: a missing token leaves the map blank rather than
  /// crashing the app, matching how the rest of the app degrades when a
  /// service is absent.
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
}
