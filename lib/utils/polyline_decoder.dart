import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<LatLng> decodeEncodedPolyline(String encoded) {
  if (encoded.isEmpty) return const [];
  final points = PolylinePoints().decodePolyline(encoded);
  return [for (final p in points) LatLng(p.latitude, p.longitude)];
}
