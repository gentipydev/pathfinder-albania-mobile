import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Base map styles used by the two Mapbox surfaces in the app: the editorial
/// thumbnail (Standard) and the fullscreen destination viewer (Standard
/// Satellite). The land and water palette is Mapbox Standard's own and does
/// not match AppColors; matching the brand would mean a custom style authored
/// in Mapbox Studio and referenced by `styleUri`.
const String kMapboxNormalStyle = MapboxStyles.STANDARD;
const String kMapboxSatelliteStyle = MapboxStyles.STANDARD_SATELLITE;
