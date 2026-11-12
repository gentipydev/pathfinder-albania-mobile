import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show Position;
import 'package:pathfinder_albania/agent/utils/polyline_decoder.dart';

void main() {
  group('decodeEncodedPolyline', () {
    test('returns positions in longitude-first order', () {
      // Encodes (41.3275, 19.8189) then (41.3300, 19.8250) — Tirana. The point
      // of this test is the axis order: Position is (lng, lat), the reverse
      // of the LatLng this used to return. Swapped, these land at 19° N /
      // 41° E — the Arabian Sea — which renders as a plausible-looking map
      // rather than an obvious crash.
      const encoded = r'{wf{Fc{}wBsNce@';
      final points = decodeEncodedPolyline(encoded);

      expect(points, hasLength(2));
      expect(points[0].lat, closeTo(41.3275, 1e-5), reason: 'latitude is the 2nd axis');
      expect(points[0].lng, closeTo(19.8189, 1e-5), reason: 'longitude is the 1st axis');
      expect(points[1].lat, closeTo(41.3300, 1e-5));
      expect(points[1].lng, closeTo(19.8250, 1e-5));
      // Second point is north-east of the first.
      expect(points[1].lat, greaterThan(points[0].lat));
      expect(points[1].lng, greaterThan(points[0].lng));
    });

    test('returns empty for an empty string', () {
      expect(decodeEncodedPolyline(''), isEmpty);
    });
  });

  group('cumulativeFractions', () {
    test('is monotonic from 0 to 1 with one entry per vertex', () {
      final fractions = cumulativeFractions(decodeEncodedPolyline(r'{wf{Fc{}wBsNce@'));
      expect(fractions, hasLength(2));
      expect(fractions.first, 0.0);
      expect(fractions.last, 1.0);
    });

    test('splits an evenly-spaced line evenly', () {
      // Three collinear points along the equator, equally spaced. The middle
      // vertex should land at the halfway mark.
      final fractions = cumulativeFractions([
        Position(0, 0),
        Position(1, 0),
        Position(2, 0),
      ]);
      expect(fractions, hasLength(3));
      expect(fractions[0], 0.0);
      expect(fractions[1], closeTo(0.5, 1e-9));
      expect(fractions[2], 1.0);
    });

    test('is monotonically non-decreasing', () {
      final fractions = cumulativeFractions([
        Position(19.8, 41.3),
        Position(19.9, 41.4),
        Position(20.4, 41.1),
        Position(20.5, 40.6),
      ]);
      for (var i = 1; i < fractions.length; i++) {
        expect(fractions[i], greaterThanOrEqualTo(fractions[i - 1]));
      }
      expect(fractions.last, 1.0);
    });

    test('handles degenerate inputs', () {
      expect(cumulativeFractions(const []), isEmpty);
      expect(cumulativeFractions([Position(19.8, 41.3)]), [0.0]);
      // A zero-length line has no meaningful fractions; all zeroes beats NaN.
      final flat = cumulativeFractions([Position(1, 1), Position(1, 1)]);
      expect(flat, everyElement(0.0));
    });
  });
}
