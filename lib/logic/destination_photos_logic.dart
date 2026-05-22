import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/config/env.dart';
import 'package:travel_buddy/logic/common/http_client.dart';

/// Fetches the per-destination photo manifest from the backend
/// (`GET /destinations/{slug}/photos`). The backend lists the
/// `place-photos/destinations/{slug}/` Supabase folder and returns ordered
/// public URLs; mobile just renders them.
///
/// In-memory cache only — manifests are tiny (one per destination, 8 total)
/// and Supabase image bytes are cached by the platform image cache once
/// loaded. Inflight requests are deduped to avoid double-fetching during
/// fast tab switches.
///
/// Only successful 2xx responses are cached. A 5xx (typically a cold-start
/// on the Render free tier) returns an empty list to the caller but leaves
/// the cache untouched so the next screen mount re-attempts the fetch
/// instead of permanently showing an empty gallery.
class DestinationPhotosLogic {
  final Map<DestinationType, List<String>> _cache = {};
  final Map<DestinationType, Future<(bool, List<String>)>> _inflight = {};

  Future<List<String>> getPhotos(DestinationType type) async {
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

  /// Returns the cached list synchronously, or null if not yet fetched.
  /// Useful for screens that already triggered a getPhotos() and want a
  /// non-await read on rebuild.
  List<String>? cached(DestinationType type) => _cache[type];

  Future<(bool, List<String>)> _fetch(DestinationType type) async {
    final url = '${Env.apiBaseUrl}/destinations/${type.slug}/photos';
    final response = await HttpClient.get(url);
    if (!response.success || response.body == null) {
      dev.log('destinationPhotosLogic: ${type.slug} -> ${response.statusCode}');
      return (false, const <String>[]);
    }
    try {
      final decoded = jsonDecode(response.body!) as Map<String, dynamic>;
      final photos = (decoded['photos'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false);
      return (true, photos);
    } on FormatException catch (e) {
      dev.log('destinationPhotosLogic parse error: ${e.message}');
      return (false, const <String>[]);
    }
  }
}
