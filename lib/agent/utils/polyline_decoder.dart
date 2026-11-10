import 'dart:math' as math;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Decodes a precision-5 encoded polyline into GeoJSON positions.
///
/// This is what the backend stores on every route leg (Mapbox Directions
/// returns it directly for `geometries=polyline`).
///
/// NOTE the axis order: [Position] is **longitude first**, the reverse of the
/// `LatLng(lat, lng)` this used to return. Getting it backwards puts Albanian
/// stops in the Indian Ocean, so it is covered by a unit test.
List<Position> decodeEncodedPolyline(String encoded) {
  if (encoded.isEmpty) return const [];
  final points = PolylinePoints().decodePolyline(encoded);
  return [for (final p in points) Position(p.longitude, p.latitude)];
}

/// Cumulative arc-length fraction (0..1) at each vertex of [pts].
///
/// Mapbox's `line-trim-offset` is expressed as a fraction of the line's total
/// **length**, not of its vertex count, so progressively revealing a route
/// needs this mapping from "we are at vertex i" to "we are f of the way
/// along". Returns a list the same length as [pts], starting at 0.0 and
/// ending at 1.0 (all zeroes for a degenerate zero-length line).
///
/// Uses an equirectangular approximation — at Albania's scale the error
/// against a full haversine is far below one rendered pixel.
List<double> cumulativeFractions(List<Position> pts) {
  if (pts.isEmpty) return const [];
  if (pts.length == 1) return const [0.0];

  final cumulative = List<double>.filled(pts.length, 0);
  var total = 0.0;
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final latA = a.lat.toDouble();
    final latB = b.lat.toDouble();
    final meanLatRad = (latA + latB) / 2 * math.pi / 180;
    // Scale the longitude delta by cos(lat) so a degree of longitude counts
    // for what it is worth at this latitude.
    final dx = (b.lng.toDouble() - a.lng.toDouble()) * math.cos(meanLatRad);
    final dy = latB - latA;
    total += math.sqrt(dx * dx + dy * dy);
    cumulative[i] = total;
  }

  if (total <= 0) return cumulative;
  for (var i = 0; i < cumulative.length; i++) {
    cumulative[i] = cumulative[i] / total;
  }
  // Guard against float drift leaving the last vertex a hair under 1.0.
  cumulative[cumulative.length - 1] = 1.0;
  return cumulative;
}
