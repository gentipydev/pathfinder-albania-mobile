import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/common/bundled_content.dart';
import 'package:pathfinder_albania/logic/common/photo_cache.dart';

/// One gallery photo: the full-size [url] (fullscreen viewer) and a small
/// copy [thumbUrl] for the grid. They are the same when there is no small
/// copy (the four photos bundled per destination).
typedef GalleryPhoto = ({String url, String thumbUrl});

/// Reads the per-destination photo list from the bundled snapshot manifest
/// ([BundledContent.photosManifest]): ordered asset paths plus a parallel
/// `thumbs` list of small copies; mobile just renders them.
///
/// The manifest is read once; parsed lists are kept per destination.
/// Whenever the snapshot has no photos for a destination (missing entry,
/// unreadable manifest, or an empty list), [getPhotos] returns the four
/// photos bundled with the app instead, so the gallery is never empty.
class DestinationPhotosLogic {
  DestinationPhotosLogic({
    AssetTextLoader? loadAsset,
    String manifestKey = BundledContent.photosManifest,
  })  : _loadAsset = loadAsset ?? BundledContent.loadString,
        _manifestKey = manifestKey;

  final AssetTextLoader _loadAsset;
  final String _manifestKey;

  /// The decoded manifest, read once. A failed read resolves to null and is
  /// not kept, so the next call retries.
  Future<Map<String, dynamic>?>? _manifest;

  final Map<DestinationType, List<GalleryPhoto>> _cache = {};

  Future<List<GalleryPhoto>> getPhotos(DestinationType type) async {
    final photos = await _getSnapshotPhotos(type);
    if (photos.isNotEmpty) return photos;
    return [for (final p in type.bundledPhotos) (url: p, thumbUrl: p)];
  }

  /// Reads the list and warms the grid's small copies, so the Photos tab
  /// opens without a wait. Cheap to call repeatedly: the list is cached and
  /// bundled files cost nothing to "prefetch".
  Future<void> prefetch(DestinationType type) async {
    final photos = await getPhotos(type);
    prefetchPhotoUrls(photos.map((p) => p.thumbUrl));
  }

  Future<List<GalleryPhoto>> _getSnapshotPhotos(DestinationType type) async {
    final cached = _cache[type];
    if (cached != null) return cached;
    final (ok, result) = await _read(type);
    if (ok) _cache[type] = result;
    return result;
  }

  Future<Map<String, dynamic>?> _readManifest() {
    final existing = _manifest;
    if (existing != null) return existing;
    late final Future<Map<String, dynamic>?> future;
    future = _loadManifest().then((manifest) {
      if (manifest == null && identical(_manifest, future)) _manifest = null;
      return manifest;
    });
    _manifest = future;
    return future;
  }

  Future<Map<String, dynamic>?> _loadManifest() async {
    try {
      final decoded = jsonDecode(await _loadAsset(_manifestKey));
      if (decoded is Map<String, dynamic>) return decoded;
      dev.log('destinationPhotosLogic: manifest is not a JSON object');
      return null;
    } catch (e) {
      dev.log('destinationPhotosLogic: manifest read failed: $e');
      return null;
    }
  }

  Future<(bool, List<GalleryPhoto>)> _read(DestinationType type) async {
    final manifest = await _readManifest();
    final entry = manifest?[type.slug];
    if (entry is! Map<String, dynamic>) {
      dev.log('destinationPhotosLogic: no manifest entry for ${type.slug}');
      return (false, const <GalleryPhoto>[]);
    }
    final rawPhotos = entry['photos'] as List? ?? const [];
    final rawThumbs = entry['thumbs'] as List? ?? const [];
    final photos = <GalleryPhoto>[];
    for (var i = 0; i < rawPhotos.length; i++) {
      final url = rawPhotos[i];
      if (url is! String) continue;
      final thumb = i < rawThumbs.length ? rawThumbs[i] : null;
      photos.add((url: url, thumbUrl: thumb is String && thumb.isNotEmpty ? thumb : url));
    }
    return (true, List<GalleryPhoto>.unmodifiable(photos));
  }
}
