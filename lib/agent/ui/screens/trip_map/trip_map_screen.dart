import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// `hide Size`: Mapbox exports its own Size, which shadows dart:ui's
// everywhere Flutter widgets need it.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
// `hide Point`: common_libs re-exports dart:math, whose Point collides with
// the GeoJSON Point every Mapbox geometry is built from. Nothing here wants
// the dart:math one.
import 'package:pathfinder_albania/common_libs.dart' hide Point;
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_route.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_stop.dart';
import 'package:pathfinder_albania/logic/common/concurrency.dart';
import 'package:pathfinder_albania/logic/common/platform_info.dart';
import 'package:pathfinder_albania/styles/map_style.dart';
import 'package:pathfinder_albania/ui/common/controls/app_header.dart';
import 'package:pathfinder_albania/ui/common/map_marker.dart';
import 'package:pathfinder_albania/agent/ui/common/place_photo_placeholder.dart';
import 'package:pathfinder_albania/agent/ui/screens/trip_map/trip_map_colors.dart';
import 'package:pathfinder_albania/agent/utils/open_in_maps.dart';
import 'package:pathfinder_albania/agent/utils/polyline_decoder.dart';

/// Phases of the entrance choreography. Drives [_TripMapScreenState._phase].
///
/// `revealing` is the dominant phase: one continuous cascade where each step
/// animates the next polyline and the next marker drop on a shared timer,
/// across all days. `entering` is just the 50ms settle before the origin pin;
/// `finalFit` is the optional bounds re-fit after the cascade.
enum _AnimPhase {
  idle,
  entering,
  revealing,
  finalFit,
  complete,
  skipped,
}

/// Style ids for the single trip route line. The source carries the whole
/// route geometry; the layer reveals it progressively via `line-trim-offset`.
const String _kRouteSourceId = 'trip-route';
const String _kRouteLayerId = 'trip-route-line';

/// Full-screen interactive Mapbox map for a saved [Trip]. Markers are
/// numbered, photo circles keyed by day; the routed geometry comes from
/// `trip.routes`; cross-day gaps are bridged with straight segments of the
/// same single line.
///
/// The [Trip] is captured by value at push time; this screen does NOT
/// subscribe to `TripsBloc`. Refines that land while the map is open are
/// reflected only on next push (frozen post-push semantics).
class TripMapScreen extends StatefulWidget {
  const TripMapScreen({super.key, required this.trip});
  final Trip trip;

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen>
    with TickerProviderStateMixin {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointManager;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Live annotations keyed by stop id. Unlike the declarative Set<Marker> this
  // replaces, animation listeners mutate these objects in place (iconSize /
  // iconOpacity) and push each change through the annotation manager.
  final Map<String, PointAnnotation> _annotationByStopId = {};

  // One PNG per (day color, continuous index, photo url). Mapbox scales the
  // bitmap through `iconSize`, so there are no per-scale bitmap variants to
  // pre-render — one rasterization per stop is enough for every animation.
  final Map<String, Uint8List> _iconCache = {};
  final Map<String, TripStop> _mappableStopById = {};
  final Map<String, int> _stopDayNumberById = {};
  // Stop's 1-based index across the whole trip — drives the numbered badge.
  // Continuous (no per-day reset) so two markers never share a number.
  final Map<String, int> _continuousIndexByStopId = {};

  // The entire trip route as one concatenated position list, in global stop
  // order across all days.
  List<Position> _routePoints = const [];
  // Parallel to _mappableStops: _legEndFraction[i] is the fraction of the
  // route's total *length* that is drawn once the leg ending at stop i is
  // complete. _legEndFraction[0] == 0 (just the origin). `line-trim-offset`
  // works in length fractions rather than vertex indices, which is why the
  // per-leg vertex counts go through [cumulativeFractions] once at build time.
  List<double> _legEndFraction = const [];

  // On-screen marker diameter in dp. A touch tighter than the original
  // implicit ~80 dp so densely-packed stops overlap less.
  static const double _baseMarkerLogicalSize = 64;

  // How far from a stop a tap still counts as hitting it. Generous on purpose:
  // during the entrance the markers are scale-animating below their final size
  // and are easy to miss.
  static const double _tapSlopPixels = 44;

  List<TripStop> _mappableStops = const [];
  CoordinateBounds? _initialBounds;
  String? _selectedStopId;
  bool _isReady = false;
  bool _isSatellite = false;

  // Entrance animation state.
  _AnimPhase _phase = _AnimPhase.idle;
  bool _skipped = false;
  bool _userPanned = false;
  bool _disposed = false;
  // Guards [_installMapContent] against the repeat style-loaded events a
  // single style load can emit, and is cleared deliberately on a style swap.
  bool _contentInstalled = false;
  // The choreography runs once per screen, not once per style load.
  bool _entranceStarted = false;
  // At most one annotation update / one trim write in flight at a time — see
  // [_pushAnnotationState].
  bool _updateInFlight = false;
  bool _trimInFlight = false;
  final List<AnimationController> _activeControllers = [];
  final Map<AnimationController, VoidCallback> _activeListeners = {};
  final Set<String> _pulsingStopIds = {};

  bool _programmaticSheetAnimation = false;

  /// Built once and never rebuilt: [MapWidget] re-runs a viewport transition
  /// whenever this value is not identical to the previous one, which would
  /// fight our own camera animations on every setState.
  ViewportState? _viewport;

  /// True while the screen is mounted AND the entrance has not been skipped.
  /// The async sequencer checks this at every await boundary and bails on
  /// false so it never calls setState after dispose or after a skip.
  bool get _alive => mounted && !_skipped;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetSizeChanged);
    _buildMapData();
  }

  Future<void> _buildMapData() async {
    // Walk every stop once to populate identity/index lookups. The
    // continuous index spans the whole trip — no per-day reset — so the
    // numbered badge in each marker is unique across the map.
    final mapped = <TripStop>[];
    var continuousIndex = 0;
    for (final d in widget.trip.days) {
      for (final s in d.stops) {
        if (s.lat == null || s.lng == null) continue;
        continuousIndex += 1;
        mapped.add(s);
        _stopDayNumberById[s.id] = d.dayNumber;
        _mappableStopById[s.id] = s;
        _continuousIndexByStopId[s.id] = continuousIndex;
      }
    }
    _mappableStops = mapped;

    if (mapped.isEmpty) {
      if (mounted) setState(() => _isReady = true);
      return;
    }

    // Decode every unique stop photo once, with bounded concurrency so a long
    // itinerary can't fire dozens of decodes at once and spike memory/network.
    // Photo-less stops fall back to the icon variant.
    final uniquePhotoUrls = mapped
        .map((s) => s.photoUrl)
        .whereType<String>()
        .toSet();
    final photoByUrl = await mapBounded<String, ui.Image?>(
      uniquePhotoUrls,
      resolveStopPhoto,
      concurrency: 5,
    );
    if (!mounted) return;

    // One bitmap per (color, continuousIndex, photoUrl) combo. Scale is a
    // Mapbox `iconSize` multiplier at render time, so the drop-in and pulse
    // animations reuse this single bitmap rather than swapping between
    // pre-baked variants.
    for (final s in mapped) {
      final dayNumber = _stopDayNumberById[s.id]!;
      final color = colorForDayNumber(dayNumber);
      final n = _continuousIndexByStopId[s.id]!;
      final photo = s.photoUrl != null ? photoByUrl[s.photoUrl] : null;
      final key = _iconKey(color, n, s.photoUrl);
      if (_iconCache.containsKey(key)) continue;
      final icon = await buildPhotoMarkerBitmap(
        photo: photo,
        dayColor: color,
        stopNumber: n,
        logicalSize: _baseMarkerLogicalSize,
      );
      if (!mounted) return;
      _iconCache[key] = icon;
    }

    // Build the single continuous trip route: one line that chains every
    // mappable stop in global order, ignoring day boundaries. Real Directions
    // geometry is used per leg when available; legs without a route (cross-day
    // gaps, Directions failures) fall back to a straight line. Exactly one
    // polyline, one style, no per-day color, no offset.
    final routeByPair = <String, TripRoute>{
      for (final r in widget.trip.routes) '${r.fromStopId}->${r.toStopId}': r,
    };
    final pts = <Position>[
      Position(mapped.first.lng!, mapped.first.lat!),
    ];
    final legEnd = <int>[pts.length]; // legEnd[0] = 1 (origin only)
    for (var i = 1; i < mapped.length; i++) {
      final prev = mapped[i - 1];
      final next = mapped[i];
      final route = routeByPair['${prev.id}->${next.id}'];
      var leg = route != null
          ? decodeEncodedPolyline(route.encodedPolyline)
          : const <Position>[];
      if (leg.isEmpty) {
        leg = [
          Position(prev.lng!, prev.lat!),
          Position(next.lng!, next.lat!),
        ];
      }
      for (final p in leg) {
        final last = pts.last;
        // Skip a leading point that duplicates the current tail so legs join
        // seamlessly into one continuous line.
        if (p.lng != last.lng || p.lat != last.lat) {
          pts.add(p);
        }
      }
      legEnd.add(pts.length);
    }
    _routePoints = pts;
    // legEnd holds *counts* of visible vertices; the last visible index is
    // one less. Convert those to length fractions for `line-trim-offset`.
    final fractions = cumulativeFractions(pts);
    _legEndFraction = [
      for (final count in legEnd) fractions.isEmpty ? 0.0 : fractions[count - 1],
    ];

    if (mapped.length >= 2) _initialBounds = _computeBounds(mapped);
    _viewport = _initialViewport();

    if (mounted) setState(() => _isReady = true);
  }

  String _iconKey(Color color, int index, String? photoUrl) =>
      '${color.toARGB32().toRadixString(16)}_${index}_${photoUrl ?? '∅'}';

  Uint8List? _iconForStop(TripStop stop) {
    final dayNumber = _stopDayNumberById[stop.id];
    final n = _continuousIndexByStopId[stop.id];
    if (dayNumber == null || n == null) return null;
    return _iconCache[_iconKey(colorForDayNumber(dayNumber), n, stop.photoUrl)];
  }

  CoordinateBounds _computeBounds(List<TripStop> stops) {
    var minLat = stops.first.lat!;
    var maxLat = minLat;
    var minLng = stops.first.lng!;
    var maxLng = minLng;
    for (final s in stops) {
      if (s.lat! < minLat) minLat = s.lat!;
      if (s.lat! > maxLat) maxLat = s.lat!;
      if (s.lng! < minLng) minLng = s.lng!;
      if (s.lng! > maxLng) maxLng = s.lng!;
    }
    return CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: false,
    );
  }

  ViewportState _initialViewport() {
    if (_mappableStops.length == 1) {
      final s = _mappableStops.first;
      return CameraViewportState(
        center: Point(coordinates: Position(s.lng!, s.lat!)),
        zoom: 13,
      );
    }
    // Albania, wide. The real framing arrives via [_fitToBounds] as soon as
    // the style is up.
    return CameraViewportState(
      center: Point(coordinates: Position(19.8189, 41.3275)),
      zoom: 6,
    );
  }

  // ---- Map lifecycle --------------------------------------------------------

  void _onMapCreated(MapboxMap map) {
    _mapboxMap = map;
    // One map-level tap handler does all hit testing (see [_onMapTapped]) —
    // no separate annotation tap listener, so there is no ordering question
    // between "a marker was tapped" and "the background was tapped".
    map.addInteraction(
      TapInteraction.onMap(_onMapTapped),
      interactionID: 'trip_map_tap',
    );
    // Mapbox's logo and attribution stay: they are required by the Mapbox
    // terms of service. The scale bar and compass are noise on a trip
    // overview, so those go.
    unawaited(map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)));
    unawaited(map.compass.updateSettings(CompassSettings(enabled: false)));
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    unawaited(_installMapContent());
  }

  /// Everything the map draws hangs off [_onStyleLoaded]. If the style itself
  /// fails — almost always a missing or rejected MAPBOX_ACCESS_TOKEN — the map
  /// stays blank and no markers appear, which is silent without this.
  void _onMapLoadError(MapLoadingErrorEventData data) {
    debugPrint('Mapbox load error (${data.type}): ${data.message}');
  }

  /// Installs everything the map draws: basemap config, the route source and
  /// layer, and the stop annotations.
  ///
  /// Called on every style load, NOT from [_onMapCreated] — swapping styleUri
  /// (the normal↔satellite toggle) reloads the style wholesale and drops every
  /// custom source, layer and annotation with it. Idempotent within one style
  /// load via [_contentInstalled].
  Future<void> _installMapContent() async {
    final map = _mapboxMap;
    if (map == null || !mounted || _mappableStops.isEmpty) return;
    if (_contentInstalled) return;
    _contentInstalled = true;

    final style = map.style;
    try {
      await style.setStyleImportConfigProperties(
        kBasemapImportId,
        kBasemapConfig,
      );
    } catch (e) {
      // A style that doesn't expose these config keys just keeps its defaults.
      debugPrint('Mapbox basemap config skipped: $e');
    }
    if (!mounted) return;

    // Either the entrance hasn't run yet, or we're re-installing after a style
    // swap that wiped the map. `atRest` decides whether content comes back
    // mid-choreography or fully drawn.
    final atRest =
        _phase == _AnimPhase.complete || _phase == _AnimPhase.skipped;

    if (_routePoints.length >= 2) {
      await style.addSource(
        GeoJsonSource(
          id: _kRouteSourceId,
          // REQUIRED for `line-trim-offset` to have any effect — without line
          // metrics the trim is silently ignored and the whole route shows at
          // once.
          lineMetrics: true,
          data: json.encode(<String, dynamic>{
            'type': 'Feature',
            'properties': <String, dynamic>{},
            'geometry': LineString(coordinates: _routePoints).toJson(),
          }),
        ),
      );
      if (!mounted) return;
      await style.addLayer(
        LineLayer(
          id: _kRouteLayerId,
          sourceId: _kRouteSourceId,
          slot: LayerSlot.TOP,
          lineColor: $styles.colors.accent1.toARGB32(),
          lineWidth: 4.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
          lineEmissiveStrength: 1.0,
          // [trim-start, trim-end] is painted with `line-trim-color`, which is
          // transparent by default. So [0,1] hides the whole line and [1,1]
          // shows it end to end; the cascade sweeps trim-start from 0 to 1.
          lineTrimOffset: atRest
              ? const <double?>[1.0, 1.0]
              : const <double?>[0.0, 1.0],
        ),
      );
      if (!mounted) return;
    }

    final manager = await map.annotations.createPointAnnotationManager();
    if (!mounted) return;
    _pointManager = manager;
    // Mapbox hides symbols that collide with one another. Without these two,
     // stops that sit close together silently disappear from the map.
    await manager.setIconAllowOverlap(true);
    await manager.setIconIgnorePlacement(true);
    if (!mounted) return;

    final pending = <TripStop>[];
    final options = <PointAnnotationOptions>[];
    for (final s in _mappableStops) {
      final icon = _iconForStop(s);
      if (icon == null) continue;
      pending.add(s);
      options.add(
        buildStopAnnotationOptions(
          position: Position(s.lng!, s.lat!),
          icon: icon,
          scale: atRest ? 1.0 : 0.30,
          opacity: atRest ? 1.0 : 0.0,
        ),
      );
    }
    final created = await manager.createMulti(options);
    if (!mounted) return;

    _annotationByStopId.clear();
    for (var i = 0; i < created.length && i < pending.length; i++) {
      final a = created[i];
      if (a == null) continue;
      _annotationByStopId[pending[i].id] = a;
    }

    if (!_entranceStarted) {
      _entranceStarted = true;
      // Deliberately not awaited: flyTo resolves only when its animation ends,
      // and the cascade is meant to run *over* the camera move, not after it.
      unawaited(_fitToBounds());
      if (!_alive) return;
      // Kick off the entrance choreography. The sequencer tolerates the camera
      // fit still being in flight — its first phase is just a 50ms settle
      // before the first pin.
      unawaited(_runEntranceAnimation());
    }
  }

  /// Chrome that overlays the map, as camera padding. Mapbox takes this per
  /// camera call rather than as a widget-level property, which is why every
  /// camera move here threads it through.
  /// - Top: status bar + ~56dp transparent header.
  /// - Bottom: half the screen when a marker is selected (so the tapped marker
  ///   centres in the upper half above the sheet); a small home-indicator pad
  ///   otherwise.
  MbxEdgeInsets _chromePadding() {
    final mq = MediaQuery.of(context);
    return MbxEdgeInsets(
      top: mq.padding.top + 56,
      left: 0,
      bottom: _selectedStopId != null
          ? mq.size.height * _sheetMaxSize + mq.padding.bottom
          : mq.padding.bottom + 8,
      right: 0,
    );
  }

  Future<void> _fitToBounds({bool animate = true}) async {
    final map = _mapboxMap;
    if (map == null || !mounted) return;
    final chrome = _chromePadding();
    CameraOptions camera;
    if (_mappableStops.length >= 2 && _initialBounds != null) {
      // Just enough inset to keep the outermost markers off the AppHeader and
      // the sheet peek: half the marker diameter plus a small visual gap, on
      // top of the chrome insets.
      const fitPadding = _baseMarkerLogicalSize / 2 + 12;
      camera = await map.cameraForCoordinateBounds(
        _initialBounds!,
        MbxEdgeInsets(
          top: chrome.top + fitPadding,
          left: chrome.left + fitPadding,
          bottom: chrome.bottom + fitPadding,
          right: chrome.right + fitPadding,
        ),
        null,
        null,
        null,
        null,
      );
      if (!mounted) return;
    } else if (_mappableStops.length == 1) {
      final s = _mappableStops.first;
      camera = CameraOptions(
        center: Point(coordinates: Position(s.lng!, s.lat!)),
        zoom: 13,
        padding: chrome,
      );
    } else {
      return;
    }
    if (animate) {
      await map
          .flyTo(camera, MapAnimationOptions(duration: 900))
          .catchError((_) {});
    } else {
      await map.setCamera(camera).catchError((_) {});
    }
  }

  void _onMapScrolled(MapContentGestureContext _) {
    // Only user gestures reach this listener — our own flyTo/setCamera calls
    // do not — so there's no in-flight flag needed to disambiguate the two.
    // Once the user has panned we never auto-fit again for
    // the lifetime of this screen: respecting their intent beats re-centering
    // on them.
    _userPanned = true;
  }

  void _toggleMapType() {
    final map = _mapboxMap;
    if (map == null) return;
    // Loading a new styleUri resets the style, taking the route layer and
    // every annotation with it. Land the choreography first so the re-install
    // rebuilds straight into the final state instead of resuming against
    // annotation objects that no longer exist.
    if (_phase != _AnimPhase.complete && _phase != _AnimPhase.skipped) {
      _skipAnimation();
    }
    setState(() => _isSatellite = !_isSatellite);
    _contentInstalled = false;
    final stale = _pointManager;
    _pointManager = null;
    _annotationByStopId.clear();
    if (stale != null) {
      unawaited(
        map.annotations.removeAnnotationManager(stale).catchError((_) {}),
      );
    }
    unawaited(
      map
          .loadStyleURI(_isSatellite ? kMapboxSatelliteStyle : kMapboxNormalStyle)
          .catchError((_) {}),
    );
  }

  /// The details sheet's max fractional size: half the screen on phones,
  /// capped at 480 logical px on tall web/desktop windows so the sheet
  /// doesn't swallow the map. Shared by the sheet itself, the programmatic
  /// open animation, and the map's bottom padding — keep all three in sync.
  double get _sheetMaxSize {
    final h = MediaQuery.of(context).size.height;
    return math.min(0.5, 480 / h);
  }

  void _onMarkerTapped(String stopId) {
    final s = _mappableStopById[stopId];
    if (s == null) return;
    // A tap on a stop is an unambiguous "I want to interact" signal — if the
    // entrance animation is still running, skip it so the camera animate +
    // pulse land on a fully-rendered final map.
    if (_phase != _AnimPhase.complete && _phase != _AnimPhase.skipped) {
      _skipAnimation();
    }
    setState(() => _selectedStopId = stopId);

    _programmaticSheetAnimation = true;
    _sheetController
        .animateTo(
          _sheetMaxSize,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        )
        .whenComplete(() => _programmaticSheetAnimation = false);

    // Padding rides along with the camera options, so there's no need to
    // defer a frame waiting for a widget-level padding change to reach the
    // platform view.
    final map = _mapboxMap;
    if (map != null) {
      unawaited(
        map
            .flyTo(
              CameraOptions(
                center: Point(coordinates: Position(s.lng!, s.lat!)),
                zoom: 16,
                padding: _chromePadding(),
              ),
              MapAnimationOptions(duration: 600),
            )
            .catchError((_) {}),
      );
    }
    // Pulse runs concurrently with the camera animation. Fire-and-forget; the
    // method itself guards against re-entry on the same stop.
    _animatePulse(stopId);
  }

  /// Listens to [_sheetController] and treats a drag-down to (near-)zero as
  /// a user-initiated dismiss. Ignores frames during our own programmatic
  /// animateTo so opening the sheet doesn't immediately re-trigger close.
  void _onSheetSizeChanged() {
    if (_programmaticSheetAnimation) return;
    if (_selectedStopId == null) return;
    if (!_sheetController.isAttached) return;
    if (_sheetController.size <= 0.02) {
      _dismissSheet();
    }
  }

  /// Every tap on the map surface lands here, marker taps included: the hit
  /// test below resolves them, rather than a separate annotation tap listener
  /// whose ordering against this one would be undefined.
  ///
  /// A tap within [_tapSlopPixels] of a stop selects it. Otherwise it either
  /// dismisses an open sheet (keeping the camera where the user left it) or
  /// skips the entrance choreography.
  Future<void> _onMapTapped(MapContentGestureContext context) async {
    final nearestId = await _findNearestStopWithinPixels(
      context.touchPosition,
      _tapSlopPixels,
    );
    if (!mounted) return;
    if (nearestId != null) {
      _onMarkerTapped(nearestId);
      return;
    }
    if (_selectedStopId != null) {
      await _dismissSheet();
      return;
    }
    if (_phase != _AnimPhase.complete && _phase != _AnimPhase.skipped) {
      _skipAnimation();
    }
  }

  Future<String?> _findNearestStopWithinPixels(
    ScreenCoordinate tap,
    double maxPixels,
  ) async {
    final map = _mapboxMap;
    if (map == null || _mappableStops.isEmpty) return null;
    // One batched round trip for every stop, rather than one call per stop.
    final coords = await map.pixelsForCoordinates([
      for (final s in _mappableStops)
        Point(coordinates: Position(s.lng!, s.lat!)),
    ]);
    if (!mounted) return null;
    String? bestId;
    var bestD2 = double.infinity;
    for (var i = 0; i < _mappableStops.length && i < coords.length; i++) {
      final p = coords[i];
      if (p == null) continue;
      final dx = p.x - tap.x;
      final dy = p.y - tap.y;
      final d2 = dx * dx + dy * dy;
      if (d2 < bestD2) {
        bestD2 = d2;
        bestId = _mappableStops[i].id;
      }
    }
    if (bestId == null) return null;
    // ScreenCoordinate is in logical pixels on both platforms — the plugin
    // normalises by device density — so no devicePixelRatio scaling here.
    return math.sqrt(bestD2) <= maxPixels ? bestId : null;
  }

  Future<void> _dismissSheet() async {
    _programmaticSheetAnimation = true;
    if (_sheetController.isAttached && _sheetController.size > 0.0) {
      await _sheetController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
    _programmaticSheetAnimation = false;
    if (!mounted) return;
    setState(() => _selectedStopId = null);
  }

  // ---- Map content writes ---------------------------------------------------

  /// Pushes a marker's animated state to the map.
  ///
  /// Annotation updates are async platform calls while the animation ticks at
  /// display refresh rate, so intermediate frames are dropped whenever a write
  /// is still in flight — invisible at 60fps, and it keeps the channel from
  /// backing up. [force] bypasses the guard for the final, must-land frame.
  void _pushAnnotationState(
    String stopId, {
    required double scale,
    required double opacity,
    bool force = false,
  }) {
    final manager = _pointManager;
    final annotation = _annotationByStopId[stopId];
    if (manager == null || annotation == null) return;
    annotation.iconSize = kStopMarkerBaseIconSize * scale;
    annotation.iconOpacity = opacity.clamp(0.0, 1.0);
    if (_updateInFlight && !force) return;
    _updateInFlight = true;
    unawaited(
      manager
          .update(annotation)
          .catchError((_) {})
          .whenComplete(() => _updateInFlight = false),
    );
  }

  /// Reveals the route up to [fraction] of its total length. Same in-flight
  /// throttle as [_pushAnnotationState].
  void _pushRouteTrim(double fraction, {bool force = false}) {
    final map = _mapboxMap;
    if (map == null || _routePoints.length < 2) return;
    if (_trimInFlight && !force) return;
    final f = fraction.clamp(0.0, 1.0);
    _trimInFlight = true;
    final trim = <double>[f, 1.0];
    unawaited(
      map.style
          .setStyleLayerProperty(_kRouteLayerId, 'line-trim-offset', trim)
          .catchError((_) {})
          .whenComplete(() => _trimInFlight = false),
    );
  }

  // ---- Entrance animation choreography --------------------------------------
  //
  // One continuous cascade across all geo-located stops, in order, regardless
  // of day. There is exactly ONE trip route line — never per-day colored,
  // never offset. Day grouping shows up only in the marker rim color and
  // badge — not in the line style or the animation timing.
  //
  // Per step (i ≥ 1) a single timer drives both halves (see [_animateLeg]):
  //   * t in [0, 0.6): the route line extends from stop i-1 toward stop i
  //     (easeOut over that leg's share of the route length).
  //   * t in [0.6, 1]: the moment the segment finishes, marker i drops in —
  //     easeOut overshoot to 1.20 then easeIn settle to 1.00.
  //   The next step doesn't begin until the timer completes. No intra-trip
  //   stagger and no day-boundary pause.
  //
  // The origin marker (i = 0) has no incoming segment; it uses the legacy
  // growth-throughout tween so the screen isn't empty before the first pin
  // appears. See [_animateMarkerDropIn] (`isOrigin` parameter).
  //
  // [_stepDurationFor] caps D against stop count so long trips stay under ~8s.
  //
  // Other related timings:
  //   * Initial settle:   50ms (one empty frame before the first pin)
  //   * Final-fit hold:   400ms (only if user hasn't panned)
  //   * Pulse (on tap):   600ms, scale 1.0 → 1.4 (easeOut) → 1.0 (elasticOut)

  /// Per-step duration for the cascade. 450ms feels deliberate on a typical
  /// 6–12 stop trip; for unusually long itineraries the per-step time shrinks
  /// to keep total runtime around 4–5s with a 280ms floor that preserves the
  /// bounce.
  Duration _stepDurationFor(int stopCount) {
    if (stopCount <= 6) return const Duration(milliseconds: 450);
    final scaled = (4500 / stopCount).round();
    return Duration(milliseconds: scaled.clamp(280, 450));
  }

  /// Async sequencer that drives the entrance choreography. Started from
  /// [_installMapContent] after the initial [_fitToBounds]. Bails at every
  /// await boundary if the screen is unmounted or the user tapped to skip.
  Future<void> _runEntranceAnimation() async {
    if (!_alive || _mappableStops.isEmpty) return;
    setState(() => _phase = _AnimPhase.entering);
    // Settle so the first frame paints the empty map before the first pin.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_alive) return;

    setState(() => _phase = _AnimPhase.revealing);

    final stepDur = _stepDurationFor(_mappableStops.length);

    // Origin pin: drops alone, no incoming segment. Uses the legacy growth
    // tween.
    await _animateMarkerDropIn(
      _mappableStops.first,
      duration: stepDur,
      isOrigin: true,
    );
    if (!_alive) return;

    // Cascade: each step extends the single trip line from stop i-1 toward
    // stop i, then drops marker i — both driven by one shared timer per step.
    // No stagger between steps, no day-boundary pause. _legEndFraction handles
    // real routes, cross-day gaps, and straight-line fallbacks uniformly,
    // including gaps where an intermediate day has zero geo-located stops.
    for (var i = 1; i < _mappableStops.length; i++) {
      if (!_alive) return;
      await _animateLeg(i, stepDur);
      if (!_alive) return;
    }

    if (!_alive) return;
    setState(() => _phase = _AnimPhase.finalFit);
    if (!_userPanned) {
      // Same as the initial fit: start the camera move and hold briefly rather
      // than blocking on the whole flight.
      unawaited(_fitToBounds());
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    if (!_alive) return;
    setState(() => _phase = _AnimPhase.complete);
  }

  /// Animates the origin pin dropping in. The origin has no incoming segment,
  /// so it fades in over the first 30% and scales 0.30 → 1.20 → 1.00 across
  /// the full timer (78% easeOut overshoot, 22% easeIn settle) — the screen
  /// isn't empty while the user waits for the first visual. Every subsequent
  /// pin drops via [_animateLeg].
  Future<void> _animateMarkerDropIn(
    TripStop stop, {
    Duration duration = const Duration(milliseconds: 450),
    bool isOrigin = false,
  }) async {
    if (!_alive) return;
    final completer = Completer<void>();

    final controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    final scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.30, end: 1.20)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 78,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.20, end: 1.00)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 22,
      ),
    ]).animate(controller);

    void listener() {
      if (!mounted) return;
      final t = controller.value;
      _pushAnnotationState(
        stop.id,
        scale: scaleAnim.value,
        opacity: (t / 0.30).clamp(0.0, 1.0),
      );
    }

    _registerActive(controller, listener);

    controller.forward().whenComplete(() {
      _disposeActive(controller);
      if (mounted) {
        // Snap to the exact final visuals so per-frame throttling can't leave
        // an off-scale bitmap behind.
        _pushAnnotationState(stop.id, scale: 1.0, opacity: 1.0, force: true);
      }
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  /// Animates one cascade step on a single shared timer: extends the one trip
  /// line from stop [stepIndex]-1 toward stop [stepIndex], then drops that
  /// stop's marker the instant the segment finishes.
  ///
  /// `t in [0, drawFraction)` grows the line over this leg's share of the
  /// route length (easeOut); `t in [drawFraction, 1]` drops marker
  /// [stepIndex] (easeOut overshoot to 1.20, easeIn settle to 1.00, opacity
  /// fading in as it lands). The already-drawn prefix stays because
  /// `line-trim-offset` always measures from the start of the line.
  ///
  /// The final frame forces the exact leg-end trim and the marker's resting
  /// scale, so the waited state and a skip both land on the same visual.
  Future<void> _animateLeg(int stepIndex, Duration duration) async {
    if (!_alive) return;
    final stop = _mappableStops[stepIndex];
    final startFraction = _legEndFraction[stepIndex - 1];
    final endFraction = _legEndFraction[stepIndex];

    const drawFraction = 0.6;
    final completer = Completer<void>();
    final controller = AnimationController(vsync: this, duration: duration);
    final dropScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.30, end: 1.20)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.20, end: 1.00)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(controller);

    void listener() {
      if (!mounted) return;
      final t = controller.value;

      // --- Route line: extend from stop i-1 toward stop i over
      //     [0, drawFraction).
      if (endFraction > startFraction) {
        final drawT =
            Curves.easeOut.transform((t / drawFraction).clamp(0.0, 1.0));
        _pushRouteTrim(
          startFraction + (endFraction - startFraction) * drawT,
        );
      }

      // --- Marker i: drops the moment the segment finishes, over
      //     [drawFraction, 1].
      final dropT =
          ((t - drawFraction) / (1 - drawFraction)).clamp(0.0, 1.0);
      _pushAnnotationState(
        stop.id,
        scale: dropT <= 0.0 ? 0.30 : dropScale.value,
        opacity: (dropT / 0.20).clamp(0.0, 1.0),
      );
    }

    _registerActive(controller, listener);

    controller.forward().whenComplete(() {
      _disposeActive(controller);
      if (mounted) {
        _pushRouteTrim(endFraction, force: true);
        _pushAnnotationState(stop.id, scale: 1.0, opacity: 1.0, force: true);
      }
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  /// Pulses a marker scale 1.0 → 1.4 → 1.0 over 600ms. Triggered when the
  /// user taps a stop. No-op if the same stop is already pulsing.
  Future<void> _animatePulse(String stopId) async {
    if (!mounted) return;
    if (_pulsingStopIds.contains(stopId)) return;
    if (!_annotationByStopId.containsKey(stopId)) return;
    _pulsingStopIds.add(stopId);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // The elastic tail overshoots past 1.0; with `iconSize` being a plain
    // double there's nothing to clamp it to, so the bounce reads in full.
    final scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(controller);

    void listener() {
      if (!mounted) return;
      _pushAnnotationState(stopId, scale: scaleAnim.value, opacity: 1.0);
    }

    _registerActive(controller, listener);

    await controller.forward().whenComplete(() {
      _disposeActive(controller);
      _pulsingStopIds.remove(stopId);
      if (!mounted) return;
      _pushAnnotationState(stopId, scale: 1.0, opacity: 1.0, force: true);
    });
  }

  /// Cancels every in-flight controller and installs the final map state.
  /// Idempotent for terminal phases.
  void _skipAnimation() {
    if (_phase == _AnimPhase.complete || _phase == _AnimPhase.skipped) return;
    _skipped = true;
    // Snapshot then clear so whenComplete callbacks see an empty list and
    // skip their own dispose path.
    final toDispose = List<AnimationController>.of(_activeControllers);
    _activeControllers.clear();
    for (final c in toDispose) {
      final l = _activeListeners.remove(c);
      if (l != null) c.removeListener(l);
      c.stop(canceled: true);
      c.dispose();
    }
    _pulsingStopIds.clear();
    setState(() => _phase = _AnimPhase.skipped);
    _snapToFinalMapState();
  }

  /// Full route revealed, every marker at rest.
  void _snapToFinalMapState() {
    final manager = _pointManager;
    if (manager != null) {
      for (final a in _annotationByStopId.values) {
        a.iconSize = kStopMarkerBaseIconSize;
        a.iconOpacity = 1.0;
        unawaited(manager.update(a).catchError((_) {}));
      }
    }
    _pushRouteTrim(1.0, force: true);
  }

  void _registerActive(AnimationController c, VoidCallback l) {
    c.addListener(l);
    _activeControllers.add(c);
    _activeListeners[c] = l;
  }

  void _disposeActive(AnimationController c) {
    if (_disposed) return;
    if (_activeControllers.remove(c)) {
      final l = _activeListeners.remove(c);
      if (l != null) c.removeListener(l);
      c.dispose();
    }
  }

  // ---- end of animation choreography ---------------------------------------

  TripStop? get _selectedStop =>
      _selectedStopId == null ? null : _mappableStopById[_selectedStopId];

  Color? get _selectedStopDayColor {
    final id = _selectedStopId;
    if (id == null) return null;
    final dn = _stopDayNumberById[id];
    if (dn == null) return null;
    return colorForDayNumber(dn);
  }

  @override
  void dispose() {
    // Mark disposed FIRST so any pending whenComplete callbacks short-circuit
    // their dispose path and don't try to dispose an already-disposed
    // controller (which throws an assertion).
    _disposed = true;
    for (final c in List<AnimationController>.of(_activeControllers)) {
      final l = _activeListeners.remove(c);
      if (l != null) c.removeListener(l);
      c.dispose();
    }
    _activeControllers.clear();
    _activeListeners.clear();
    // MapWidget disposes the MapboxMap it created; dropping the reference is
    // enough here.
    _mapboxMap = null;
    _pointManager = null;
    _sheetController.removeListener(_onSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mapbox ships iOS and Android only. Render the empty state rather than
    // letting the platform view throw a MissingPluginException on web/desktop.
    if (kIsWeb || PlatformInfo.isDesktop) {
      return _EmptyTripMap(
        title: widget.trip.title,
        message: 'The interactive map is available in the mobile app',
        detail: 'Open this trip on iOS or Android to explore it on the map.',
      );
    }

    if (!_isReady) {
      return ColoredBox(
        color: $styles.colors.black,
        child: Stack(
          children: [
            const Center(child: CircularProgressIndicator()),
            const Align(
              alignment: Alignment.topCenter,
              child: AppHeader(isTransparent: true),
            ),
          ],
        ),
      );
    }

    if (_mappableStops.isEmpty) {
      return _EmptyTripMap(title: widget.trip.title);
    }

    final mq = MediaQuery.of(context);
    final mapTopInset = mq.padding.top + 56;

    return ColoredBox(
      color: $styles.colors.black,
      child: Stack(
        children: [
          // Hero tag matches the saved-itinerary thumbnail in the buddy chat
          // bubble, so tapping the thumbnail morphs into the full map.
          Hero(
            tag: 'itinerary_map_${widget.trip.id}',
            child: MapWidget(
              key: const ValueKey('trip_map'),
              styleUri: _isSatellite
                  ? kMapboxSatelliteStyle
                  : kMapboxNormalStyle,
              viewport: _viewport,
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: _onStyleLoaded,
              onMapLoadErrorListener: _onMapLoadError,
              onScrollListener: _onMapScrolled,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: const AppHeader(isTransparent: true),
          ),
          Positioned(
            top: mapTopInset + 8,
            right: 12,
            child: _MapTypeToggle(
              isSatellite: _isSatellite,
              onToggle: _toggleMapType,
            ),
          ),
          // The Align/SizedBox wrapper is unconditional (never toggled by
          // _selectedStopId) so the sheet's inner Scrollable keeps the same
          // tree location across state changes — see the comment on `stop:`.
          // It caps the sheet's width on wide windows.
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: math.min(mq.size.width, $styles.sizes.maxContentWidth2),
              child: DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.0,
                minChildSize: 0.0,
                maxChildSize: _sheetMaxSize,
                snap: true,
                snapSizes: [0.0, _sheetMaxSize],
                builder: (ctx, scrollCtrl) => _StopDetailsSheet(
                  // Nullable on purpose. The Scrollable must stay at the same
                  // tree location across null↔stop transitions; swapping widget
                  // types here would detach the ScrollPosition and (via the
                  // controller's onPositionDetached hook) kill any in-flight
                  // _sheetController.animateTo, leaving the sheet stuck at 0.
                  stop: _selectedStop,
                  dayColor: _selectedStopDayColor ?? Colors.grey,
                  scrollCtrl: scrollCtrl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small circular button at the top-right of the map that toggles the base
/// style between Mapbox Standard and Standard Satellite. The icon reflects the
/// *target* state (satellite glyph in normal mode, map glyph in satellite
/// mode) so the user knows what they're switching to.
class _MapTypeToggle extends StatelessWidget {
  const _MapTypeToggle({required this.isSatellite, required this.onToggle});
  final bool isSatellite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Material(
        color: $styles.colors.black.withValues(alpha: 0.85),
        elevation: 4,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onToggle,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              isSatellite ? Icons.map_outlined : Icons.satellite_alt_outlined,
              color: $styles.colors.offWhite,
              size: 22,
              semanticLabel: isSatellite
                  ? 'Switch to normal map'
                  : 'Switch to satellite view',
            ),
          ),
        ),
      ),
    );
  }
}


/// Half-screen bottom-sheet card showing details for the tapped marker:
/// a (currently single-photo) carousel, name, address, time, and an
/// "Open in Maps" icon. The parent screen drives open/close via
/// [_TripMapScreenState._sheetController].
class _StopDetailsSheet extends StatelessWidget {
  const _StopDetailsSheet({
    required this.stop,
    required this.dayColor,
    required this.scrollCtrl,
  });

  /// Nullable so the same widget can stay mounted across null↔stop
  /// transitions of the parent sheet — see the builder call site.
  final TripStop? stop;
  final Color dayColor;
  final ScrollController scrollCtrl;

  Future<void> _openInMaps(TripStop s) async {
    await openInMaps(name: s.name, lat: s.lat, lng: s.lng);
  }

  String? _timeLabel(TripStop s) {
    final start = s.arrivalTime ?? '';
    final end = s.endTime ?? '';
    if (start.isNotEmpty && end.isNotEmpty) return '$start – $end';
    if (start.isNotEmpty) return start;
    if (end.isNotEmpty) return end;
    final mins = s.durationMinutes;
    if (mins != null && mins > 0) return '$mins min';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = stop;
    return Container(
      decoration: BoxDecoration(
        color: s == null ? Colors.transparent : $styles.colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: s == null
            ? null
            : const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 18,
                  offset: Offset(0, -4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SingleChildScrollView(
          controller: scrollCtrl,
          physics: const ClampingScrollPhysics(),
          child: s == null
              ? const SizedBox.shrink()
              : _buildContent(context, s),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripStop s) {
    final formatted = s.formattedAddress;
    final addrFallback = s.address;
    final addr = (formatted != null && formatted.isNotEmpty)
        ? formatted
        : (addrFallback != null && addrFallback.isNotEmpty
              ? addrFallback
              : null);
    final timeLabel = _timeLabel(s);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: $styles.colors.greyMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 16 / 10,
          child: _StopPhotoStack(
            photos: s.effectivePhotos,
            onOpenMaps: () => _openInMaps(s),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            $styles.insets.sm,
            $styles.insets.sm,
            $styles.insets.sm,
            $styles.insets.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.name,
                style: $styles.text.h4.copyWith(
                  color: $styles.colors.offWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (addr != null) ...[
                Gap($styles.insets.xs),
                _StopDetailRow(icon: Icons.place_outlined, text: addr),
              ],
              if (timeLabel != null) ...[
                Gap($styles.insets.xxs),
                _StopDetailRow(icon: Icons.schedule, text: timeLabel),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          bottom: true,
          child: SizedBox(height: $styles.insets.xs),
        ),
      ],
    );
  }
}

/// Multi-photo region for the stop sheet. Layout adapts to photo count:
///   0 → placeholder + open-in-maps badge
///   1 → single hero (no thumbs, no swipe, no dots)
///   2 → hero left ~68%, single thumb right ~32%, 2 dots
///   3 → hero left ~68%, two thumbs stacked right ~32%, 3 dots
///
/// The thumb layout is a circular "deck": top thumb is photos[(hero+1)%n],
/// bottom is photos[(hero+2)%n]. Tapping the top thumb advances by one;
/// tapping the bottom skips ahead two (cycles back around). Swiping the
/// hero left/right rotates the same way. The displaced hero ends up at the
/// back of the stack — what felt right for the "deck-of-cards" feel.
class _StopPhotoStack extends StatefulWidget {
  const _StopPhotoStack({
    required this.photos,
    required this.onOpenMaps,
  });

  /// Already-capped list (1–3 entries when called from the sheet via
  /// `effectivePhotos`). Pass an empty list to render the placeholder.
  final List<String> photos;
  final VoidCallback onOpenMaps;

  @override
  State<_StopPhotoStack> createState() => _StopPhotoStackState();
}

class _StopPhotoStackState extends State<_StopPhotoStack> {
  int _heroIndex = 0;

  @override
  void didUpdateWidget(covariant _StopPhotoStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Photos list changed (different stop selected) → reset to the primary.
    // Same-content rebuilds (parent setState that doesn't change urls) keep
    // the user's current hero selection.
    if (!_sameUrls(oldWidget.photos, widget.photos)) {
      _heroIndex = 0;
    }
  }

  static bool _sameUrls(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _advance() {
    final n = widget.photos.length;
    if (n <= 1) return;
    setState(() => _heroIndex = (_heroIndex + 1) % n);
  }

  void _reverse() {
    final n = widget.photos.length;
    if (n <= 1) return;
    setState(() => _heroIndex = (_heroIndex - 1 + n) % n);
  }

  void _jumpTo(int absIndex) {
    if (absIndex == _heroIndex) return;
    setState(() => _heroIndex = absIndex);
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;

    if (photos.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const PlacePhotoPlaceholder(),
          _StopOpenMapsBadge(onTap: widget.onOpenMaps),
        ],
      );
    }

    if (photos.length == 1) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _StopHeroSlot(
            url: photos[0],
            onAdvance: null,
            onReverse: null,
          ),
          _StopOpenMapsBadge(onTap: widget.onOpenMaps),
        ],
      );
    }

    final n = photos.length;
    final topIdx = (_heroIndex + 1) % n;
    final bottomIdx = n == 3 ? (_heroIndex + 2) % n : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                flex: 68,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _StopHeroSlot(
                      url: photos[_heroIndex],
                      onAdvance: _advance,
                      onReverse: _reverse,
                    ),
                    _StopOpenMapsBadge(onTap: widget.onOpenMaps),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 32,
                child: _StopThumbColumn(
                  topUrl: photos[topIdx],
                  bottomUrl: bottomIdx != null ? photos[bottomIdx] : null,
                  onTapTop: _advance,
                  onTapBottom:
                      bottomIdx != null ? () => _jumpTo(bottomIdx) : null,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: _StopDotIndicator(count: n, activeIndex: _heroIndex),
        ),
      ],
    );
  }
}

/// Hero photo with a horizontal-drag swap gesture. Swipe-left advances,
/// swipe-right reverses. Vertical drags fall through to the parent
/// DraggableScrollableSheet so collapsing the sheet still works.
class _StopHeroSlot extends StatelessWidget {
  const _StopHeroSlot({
    required this.url,
    required this.onAdvance,
    required this.onReverse,
  });

  final String url;
  final VoidCallback? onAdvance;
  final VoidCallback? onReverse;

  // Pixels-per-second. Below this, treat the drag as accidental and ignore.
  static const double _swipeVelocityThreshold = 280.0;

  void _handleDragEnd(DragEndDetails d) {
    final vx = d.primaryVelocity ?? 0.0;
    if (vx <= -_swipeVelocityThreshold) {
      onAdvance?.call();
    } else if (vx >= _swipeVelocityThreshold) {
      onReverse?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _handleDragEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular($styles.corners.md),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
              child: child,
            ),
          ),
          child: _StopPhotoTile(
            key: ValueKey<String>(url),
            url: url,
            cacheWidth: 1000,
          ),
        ),
      ),
    );
  }
}

/// Right-side thumb column. Renders 1 thumb when [bottomUrl] is null
/// (2-photo case) or 2 thumbs stacked vertically (3-photo case).
class _StopThumbColumn extends StatelessWidget {
  const _StopThumbColumn({
    required this.topUrl,
    required this.bottomUrl,
    required this.onTapTop,
    required this.onTapBottom,
  });

  final String topUrl;
  final String? bottomUrl;
  final VoidCallback? onTapTop;
  final VoidCallback? onTapBottom;

  @override
  Widget build(BuildContext context) {
    final bottom = bottomUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _StopThumbTile(url: topUrl, onTap: onTapTop)),
        if (bottom != null) const SizedBox(height: 6),
        if (bottom != null)
          Expanded(child: _StopThumbTile(url: bottom, onTap: onTapBottom)),
      ],
    );
  }
}

class _StopThumbTile extends StatelessWidget {
  const _StopThumbTile({required this.url, required this.onTap});
  final String url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular($styles.corners.sm);
    // Plain GestureDetector (not Material/InkWell) so taps don't paint a
    // splash/highlight on top of the photo — the cross-fade swap is feedback
    // enough.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: radius,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          child: _StopPhotoTile(
            key: ValueKey<String>(url),
            url: url,
            cacheWidth: 240,
          ),
        ),
      ),
    );
  }
}

class _StopPhotoTile extends StatelessWidget {
  const _StopPhotoTile({
    super.key,
    required this.url,
    required this.cacheWidth,
  });

  final String url;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand pins the image to the parent's full bounds. Without it
    // the image takes its decoded natural size inside AnimatedSwitcher's
    // loose-fit Stack, so swapping to a portrait photo would shrink the
    // hero box and a wide one would let it bulge — visually janky.
    return SizedBox.expand(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        memCacheWidth: cacheWidth,
        placeholder: (_, _) => const PlacePhotoPlaceholder(),
        errorWidget: (_, _, _) => const PlacePhotoPlaceholder(),
      ),
    );
  }
}

/// Top-right round badge that opens the place in the device's maps app.
/// Returns a `Positioned` so it must be placed inside a Stack.
class _StopOpenMapsBadge extends StatelessWidget {
  const _StopOpenMapsBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: $styles.colors.black.withValues(alpha: 0.78),
        elevation: 2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.open_in_new,
              size: 18,
              color: $styles.colors.offWhite,
              semanticLabel: 'Open in Maps',
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom dot indicator. Active dot is wider (14×6) and accent1 (orange);
/// inactive dots are 6×6 in greyMedium @ 55%. Width animates so the swap
/// reads as one motion with the hero cross-fade.
class _StopDotIndicator extends StatelessWidget {
  const _StopDotIndicator({required this.count, required this.activeIndex});
  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) _StopDot(active: i == activeIndex),
      ],
    );
  }
}

class _StopDot extends StatelessWidget {
  const _StopDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 6,
      width: active ? 14 : 6,
      decoration: BoxDecoration(
        color: active
            ? $styles.colors.accent1
            : $styles.colors.greyMedium.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _StopDetailRow extends StatelessWidget {
  const _StopDetailRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: $styles.colors.greyMedium),
        Gap($styles.insets.xs),
        Expanded(
          child: Text(
            text,
            style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
          ),
        ),
      ],
    );
  }
}

class _EmptyTripMap extends StatelessWidget {
  const _EmptyTripMap({
    required this.title,
    this.message = 'No locations on the map for this trip',
    this.detail = 'Add coordinates to a stop and reopen this view.',
  });
  final String title;

  /// Overridden on web/desktop, where the map isn't the missing data but the
  /// platform — Mapbox ships iOS and Android only.
  final String message;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: $styles.colors.black,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 48,
                    color: $styles.colors.greyMedium,
                  ),
                  Gap($styles.insets.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: $styles.text.body.copyWith(
                      color: $styles.colors.offWhite,
                    ),
                  ),
                  Gap($styles.insets.xxs),
                  Text(
                    detail,
                    textAlign: TextAlign.center,
                    style: $styles.text.bodySmall.copyWith(
                      color: $styles.colors.greyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AppHeader(isTransparent: true, title: title),
          ),
        ],
      ),
    );
  }
}

