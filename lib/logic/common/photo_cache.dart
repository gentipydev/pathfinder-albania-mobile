import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

bool _isRemote(String src) => src.startsWith('http://') || src.startsWith('https://');

/// Image provider for a photo source: an http(s) URL from the backend, kept
/// in the on-disk cache so revisits and relaunches don't download it again,
/// or the path of a photo bundled in assets/ (the gallery's offline
/// fallback).
ImageProvider photoImageProvider(String src) => _isRemote(src) ? CachedNetworkImageProvider(src) : AssetImage(src);

/// Downloads remote photos into the on-disk cache in the background, so they
/// show without a wait when their screen opens. Nothing is decoded, so no
/// memory is spent on photos the user may never look at. Already-cached
/// files are skipped; failures are ignored (the widget just loads it again).
void prefetchPhotoUrls(Iterable<String> urls) {
  if (kIsWeb) return; // the browser's HTTP cache covers this on web
  for (final url in urls.where(_isRemote).toSet()) {
    unawaited(DefaultCacheManager().getSingleFile(url).then((_) {}, onError: (_) {}));
  }
}
