import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/domain/entities/trip_route.dart';
import 'package:travel_buddy/domain/entities/trip_stop.dart';
import 'package:travel_buddy/logic/common/concurrency.dart';
import 'package:travel_buddy/ui/common/controls/app_header.dart';
import 'package:travel_buddy/styles/google_map_style.dart';
import 'package:travel_buddy/ui/common/google_maps_marker.dart';
import 'package:travel_buddy/ui/screens/trip_map/trip_map_colors.dart';
import 'package:travel_buddy/utils/polyline_decoder.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Full-screen interactive Google Map for a saved [Trip]. Markers are
/// numbered, colored circles keyed by day; routed polylines come from
/// `trip.routes`; cross-day gaps are bridged with a dashed grey polyline.
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
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Live sets rendered by the [GoogleMap] widget. Animation listeners mutate
  // these incrementally; the entrance starts with both empty and grows them.
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Final, fully-populated state — installed wholesale on skip / dispose.
  final Set<Marker> _finalMarkers = {};
  // The single, fully-drawn trip route. One dashed-grey polyline chaining every
  // stop in global order — never per-day, never offset. Null for 0/1-stop trips.
  Polyline? _finalRouteLine;

  final Map<String, BitmapDescriptor> _iconCache = {};
  final Map<String, TripStop> _mappableStopById = {};
  final Map<String, int> _stopDayNumberById = {};
  // Stop's 1-based index across the whole trip — drives the numbered badge.
  // Continuous (no per-day reset) so two markers never share a number.
  final Map<String, int> _continuousIndexByStopId = {};
  // The entire trip route as one concatenated point list, in global stop order
  // across all days. The per-frame leg draw sublists this without re-decoding.
  List<LatLng> _routePoints = const [];
  // Parallel to _mappableStops: _segmentLegEnd[i] is the number of _routePoints
  // visible once the leg ending at stop i is fully drawn. _segmentLegEnd[0] = 1
  // (just the origin point). Lets each cascade step extend the one polyline from
  // stop i-1 toward stop i without branching on day membership.
  List<int> _segmentLegEnd = const [];
  // (colorARGB, continuousIndex, photoUrl, scaleGridIdx) → BitmapDescriptor.
  // Pre-rendered at mount time so the drop/pulse animations swap in cached
  // bitmaps each frame.
  final Map<String, BitmapDescriptor> _scaledIconCache = {};

  // Quantization grid for animated bitmap scales. Covers the drop range
  // (0.30 → 1.20) and pulse range (1.0 → 1.40). Listeners snap the tween
  // value to the nearest grid index.
  static const List<double> _scaleGrid = <double>[
    0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90,
    0.95, 1.00, 1.05, 1.10, 1.15, 1.20, 1.30, 1.40,
  ];

  // On-screen marker diameter in dp. A touch tighter than the original
  // implicit ~80 dp so densely-packed stops overlap less.
  static const double _baseMarkerLogicalSize = 64;

  List<TripStop> _mappableStops = const [];
  LatLngBounds? _initialBounds;
  String? _selectedStopId;
  bool _isReady = false;
  MapType _mapType = MapType.normal;

  // Entrance animation state.
  _AnimPhase _phase = _AnimPhase.idle;
  bool _skipped = false;
  bool _userPanned = false;
  bool _programmaticCameraInFlight = false;
  bool _disposed = false;
  final List<AnimationController> _activeControllers = [];
  final Map<AnimationController, VoidCallback> _activeListeners = {};
  final Set<String> _pulsingStopIds = {};

  bool _programmaticSheetAnimation = false;

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

    // Build the static (scale-1.0) bitmap and the scaled variants for each
    // (color, continuousIndex, photoUrl) combo. The static one feeds
    // [_finalMarkers]; the scaled variants feed [_animateMarkerDropIn] and
    // [_animatePulse].
    for (final s in mapped) {
      final dayNumber = _stopDayNumberById[s.id]!;
      final color = colorForDayNumber(dayNumber);
      final n = _continuousIndexByStopId[s.id]!;
      final photo = s.photoUrl != null ? photoByUrl[s.photoUrl] : null;
      final colorKey = color.toARGB32().toRadixString(16);
      final photoKey = s.photoUrl ?? '∅';
      final baseKey = '${colorKey}_${n}_$photoKey';

      var icon = _iconCache[baseKey];
      if (icon == null) {
        icon = await buildPhotoMarkerBitmap(
          photo: photo,
          dayColor: color,
          stopNumber: n,
          logicalSize: _baseMarkerLogicalSize,
        );
        if (!mounted) return;
        _iconCache[baseKey] = icon;
      }
      _finalMarkers.add(
        buildStopMarker(
          stopId: s.id,
          position: LatLng(s.lat!, s.lng!),
          icon: icon,
          onTap: () => _onMarkerTapped(s.id),
        ),
      );

      // Pre-render every scale grid variant. Scale 1.0 reuses [icon] as-is.
      for (var idx = 0; idx < _scaleGrid.length; idx++) {
        final scale = _scaleGrid[idx];
        final scaleKey = '${colorKey}_${n}_${photoKey}_$idx';
        if (_scaledIconCache.containsKey(scaleKey)) continue;
        if (scale == 1.0) {
          _scaledIconCache[scaleKey] = icon;
          continue;
        }
        final scaled = await buildPhotoMarkerBitmap(
          photo: photo,
          dayColor: color,
          stopNumber: n,
          logicalSize: _baseMarkerLogicalSize * scale,
        );
        if (!mounted) return;
        _scaledIconCache[scaleKey] = scaled;
      }
    }

    // Build the single continuous trip route: one dashed-grey polyline that
    // chains every mappable stop in global order, ignoring day boundaries.
    // Real Directions geometry is used per leg when available; legs without a
    // route (cross-day gaps, Directions failures) fall back to a straight line.
    // Exactly one polyline, one style, no per-day color, no offset.
    final routeByPair = <String, TripRoute>{
      for (final r in widget.trip.routes) '${r.fromStopId}->${r.toStopId}': r,
    };
    final pts = <LatLng>[LatLng(mapped.first.lat!, mapped.first.lng!)];
    final legEnd = <int>[pts.length]; // legEnd[0] = 1 (origin only)
    for (var i = 1; i < mapped.length; i++) {
      final prev = mapped[i - 1];
      final next = mapped[i];
      final route = routeByPair['${prev.id}->${next.id}'];
      var leg = route != null
          ? decodeEncodedPolyline(route.encodedPolyline)
          : const <LatLng>[];
      if (leg.isEmpty) {
        leg = [
          LatLng(prev.lat!, prev.lng!),
          LatLng(next.lat!, next.lng!),
        ];
      }
      for (final p in leg) {
        final last = pts.last;
        // Skip a leading point that duplicates the current tail so legs join
        // seamlessly into one continuous line.
        if (p.latitude != last.latitude || p.longitude != last.longitude) {
          pts.add(p);
        }
      }
      legEnd.add(pts.length);
    }
    _routePoints = pts;
    _segmentLegEnd = legEnd;
    _finalRouteLine = pts.length < 2
        ? null
        : Polyline(
            polylineId: const PolylineId('trip_route'),
            color: $styles.colors.accent1,
            width: 4,
            points: pts,
            zIndex: 1,
          );

    if (mapped.length >= 2) _initialBounds = _computeBounds(mapped);

    if (mounted) setState(() => _isReady = true);
  }

  LatLngBounds _computeBounds(List<TripStop> stops) {
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
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  CameraPosition _initialCamera() {
    if (_mappableStops.length == 1) {
      final s = _mappableStops.first;
      return CameraPosition(target: LatLng(s.lat!, s.lng!), zoom: 13);
    }
    return const CameraPosition(target: LatLng(41.3275, 19.8189), zoom: 6);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _programmaticCameraInFlight = true;
      _fitToBounds();
      // Kick off the entrance choreography. The sequencer is tolerant to the
      // camera fit still being in flight — its first phase is just a 50ms
      // settle before the first marker drops.
      unawaited(_runEntranceAnimation());
    });
  }

  void _fitToBounds() {
    final ctrl = _mapController;
    if (ctrl == null) return;
    _programmaticCameraInFlight = true;
    if (_mappableStops.length >= 2 && _initialBounds != null) {
      // Just enough inset to keep the outermost markers off the AppHeader and
      // the sheet peek: half the marker diameter plus a small visual gap.
      // GoogleMap.padding already excludes the chrome regions, so this is the
      // additional inset *within* the visible region.
      const fitPadding = _baseMarkerLogicalSize / 2 + 12;
      ctrl.animateCamera(
        CameraUpdate.newLatLngBounds(_initialBounds!, fitPadding),
      );
    } else if (_mappableStops.length == 1) {
      final s = _mappableStops.first;
      ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(s.lat!, s.lng!), 13),
      );
    }
  }

  void _onCameraMoveStarted() {
    // Distinguish gesture-initiated pan from any of our programmatic
    // [animateCamera] calls. Once the user has panned, we never auto-fit
    // again for the lifetime of this screen — respecting their intent
    // beats re-centering on them.
    if (!_programmaticCameraInFlight) {
      _userPanned = true;
    }
  }

  void _onCameraIdle() {
    _programmaticCameraInFlight = false;
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

    // Defer animateCamera one frame so the larger GoogleMap.padding (driven
    // by _selectedStopId in build) is committed to the platform view first —
    // otherwise the camera centers within the *old* padded region.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _programmaticCameraInFlight = true;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(s.lat!, s.lng!), 16),
      );
    });
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

  /// Map-background tap during the entrance choreography. The drop-in scale
  /// animation makes markers smaller than final size, so a tap aimed at a
  /// marker can land just outside its bitmap and end up here instead of in
  /// the marker's [onTap]. If the tap is within ~44 logical pixels of a
  /// known stop, route to [_onMarkerTapped] for that stop; otherwise just
  /// skip the choreography.
  Future<void> _resolveTapAsMarkerOrSkip(LatLng tap) async {
    final nearestId = await _findNearestStopWithinPixels(tap, 44);
    if (!mounted) return;
    if (nearestId != null) {
      _onMarkerTapped(nearestId);
    } else {
      _skipAnimation();
    }
  }

  Future<String?> _findNearestStopWithinPixels(
    LatLng tap,
    double maxPixels,
  ) async {
    final ctrl = _mapController;
    if (ctrl == null || _mappableStops.isEmpty) return null;
    final coords = await Future.wait<ScreenCoordinate>([
      ctrl.getScreenCoordinate(tap),
      for (final s in _mappableStops)
        ctrl.getScreenCoordinate(LatLng(s.lat!, s.lng!)),
    ]);
    if (!mounted) return null;
    final tapXY = coords.first;
    final mq = MediaQuery.maybeOf(context);
    final dpr = mq?.devicePixelRatio ?? 1.0;
    final maxPhysical = maxPixels * dpr; // ScreenCoordinate is in pixels.
    var bestId = '';
    var bestD2 = double.infinity;
    for (var i = 0; i < _mappableStops.length; i++) {
      final p = coords[i + 1];
      final dx = (p.x - tapXY.x).toDouble();
      final dy = (p.y - tapXY.y).toDouble();
      final d2 = dx * dx + dy * dy;
      if (d2 < bestD2) {
        bestD2 = d2;
        bestId = _mappableStops[i].id;
      }
    }
    final ok = math.sqrt(bestD2) <= maxPhysical;
    return ok ? bestId : null;
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

  // ---- Entrance animation choreography --------------------------------------
  //
  // One continuous cascade across all geo-located stops, in order, regardless
  // of day. There is exactly ONE trip polyline — dashed grey, never per-day
  // colored, never offset. Day grouping shows up only in the marker rim color
  // and badge — not in the polyline style or the animation timing.
  //
  // Per step (i ≥ 1) a single timer drives both halves (see [_animateLeg]):
  //   * t in [0, 0.6): the one polyline extends from stop i-1 toward stop i
  //     (easeOut over that leg's points in [_routePoints]).
  //   * t in [0.6, 1]: the moment the segment finishes, marker i drops in —
  //     easeOut overshoot to 1.20 then easeIn settle to 1.00.
  //   The next step doesn't begin until the timer completes. No intra-trip
  //   stagger and no day-boundary pause.
  //
  // The origin marker (i = 0) has no incoming polyline; it uses the legacy
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
  /// [_onMapCreated] after the initial [_fitToBounds]. Bails at every await
  /// boundary if the screen is unmounted or the user tapped to skip.
  Future<void> _runEntranceAnimation() async {
    if (!_alive || _mappableStops.isEmpty) return;
    setState(() => _phase = _AnimPhase.entering);
    // Settle so the first frame paints the empty map before the first pin.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_alive) return;

    setState(() => _phase = _AnimPhase.revealing);

    final stepDur = _stepDurationFor(_mappableStops.length);

    // Origin pin: drops alone, no polyline. Uses the legacy growth tween.
    await _animateMarkerDropIn(
      _mappableStops.first,
      duration: stepDur,
      isOrigin: true,
    );
    if (!_alive) return;

    // Cascade: each step extends the single trip polyline from stop i-1 toward
    // stop i, then drops marker i — both driven by one shared timer per step.
    // No stagger between steps, no day-boundary pause. _segmentLegEnd handles
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
      _programmaticCameraInFlight = true;
      _fitToBounds();
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    if (!_alive) return;
    setState(() => _phase = _AnimPhase.complete);
  }

  /// Animates the origin pin dropping in. Adds the marker to [_markers] and
  /// rebuilds it on every frame with a scaled bitmap descriptor and a fading
  /// alpha. The origin has no incoming polyline, so it fades in over the first
  /// 30% and scales 0.30 → 1.20 → 1.00 across the full timer (78% easeOut
  /// overshoot, 22% easeIn settle) — the screen isn't empty while the user
  /// waits for the first visual. Every subsequent pin drops via [_animateLeg].
  Future<void> _animateMarkerDropIn(
    TripStop stop, {
    Duration duration = const Duration(milliseconds: 450),
    bool isOrigin = false,
  }) async {
    if (!_alive) return;
    final position = LatLng(stop.lat!, stop.lng!);
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
      final scale = scaleAnim.value;
      final alpha = (t / 0.30).clamp(0.0, 1.0);
      final icon = _scaledIconFor(stop.id, scale);
      final newMarker = buildStopMarker(
        stopId: stop.id,
        position: position,
        icon: icon,
        alpha: alpha,
        onTap: () => _onMarkerTapped(stop.id),
      );
      setState(() {
        _markers.removeWhere((m) => m.markerId == newMarker.markerId);
        _markers.add(newMarker);
      });
    }

    _registerActive(controller, listener);

    controller.forward().whenComplete(() {
      _disposeActive(controller);
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  /// Animates one cascade step on a single shared timer: extends the one trip
  /// polyline from stop [stepIndex]-1 toward stop [stepIndex], then drops that
  /// stop's marker the instant the segment finishes.
  ///
  /// `t in [0, _drawFraction)` grows the polyline over this leg's points
  /// (easeOut); `t in [_drawFraction, 1]` drops marker [stepIndex] (easeOut
  /// overshoot to 1.20, easeIn settle to 1.00, alpha fading in as it lands).
  /// The already-drawn prefix stays because every frame sublists from index 0.
  ///
  /// The final frame installs exactly the [_routePoints] prefix for this leg
  /// and the static [_finalMarkers] entry, so the waited state and a skip both
  /// land on the same visual.
  Future<void> _animateLeg(int stepIndex, Duration duration) async {
    if (!_alive) return;
    final stop = _mappableStops[stepIndex];
    final position = LatLng(stop.lat!, stop.lng!);
    final routeLine = _finalRouteLine;
    final base = _segmentLegEnd[stepIndex - 1];
    final end = _segmentLegEnd[stepIndex];

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

      // --- Polyline: extend from stop i-1 toward stop i over [0, drawFraction).
      if (routeLine != null && end > base) {
        final drawT =
            Curves.easeOut.transform((t / drawFraction).clamp(0.0, 1.0));
        var visible = base + ((end - base) * drawT).ceil();
        if (visible < 2) visible = 2;
        if (visible > end) visible = end;
        final line = routeLine.copyWith(
          pointsParam: _routePoints.sublist(0, visible),
        );
        _polylines.removeWhere((p) => p.polylineId == line.polylineId);
        _polylines.add(line);
      }

      // --- Marker i: drops the moment the segment finishes, over [drawFraction, 1].
      final dropT =
          ((t - drawFraction) / (1 - drawFraction)).clamp(0.0, 1.0);
      final scale = dropT <= 0.0 ? 0.30 : dropScale.value;
      final alpha = (dropT / 0.20).clamp(0.0, 1.0);
      final icon = _scaledIconFor(stop.id, scale);
      final newMarker = buildStopMarker(
        stopId: stop.id,
        position: position,
        icon: icon,
        alpha: alpha,
        onTap: () => _onMarkerTapped(stop.id),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId == newMarker.markerId);
        _markers.add(newMarker);
      });
    }

    _registerActive(controller, listener);

    controller.forward().whenComplete(() {
      _disposeActive(controller);
      if (mounted) {
        // Snap to the exact final visuals so per-frame rounding can't leave a
        // short polyline or an off-scale bitmap behind.
        final finalMarker = _finalMarkers.firstWhereOrNull(
          (m) => m.markerId.value == stop.id,
        );
        setState(() {
          if (routeLine != null) {
            final line = routeLine.copyWith(
              pointsParam: _routePoints.sublist(0, end),
            );
            _polylines.removeWhere((p) => p.polylineId == line.polylineId);
            _polylines.add(line);
          }
          if (finalMarker != null) {
            _markers.removeWhere((m) => m.markerId.value == stop.id);
            _markers.add(finalMarker);
          }
        });
      }
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  /// Pulses a marker scale 1.0 → 1.4 → 1.0 over 600ms. Triggered when the
  /// user taps a stop in the bottom sheet (or directly on the map). No-op if
  /// the same stop is already pulsing.
  Future<void> _animatePulse(String stopId) async {
    if (!mounted) return;
    if (_pulsingStopIds.contains(stopId)) return;
    final stop = _mappableStopById[stopId];
    if (stop == null) return;
    final dayNumber = _stopDayNumberById[stopId];
    if (dayNumber == null) return;
    final position = LatLng(stop.lat!, stop.lng!);
    _pulsingStopIds.add(stopId);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
      var scale = scaleAnim.value;
      // Elastic curve overshoots; clamp so we always have a cached bitmap.
      if (scale < _scaleGrid.first) scale = _scaleGrid.first;
      if (scale > _scaleGrid.last) scale = _scaleGrid.last;
      final icon = _scaledIconFor(stopId, scale);
      final newMarker = buildStopMarker(
        stopId: stopId,
        position: position,
        icon: icon,
        onTap: () => _onMarkerTapped(stopId),
      );
      setState(() {
        _markers.removeWhere((m) => m.markerId == newMarker.markerId);
        _markers.add(newMarker);
      });
    }

    _registerActive(controller, listener);

    await controller.forward().whenComplete(() {
      _disposeActive(controller);
      _pulsingStopIds.remove(stopId);
      if (!mounted) return;
      // Restore the exact static marker so any rounding error in the listener
      // can't leave a slightly-off-scale bitmap behind.
      final finalMarker = _finalMarkers.firstWhereOrNull(
        (m) => m.markerId.value == stopId,
      );
      if (finalMarker != null) {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == stopId);
          _markers.add(finalMarker);
        });
      }
    });
  }

  /// Cancels every in-flight controller and installs the final marker /
  /// polyline sets in a single setState. Idempotent for terminal phases.
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
    setState(() {
      _phase = _AnimPhase.skipped;
      _markers
        ..clear()
        ..addAll(_finalMarkers);
      _polylines.clear();
      if (_finalRouteLine != null) _polylines.add(_finalRouteLine!);
    });
  }

  /// Looks up the cached scaled bitmap nearest the requested [scale]. Returns
  /// the static (1.0) bitmap on a miss — should not happen because the cache
  /// is fully populated in [_buildMapData].
  BitmapDescriptor _scaledIconFor(String stopId, double scale) {
    final stop = _mappableStopById[stopId];
    final dayNumber = _stopDayNumberById[stopId];
    final n = _continuousIndexByStopId[stopId];
    if (stop == null || dayNumber == null || n == null) {
      return BitmapDescriptor.defaultMarker;
    }
    var bestIdx = 0;
    var bestDiff = double.infinity;
    for (var i = 0; i < _scaleGrid.length; i++) {
      final diff = (_scaleGrid[i] - scale).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIdx = i;
      }
    }
    final color = colorForDayNumber(dayNumber);
    final colorKey = color.toARGB32().toRadixString(16);
    final photoKey = stop.photoUrl ?? '∅';
    final scaleKey = '${colorKey}_${n}_${photoKey}_$bestIdx';
    final cached = _scaledIconCache[scaleKey];
    if (cached != null) return cached;
    final baseKey = '${colorKey}_${n}_$photoKey';
    return _iconCache[baseKey] ?? BitmapDescriptor.defaultMarker;
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
    _mapController?.dispose();
    _sheetController.removeListener(_onSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    // Tell the map about the chrome that overlays it so the bounds-fit lands
    // inside the visible window (not under the AppHeader or the details sheet).
    // - Top: status bar + ~56dp transparent header.
    // - Bottom: half the screen when a marker is selected (so the tapped
    //   marker centers in the upper half above the sheet); a small home-
    //   indicator pad otherwise.
    final mq = MediaQuery.of(context);
    final mapTopInset = mq.padding.top + 56;
    final mapBottomInset = _selectedStopId != null
        ? mq.size.height * _sheetMaxSize + mq.padding.bottom
        : mq.padding.bottom + 8;

    return ColoredBox(
      color: $styles.colors.black,
      child: Stack(
        children: [
          // Hero tag matches the saved-itinerary thumbnail in the buddy chat
          // bubble, so tapping the thumbnail morphs into the full map.
          Hero(
            tag: 'itinerary_map_${widget.trip.id}',
            child: GoogleMap(
            initialCameraPosition: _initialCamera(),
            padding: EdgeInsets.only(
              top: mapTopInset,
              bottom: mapBottomInset,
            ),
            markers: _markers,
            polylines: _polylines,
            mapType: _mapType,
            // AppColors-themed base map. Cleared on satellite (imagery
            // already carries its own palette). Mirrored in
            // travel-buddy-backend/.../static_map.py:_MAP_STYLE_RULES.
            style: _mapType == MapType.normal ? kAppMapStyleJson : null,
            onMapCreated: _onMapCreated,
            onCameraMoveStarted: _onCameraMoveStarted,
            onCameraIdle: _onCameraIdle,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onTap: (LatLng pos) {
              // While the details sheet is up, any map tap dismisses the sheet.
              // The camera stays put — any panning/zooming the user did while
              // the sheet was open is preserved.
              if (_selectedStopId != null) {
                _dismissSheet();
                return;
              }
              // During entrance the markers are scale-animating below their
              // final size, which makes them easy to miss. If the user tapped
              // near a known stop, treat it as a marker tap so the first tap
              // opens the sheet instead of just skipping the choreography.
              if (_phase != _AnimPhase.complete &&
                  _phase != _AnimPhase.skipped) {
                _resolveTapAsMarkerOrSkip(pos);
              }
            },
            ),
          ),
          // PointerInterceptor (here and below) stops taps on widgets that
          // overlay the GoogleMap from falling through to the map's platform
          // view on web. It's a no-op on mobile.
          Align(
            alignment: Alignment.topCenter,
            child: PointerInterceptor(
              child: const AppHeader(isTransparent: true),
            ),
          ),
          Positioned(
            top: mapTopInset + 8,
            right: 12,
            child: PointerInterceptor(
              child: _MapTypeToggle(
                mapType: _mapType,
                onToggle: () => setState(() {
                  _mapType = _mapType == MapType.normal
                      ? MapType.satellite
                      : MapType.normal;
                }),
              ),
            ),
          ),
          // The Align/SizedBox wrapper is unconditional (never toggled by
          // _selectedStopId) so the sheet's inner Scrollable keeps the same
          // tree location across state changes — see the comment on `stop:`.
          // It caps the sheet's width on wide web/desktop windows.
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
                builder: (ctx, scrollCtrl) => PointerInterceptor(
                  child: _StopDetailsSheet(
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
          ),
        ],
      ),
    );
  }
}

/// Small circular button at the top-right of the map that toggles the
/// underlying [GoogleMap.mapType] between normal and satellite. The icon
/// reflects the *target* state (satellite glyph in normal mode, map glyph
/// in satellite mode) so the user knows what they're switching to.
class _MapTypeToggle extends StatelessWidget {
  const _MapTypeToggle({required this.mapType, required this.onToggle});
  final MapType mapType;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isSatellite = mapType == MapType.satellite;
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
/// "Open in Google Maps" icon. The parent screen drives open/close via
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
    final placeId = s.googlePlaceId;
    Uri uri;
    if (placeId != null && placeId.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeComponent(s.name)}'
        '&query_place_id=$placeId',
      );
    } else if (s.lat != null && s.lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${s.lat},${s.lng}',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeComponent(s.name)}',
      );
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          const _PhotoPlaceholder(),
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
        placeholder: (_, _) => const _PhotoPlaceholder(),
        errorWidget: (_, _, _) => const _PhotoPlaceholder(),
      ),
    );
  }
}

/// Top-right round badge that opens the place in Google Maps. Returns a
/// `Positioned` so it must be placed inside a Stack.
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
              semanticLabel: 'Open in Google Maps',
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

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: $styles.colors.greyMedium.withValues(alpha: 0.25),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 36,
          color: $styles.colors.greyMedium,
        ),
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
  const _EmptyTripMap({required this.title});
  final String title;

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
                    'No locations on the map for this trip',
                    textAlign: TextAlign.center,
                    style: $styles.text.body.copyWith(
                      color: $styles.colors.offWhite,
                    ),
                  ),
                  Gap($styles.insets.xxs),
                  Text(
                    'Add coordinates to a stop and reopen this view.',
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

