import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:travel_buddy/assets.dart';

/// Single generic pin used by the destination maps (editorial thumbnail and
/// the fullscreen viewer). Trip stops use [buildStopAnnotationOptions] with a
/// per-stop photo bitmap instead.
PointAnnotationOptions buildPinAnnotationOptions(Position position) => PointAnnotationOptions(
  geometry: Point(coordinates: position),
  image: AppBitmaps.mapMarker,
  iconAnchor: IconAnchor.BOTTOM,
);

// Render the marker bitmap at retina density. Mapbox draws the PNG at its
// natural pixel size scaled by `iconSize`, so the bitmap is rasterized at
// [_markerPixelRatio]× the logical size and drawn back down via
// [kStopMarkerBaseIconSize] — plenty of physical pixels on a 3× device.
const double _markerPixelRatio = 3.0;

/// `iconSize` that renders a [buildPhotoMarkerBitmap] result at its intended
/// logical size. The bitmap is [_markerPixelRatio]× oversampled, so the
/// neutral on-screen scale is its reciprocal. Animations multiply this.
const double kStopMarkerBaseIconSize = 1 / _markerPixelRatio;

// Enough source pixels to feed FilterQuality.high at the largest on-screen
// size (logicalSize × 1.4 pulse × 3 DPR × ≈2 retina headroom ÷ 0.93 inner
// circle factor). One decode per unique URL, memo-cached forever.
const int _photoDecodeWidth = 256;

// Process-wide memo of decoded photos. Keyed by URL — every TripStop with
// the same `photoUrl` decodes once and shares the resulting `ui.Image`
// across every marker it appears in.
final Map<String, Future<ui.Image?>> _photoImageCache = {};

/// Decodes the photo at [photoUrl] into a `ui.Image` once and memoizes the
/// result. Subsequent calls for the same URL return the same Future.
/// Returns `null` for null URLs or on network/decode errors so callers
/// can fall back to the photoless variant.
Future<ui.Image?> resolveStopPhoto(String? photoUrl) {
  if (photoUrl == null) return Future.value(null);
  return _photoImageCache.putIfAbsent(photoUrl, () {
    final completer = Completer<ui.Image?>();
    final provider = ResizeImage(
      NetworkImage(photoUrl),
      width: _photoDecodeWidth,
    );
    final stream = provider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(info.image);
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  });
}

/// Async-paint a small round photo marker: the image inside a thin
/// day-color border, with a small numbered chip in the top-right corner
/// carrying the continuous trip-wide stop index.
///
/// [logicalSize] is the intended on-screen marker diameter in dp. The bitmap
/// is rasterized at [logicalSize] × [_markerPixelRatio] physical pixels;
/// render it with `iconSize: kStopMarkerBaseIconSize` to land at that size.
///
/// Caller MUST cache by (color, photoUrl, stopNumber) — generating the
/// bitmap involves a Picture rasterization + PNG encode that's slow on the
/// main isolate, but the result is stable for those inputs. Scale is NOT part
/// of the key: Mapbox animates it with `iconSize`, so one bitmap per stop is
/// enough.
Future<Uint8List> buildPhotoMarkerBitmap({
  required ui.Image? photo,
  required Color dayColor,
  required int stopNumber,
  double logicalSize = 64,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Work in physical pixels for crisp anti-aliasing at retina density.
  final pxSize = logicalSize * _markerPixelRatio;
  final center = Offset(pxSize / 2, pxSize / 2);
  // Tiny inset so anti-aliased edges don't clip on the bitmap boundary.
  final outerRadius = pxSize / 2 - pxSize * 0.02;
  // Day-color rim — kept thin but thick enough to survive small logical
  // sizes without aliasing to a sub-pixel line.
  final borderWidth = pxSize * 0.025;
  final innerRadius = outerRadius - borderWidth;

  // Day-color border ring.
  canvas.drawCircle(center, outerRadius, Paint()..color = dayColor);

  // Photo (or fallback) clipped to the inner circle.
  canvas.save();
  canvas.clipPath(
    Path()..addOval(Rect.fromCircle(center: center, radius: innerRadius)),
  );
  if (photo != null) {
    // BoxFit.cover-equivalent: largest centered square crop, scaled to fill.
    final photoW = photo.width.toDouble();
    final photoH = photo.height.toDouble();
    final cropSize = photoW < photoH ? photoW : photoH;
    final src = Rect.fromLTWH(
      (photoW - cropSize) / 2,
      (photoH - cropSize) / 2,
      cropSize,
      cropSize,
    );
    final dst = Rect.fromCircle(center: center, radius: innerRadius);
    canvas.drawImageRect(
      photo,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
  } else {
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = dayColor.withValues(alpha: 0.85),
    );
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.place_outlined.codePoint),
        style: TextStyle(
          fontSize: pxSize * 0.5,
          color: Colors.white,
          fontFamily: Icons.place_outlined.fontFamily,
          package: Icons.place_outlined.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        (pxSize - iconPainter.width) / 2,
        (pxSize - iconPainter.height) / 2,
      ),
    );
  }
  canvas.restore();

  // Numbered chip — a single filled day-color disc at the top-right. No
  // outline: the photo's day-color rim is the visual anchor.
  final badgeRadius = pxSize * 0.16;
  final badgeCenter = Offset(
    pxSize - badgeRadius - pxSize * 0.025,
    badgeRadius + pxSize * 0.025,
  );
  canvas.drawCircle(badgeCenter, badgeRadius, Paint()..color = dayColor);
  final numPainter = TextPainter(
    text: TextSpan(
      text: '$stopNumber',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: badgeRadius * 1.05,
        height: 1.0,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  )..layout();
  numPainter.paint(
    canvas,
    Offset(
      badgeCenter.dx - numPainter.width / 2,
      badgeCenter.dy - numPainter.height / 2,
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(pxSize.round(), pxSize.round());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

/// Builds the creation options for a trip-stop annotation.
///
/// Anchored at CENTER so scale-based entrance/pulse animations expand radially
/// around the marker centre rather than growing from the bottom-centre default.
/// [scale] is a multiplier on the neutral [kStopMarkerBaseIconSize]; the drop-in
/// and pulse animations drive it by mutating `iconSize` on the created
/// annotation, which is why no per-scale bitmap variants exist.
PointAnnotationOptions buildStopAnnotationOptions({
  required Position position,
  required Uint8List icon,
  double scale = 1.0,
  double opacity = 1.0,
}) => PointAnnotationOptions(
  geometry: Point(coordinates: position),
  image: icon,
  iconAnchor: IconAnchor.CENTER,
  iconSize: kStopMarkerBaseIconSize * scale,
  iconOpacity: opacity,
);
