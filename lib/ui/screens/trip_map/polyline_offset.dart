import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// One degree of latitude is constant ≈ 111.32 km. Longitude scales by
/// cos(latitude) — handled per polyline using the first point's latitude.
const double _metersPerDegreeLat = 111320.0;

/// Returns a copy of [points] parallel-offset by [offsetMeters] perpendicular
/// to the direction of travel. Positive shifts to the right of travel; pass
/// a negative value for the left.
///
/// For multi-segment polylines, interior vertices use the bisector of the two
/// adjacent perpendiculars so the offset curve follows the original shape
/// without creasing. A mitre clamp caps the corner extension at sharp turns.
///
/// Returns [points] unchanged when:
///   * [offsetMeters] is zero (no-op);
///   * fewer than 2 distinct points after collapsing consecutive duplicates;
///   * polyline lies at a degenerate latitude (cos→0) where the conversion
///     would explode.
List<LatLng> offsetPolyline(List<LatLng> points, double offsetMeters) {
  if (offsetMeters == 0 || points.length < 2) return points;

  // Drop consecutive duplicates so every segment has a well-defined direction.
  final pts = <LatLng>[];
  for (final p in points) {
    if (pts.isEmpty ||
        pts.last.latitude != p.latitude ||
        pts.last.longitude != p.longitude) {
      pts.add(p);
    }
  }
  if (pts.length < 2) return points;

  final cosLat = math.cos(pts.first.latitude * math.pi / 180);
  if (cosLat.abs() < 1e-6) return points;
  final metersPerDegLng = _metersPerDegreeLat * cosLat;

  // Per-segment right-perpendicular unit vectors in (lng, lat) order. Sign
  // convention: rotate the segment vector −90° so positive [offsetMeters]
  // means "right of travel."
  final perpSeg = List<_Vec2>.filled(pts.length - 1, const _Vec2(0, 0));
  for (var i = 0; i < pts.length - 1; i++) {
    final dxM = (pts[i + 1].longitude - pts[i].longitude) * metersPerDegLng;
    final dyM = (pts[i + 1].latitude - pts[i].latitude) * _metersPerDegreeLat;
    final len = math.sqrt(dxM * dxM + dyM * dyM);
    if (len < 1e-6) continue; // shouldn't happen after dedup, defensive
    perpSeg[i] = _Vec2(dyM / len, -dxM / len);
  }

  // Cap corner-offset magnitude at this multiple of [offsetMeters] to prevent
  // long spikes at sharp turns. 3.0 means a corner sharper than ~140° gets
  // visually cut rather than extended.
  const double mitreClamp = 3.0;

  final out = <LatLng>[];
  for (var i = 0; i < pts.length; i++) {
    final _Vec2 perp;
    if (i == 0) {
      perp = perpSeg.first;
    } else if (i == pts.length - 1) {
      perp = perpSeg.last;
    } else {
      final v1 = perpSeg[i - 1];
      final v2 = perpSeg[i];
      final sumX = v1.x + v2.x;
      final sumY = v1.y + v2.y;
      final sumLen = math.sqrt(sumX * sumX + sumY * sumY);
      if (sumLen < 1e-6) {
        // 180° reversal — bisector undefined; cut the corner.
        perp = v1;
      } else {
        // Geometric bisector scale for unit perpendiculars: 2 / sumLen².
        // Clamped scale for mitre: mitreClamp / sumLen (so magnitude ≤ clamp).
        final scaleA = 2.0 / (sumLen * sumLen);
        final scaleB = mitreClamp / sumLen;
        final scale = scaleA < scaleB ? scaleA : scaleB;
        perp = _Vec2(sumX * scale, sumY * scale);
      }
    }

    final latDelta = perp.y * offsetMeters / _metersPerDegreeLat;
    final lngDelta = perp.x * offsetMeters / metersPerDegLng;
    out.add(LatLng(
      pts[i].latitude + latDelta,
      pts[i].longitude + lngDelta,
    ));
  }
  return out;
}

/// Offset for a within-day polyline in [dayNumber] (1-indexed). Day 1 = 0
/// (baseline, sits on the actual road); each subsequent day steps by
/// [stepMeters] perpendicular.
double offsetForDay(int dayNumber, {double stepMeters = 2.5}) {
  if (dayNumber < 1) return 0;
  return (dayNumber - 1) * stepMeters;
}

/// Offset for a cross-day polyline connecting [fromDay] and [toDay] — sits
/// in its own lane between the two days' within-day offsets.
double offsetForCrossDay(
  int fromDay,
  int toDay, {
  double stepMeters = 2.5,
}) {
  return (offsetForDay(fromDay, stepMeters: stepMeters) +
          offsetForDay(toDay, stepMeters: stepMeters)) /
      2;
}

class _Vec2 {
  final double x;
  final double y;
  const _Vec2(this.x, this.y);
}
