import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Base map styles used by every Mapbox surface in the app.
///
/// The interactive trip map toggles between these two; the destination
/// maps pick their own (satellite imagery for the fullscreen viewer).
const String kMapboxNormalStyle = MapboxStyles.STANDARD;
const String kMapboxSatelliteStyle = MapboxStyles.STANDARD_SATELLITE;

/// The style-import id of the basemap inside Mapbox Standard. Config
/// properties are addressed against it, not against the root style.
const String kBasemapImportId = 'basemap';

/// Applied via `style.setStyleImportConfigProperties(kBasemapImportId, ...)`
/// on every style load — including after a normal↔satellite swap, which
/// resets the style wholesale.
///
/// The intent is to hide the POI / transit / road-label noise so the
/// day-colored trip markers are the only story on the map. The land and water
/// palette is Mapbox Standard's own and does not match AppColors.
///
/// NOTE: this map and the `trip.staticMapUrl` thumbnail deliberately don't
/// match. The backend builds that thumbnail with the Static Images API
/// (`travel-buddy-backend/app/integrations/mapbox_static.py`), which renders
/// classic styles only — it uses `light-v11` because Standard is GL-only.
/// Do not "fix" one side to match the other; the constraint is Mapbox's.
const Map<String, Object> kBasemapConfig = <String, Object>{
  'showPointOfInterestLabels': false,
  'showTransitLabels': false,
  'showRoadLabels': false,
  'lightPreset': 'day',
};
