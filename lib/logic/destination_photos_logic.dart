import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/config/env.dart';
import 'package:pathfinder_albania/logic/common/http_client.dart';
import 'package:pathfinder_albania/logic/common/photo_cache.dart';

typedef PhotosHttpFetcher = Future<HttpResponse> Function(String url, {Map<String, String>? headers});

/// One gallery photo: the full-size [url] (fullscreen viewer) and a small
/// copy [thumbUrl] for the grid. They are the same when there is no small
/// copy (bundled photos, or an older backend).
typedef GalleryPhoto = ({String url, String thumbUrl});

/// Fetches the per-destination photo manifest from the backend
/// (`GET /destinations/{slug}/photos`). The backend lists the
/// `place-photos/destinations/{slug}/` Supabase folder and returns ordered
/// public URLs plus a parallel `thumbs` list of small copies; mobile just
/// renders them.
///
/// In-memory cache only — manifests are tiny (one per destination, 8 total).
/// Image bytes live in the on-disk photo cache (`photo_cache.dart`). Inflight requests are deduped to avoid double-fetching during
/// fast tab switches.
///
/// Only successful 2xx responses are cached. A 5xx (typically a backend
/// cold-start) leaves the cache untouched so the next screen mount
/// re-attempts the fetch.
///
/// Whenever the backend has no photos for a destination (unreachable, an
/// error, or an empty Storage folder), [getPhotos] returns the four photos
/// bundled with the app instead, so the gallery is never empty.
class DestinationPhotosLogic {
  DestinationPhotosLogic({PhotosHttpFetcher? httpGet, String Function()? baseUrl})
    : _httpGet = httpGet ?? HttpClient.get,
      _baseUrl = baseUrl ?? (() => Env.apiBaseUrl);

  final PhotosHttpFetcher _httpGet;

  /// Empty when no backend is configured; the fetch is skipped then.
  final String Function() _baseUrl;

  final Map<DestinationType, List<GalleryPhoto>> _cache = {};
  final Map<DestinationType, Future<(bool, List<GalleryPhoto>)>> _inflight = {};

  Future<List<GalleryPhoto>> getPhotos(DestinationType type) async {
    final photos = await _getNetworkPhotos(type);
    if (photos.isNotEmpty) return photos;
    return [for (final p in type.bundledPhotos) (url: p, thumbUrl: p)];
  }

  /// Fetches the manifest and downloads the grid's small copies to disk in
  /// the background, so the Photos tab opens without a wait. Cheap to call
  /// repeatedly: the manifest is cached and cached files are skipped.
  Future<void> prefetch(DestinationType type) async {
    final photos = await getPhotos(type);
    prefetchPhotoUrls(photos.map((p) => p.thumbUrl));
  }

  Future<List<GalleryPhoto>> _getNetworkPhotos(DestinationType type) async {
    final cached = _cache[type];
    if (cached != null) return cached;

    final existing = _inflight[type];
    if (existing != null) {
      final (_, photos) = await existing;
      return photos;
    }

    final future = _fetch(type);
    _inflight[type] = future;
    try {
      final (ok, result) = await future;
      if (ok) _cache[type] = result;
      return result;
    } finally {
      _inflight.remove(type);
    }
  }

  Future<(bool, List<GalleryPhoto>)> _fetch(DestinationType type) async {
    final base = _baseUrl();
    if (base.isEmpty) return (false, const <GalleryPhoto>[]);
    final url = '$base/destinations/${type.slug}/photos';
    final response = await _httpGet(url);
    if (!response.success || response.body == null) {
      dev.log('destinationPhotosLogic: ${type.slug} -> ${response.statusCode}');
      return (false, const <GalleryPhoto>[]);
    }
    try {
      final decoded = jsonDecode(response.body!) as Map<String, dynamic>;
      final rawPhotos = decoded['photos'] as List? ?? const [];
      final rawThumbs = decoded['thumbs'] as List? ?? const [];
      final photos = <GalleryPhoto>[];
      for (var i = 0; i < rawPhotos.length; i++) {
        final url = rawPhotos[i];
        if (url is! String) continue;
        final thumb = i < rawThumbs.length ? rawThumbs[i] : null;
        photos.add((url: url, thumbUrl: thumb is String && thumb.isNotEmpty ? thumb : url));
      }
      return (true, List<GalleryPhoto>.unmodifiable(photos));
    } catch (e) {
      // FormatException for invalid JSON, TypeError for a non-object body.
      dev.log('destinationPhotosLogic parse error: $e');
      return (false, const <GalleryPhoto>[]);
    }
  }
}
