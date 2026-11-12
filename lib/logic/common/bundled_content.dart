import 'package:flutter/services.dart' show rootBundle;

/// Reads a bundled text asset. Injected into the content loaders so tests
/// can feed them JSON without touching the asset bundle.
typedef AssetTextLoader = Future<String> Function(String key);

/// Where the showcase's artifact catalog and destination photos live while
/// the backend is being rewritten: a snapshot of the old Supabase Storage
/// buckets bundled under `assets/backend_snapshot/` (see its README). The
/// manifests use the same JSON shapes the old `/destinations/{slug}/artifacts`
/// and `/destinations/{slug}/photos` endpoints returned, keyed by slug, with
/// asset paths where the URLs used to be. Re-pointing the app at a new
/// backend later means swapping the loaders, not the screens.
class BundledContent {
  BundledContent._();

  static const String root = 'assets/backend_snapshot';
  static const String artifactsManifest = '$root/manifests/artifacts.json';
  static const String photosManifest = '$root/manifests/photos.json';

  static Future<String> loadString(String key) => rootBundle.loadString(key);
}
