import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/agent/features/visit_detection/logic/visit_evaluator.dart';
import 'package:travel_buddy/agent/logic/auto_track_prefs.dart';
import 'package:travel_buddy/agent/services/location_service.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class VisitDetectorEvent extends Equatable {
  const VisitDetectorEvent();
  @override
  List<Object?> get props => const [];
}

class VisitDetectorActivated extends VisitDetectorEvent {
  const VisitDetectorActivated(this.tripId);
  final String tripId;
  @override
  List<Object?> get props => [tripId];
}

class VisitDetectorDeactivated extends VisitDetectorEvent {
  const VisitDetectorDeactivated();
}

class _PositionReceived extends VisitDetectorEvent {
  const _PositionReceived(this.position);
  final Position position;
  @override
  List<Object?> get props => [position];
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class VisitDetectorState extends Equatable {
  const VisitDetectorState({
    this.isActive = false,
    this.lastAttemptedTripId,
  });
  final bool isActive;
  final String? lastAttemptedTripId;

  VisitDetectorState copyWith({bool? isActive, String? lastAttemptedTripId}) =>
      VisitDetectorState(
        isActive: isActive ?? this.isActive,
        lastAttemptedTripId: lastAttemptedTripId ?? this.lastAttemptedTripId,
      );

  @override
  List<Object?> get props => [isActive, lastAttemptedTripId];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

/// Foreground visit-detection driver. Lives for the lifetime of a single
/// [TripDetailScreen]. On activation: verifies (a) the user opted in for
/// this trip, (b) the trip is in its calendar window, (c) location
/// permission is `whileInUse` (or `always`); if so, subscribes to the
/// position stream and dispatches [StopVisitMarkRequested] to [TripsBloc]
/// when a stop matches the time-and-distance criteria.
///
/// Throttle: one evaluator pass at most every 30 s, plus a per-stop
/// session lock so the same stop can't be PATCHed twice. The server is
/// source of truth — once `stop.completedAt` propagates back via the
/// `TripsBloc` state, [evaluateVisits] also skips it on next pass.
class VisitDetectorBloc extends Bloc<VisitDetectorEvent, VisitDetectorState> {
  VisitDetectorBloc({
    required this.tripsBloc,
    required this.locationService,
    required this.autoTrackPrefs,
  }) : super(const VisitDetectorState()) {
    on<VisitDetectorActivated>(_onActivated);
    on<VisitDetectorDeactivated>(_onDeactivated);
    on<_PositionReceived>(_onPositionReceived);
  }

  final TripsBloc tripsBloc;
  final LocationService locationService;
  final AutoTrackPrefs autoTrackPrefs;

  StreamSubscription<Position>? _sub;
  String? _activeTripId;
  final Set<String> _markedThisSession = <String>{};
  DateTime _lastEval = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _evalThrottle = Duration(seconds: 30);
  // Set when activation arrives before TripsBloc has the trip in state
  // (cold-start path — TripDetailScreen fires us in initState while
  // _ensureLoaded's HTTP GET is still in flight). `_tripsWatch` is then a
  // one-shot listener that self-retries `VisitDetectorActivated` once the
  // trip enters TripsBloc state. Both are cleared in _onDeactivated, close,
  // and at the top of every new _onActivated.
  StreamSubscription<TripsState>? _tripsWatch;
  String? _pendingTripId;

  Future<void> _onActivated(
    VisitDetectorActivated e,
    Emitter<VisitDetectorState> emit,
  ) async {
    emit(state.copyWith(lastAttemptedTripId: e.tripId));
    await _tripsWatch?.cancel();
    _tripsWatch = null;
    _pendingTripId = null;
    if (autoTrackPrefs.decisionFor(e.tripId) != true) return;
    final trip = _findTrip(e.tripId);
    if (trip == null) {
      _pendingTripId = e.tripId;
      _tripsWatch = tripsBloc.stream.listen((s) {
        final pending = _pendingTripId;
        if (pending == null) return;
        if (s.trips.any((t) => t.id == pending)) {
          _pendingTripId = null;
          _tripsWatch?.cancel();
          _tripsWatch = null;
          add(VisitDetectorActivated(pending));
        }
      });
      return;
    }
    if (!_isInDateWindow(trip)) return;
    final perm = await locationService.checkPermission();
    if (perm != LocationPermission.whileInUse &&
        perm != LocationPermission.always) {
      return;
    }
    final serviceOn = await locationService.isServiceEnabled();
    if (!serviceOn) return;
    _activeTripId = e.tripId;
    _markedThisSession.clear();
    _lastEval = DateTime.fromMillisecondsSinceEpoch(0);
    await _sub?.cancel();
    _sub = locationService.positions().listen(
      (pos) => add(_PositionReceived(pos)),
    );
    emit(state.copyWith(isActive: true));
  }

  Future<void> _onDeactivated(
    VisitDetectorDeactivated e,
    Emitter<VisitDetectorState> emit,
  ) async {
    _activeTripId = null;
    _markedThisSession.clear();
    await _tripsWatch?.cancel();
    _tripsWatch = null;
    _pendingTripId = null;
    await _sub?.cancel();
    _sub = null;
    emit(state.copyWith(isActive: false));
  }

  Future<void> _onPositionReceived(
    _PositionReceived e,
    Emitter<VisitDetectorState> emit,
  ) async {
    final now = DateTime.now();
    if (now.difference(_lastEval) < _evalThrottle) return;
    _lastEval = now;
    final tripId = _activeTripId;
    if (tripId == null) return;
    final trip = _findTrip(tripId);
    if (trip == null) return;
    final candidates = evaluateVisits(
      trip: trip,
      pos: VisitEvaluatorPosition(
        latitude: e.position.latitude,
        longitude: e.position.longitude,
      ),
      now: now,
    );
    for (final c in candidates) {
      if (_markedThisSession.contains(c.stopId)) continue;
      _markedThisSession.add(c.stopId);
      tripsBloc.add(StopVisitMarkRequested(
        tripId: tripId,
        dayId: c.dayId,
        stopId: c.stopId,
        visitedAt: c.detectedAt.toUtc(),
        source: 'auto',
      ));
      // One match per evaluation. Two close stops would both fire on
      // subsequent passes; this avoids hammering the server when the
      // user lingers at a cluster.
      break;
    }
  }

  Trip? _findTrip(String tripId) {
    for (final t in tripsBloc.state.trips) {
      if (t.id == tripId) return t;
    }
    return null;
  }

  bool _isInDateWindow(Trip trip) {
    final start = trip.startDate;
    if (start == null) return true; // permissive when undated
    final startDay = DateTime(start.year, start.month, start.day);
    final endExclusive = startDay.add(Duration(days: trip.days.length + 1));
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    return !todayDay.isBefore(startDay) && todayDay.isBefore(endExclusive);
  }

  @override
  Future<void> close() async {
    await _tripsWatch?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
