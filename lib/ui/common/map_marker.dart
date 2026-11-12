import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pathfinder_albania/assets.dart';

/// Single generic pin used by the destination maps (editorial thumbnail and
/// the fullscreen viewer).
PointAnnotationOptions buildPinAnnotationOptions(Position position) => PointAnnotationOptions(
  geometry: Point(coordinates: position),
  image: AppBitmaps.mapMarker,
  iconAnchor: IconAnchor.BOTTOM,
);
