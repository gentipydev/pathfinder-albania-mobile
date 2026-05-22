/// AppColors-derived base-map theme applied to every Google Map surface
/// in the app — both the static thumbnail in the buddy chat bubble and the
/// interactive [GoogleMap] on TripMapScreen.
///
/// The same rules are mirrored in
/// `travel-buddy-backend/app/services/static_map.py:_MAP_STYLE_RULES`
/// (Google Static Maps `style=` URL params) — change both together or the
/// thumbnail will render differently from the full map.
///
/// Palette anchors:
///   - `#F8ECE5` → AppColors.offWhite  (landscape fill)
///   - `#9BB7C2` → Adriatic slate-lite (water)
///   - `#514F4D` → AppColors.body      (administrative label text)
///   - POIs and transit are hidden so they don't compete with the day-color
///     trip markers (which are the only "story" on this map).
const String kAppMapStyleJson = '''[
  { "featureType": "water",          "stylers": [{ "color": "#9BB7C2" }] },
  { "featureType": "landscape",      "stylers": [{ "color": "#F8ECE5" }] },
  { "featureType": "road",           "elementType": "geometry",         "stylers": [{ "color": "#FFFFFF" }] },
  { "featureType": "road",           "elementType": "labels",           "stylers": [{ "visibility": "off" }] },
  { "featureType": "poi",            "stylers": [{ "visibility": "off" }] },
  { "featureType": "administrative", "elementType": "labels.text.fill", "stylers": [{ "color": "#514F4D" }] },
  { "featureType": "transit",        "stylers": [{ "visibility": "off" }] }
]''';
