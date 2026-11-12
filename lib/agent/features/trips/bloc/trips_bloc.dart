import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_day.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_stop.dart';
import 'package:pathfinder_albania/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:pathfinder_albania/agent/features/buddy/bloc/buddy_event.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_error_mapper.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_event.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_state.dart';
import 'package:pathfinder_albania/agent/services/trip_service.dart';

/// Free-tier cap. Mirrors the backend's `MAX_TRIPS_PER_USER` in
/// `app/routers/trips.py`. Kept as a top-level constant so the BuddyScreen
/// save button and the MyTrips header counter can read the same value
/// without duplicating the magic number.
const int maxSavedTrips = 3;

/// Saved trips for the current authenticated user. Replaces the legacy
/// `TripsLogic` (GetIt + ValueNotifier). Mutation handlers retain the
/// snapshot → optimistic emit → API → equality-guarded revert pattern.
class TripsBloc extends Bloc<TripsEvent, TripsState> {
  TripsBloc({
    required TripService service,
    required String? Function() tokenReader,
    BuddyBloc Function()? buddyBlocProvider,
  }) : _service = service,
       _tokenReader = tokenReader,
       _buddyBlocProvider =
           buddyBlocProvider ?? (() => GetIt.I<BuddyBloc>()),
       super(const TripsState()) {
    on<LoadAllRequested>(_onLoadAll);
    on<TripsLoadMoreRequested>(_onLoadMore);
    on<TripCleared>(_onTripCleared);
    on<TripMerged>(_onTripMerged);
    on<ItinerarySaveRequested>(_onItinerarySave);
    on<TripRenameRequested>(_onTripRename);
    on<TripSummaryUpdateRequested>(_onTripSummaryUpdate);
    on<TripStartDateUpdateRequested>(_onTripStartDateUpdate);
    on<TripDeleteRequested>(_onTripDelete);
    on<TripClearAllRequested>(_onTripClearAll);
    on<StopEditRequested>(_onStopEdit);
    on<StopVisitMarkRequested>(_onStopVisitMark);
    on<StopVisitResetRequested>(_onStopVisitReset);
    on<StopAddRequested>(_onStopAdd);
    on<StopDeleteRequested>(_onStopDelete);
    on<StopDeleteUndoRequested>(_onStopDeleteUndo);
    on<StopDeleteUndoExpired>(_onStopDeleteUndoExpired);
    on<StopsReorderRequested>(_onStopsReorder);
    on<StopMoveToDayRequested>(_onStopMoveToDay);
    on<DayAddRequested>(_onDayAdd);
    on<DayDeleteRequested>(_onDayDelete);
    on<DayMetaUpdateRequested>(_onDayMetaUpdate);
    on<ErrorDismissed>(_onErrorDismissed);
    on<TripsErrorSurfaced>(_onErrorSurfaced);
  }

  final TripService _service;
  final String? Function() _tokenReader;
  final BuddyBloc Function() _buddyBlocProvider;

  /// Per-day in-flight tail used to chain ops on the same `(tripId, dayId)`.
  /// Different keys run in parallel; same-key ops chain through. Same shape
  /// as the legacy `TripsLogic._dayInflight`.
  final Map<String, Future<void>> _dayInflight = {};

  /// 5-second expiry timers for inline-undo records, keyed by deleted
  /// `stopId`. Canceled when the user taps UNDO (the corresponding record
  /// is consumed by `_onStopDeleteUndo`) or when the bloc is closed.
  final Map<String, Timer> _undoTimers = {};

  /// Window during which a just-deleted stop can be restored by tapping
  /// the inline UNDO banner. After this the record is cleared and the
  /// stop is gone for good (until next sync).
  static const Duration _undoWindow = Duration(seconds: 5);

  @override
  Future<void> close() {
    for (final t in _undoTimers.values) {
      t.cancel();
    }
    _undoTimers.clear();
    return super.close();
  }

  // ---- handlers ----

  Future<void> _onLoadAll(LoadAllRequested e, Emitter<TripsState> emit) async {
    final token = _tokenReader();
    if (token == null || token.isEmpty) {
      // Logged-out path: idempotent reset, no error surface.
      emit(state.copyWith(
        trips: const [],
        nextCursor: null,
        hasMore: true,
        isLoading: false,
        isLoadingMore: false,
        lastError: null,
      ));
      return;
    }
    emit(state.copyWith(isLoading: true, lastError: null));
    try {
      final page = await _service.listTrips(bearerToken: token);
      emit(state.copyWith(
        trips: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
        isLoading: false,
        lastError: null,
      ));
    } catch (err) {
      // Was previously swallowed (`catch (_)`); now surfaces a banner key so
      // the empty-state UI can offer a retry instead of silently showing the
      // empty list. The mapper returns a `TripsErrorKey.*` constant.
      emit(state.copyWith(
        isLoading: false,
        lastError: mapTripsError(err),
      ));
    }
  }

  Future<void> _onLoadMore(
    TripsLoadMoreRequested e,
    Emitter<TripsState> emit,
  ) async {
    // Idempotent: no-ops if already loading, no more pages, or no cursor yet.
    if (!state.hasMore || state.isLoadingMore || state.nextCursor == null) {
      return;
    }
    final token = _tokenReader();
    if (token == null || token.isEmpty) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await _service.listTrips(
        bearerToken: token,
        cursor: state.nextCursor,
      );
      emit(state.copyWith(
        trips: [...state.trips, ...page.items],
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
        isLoadingMore: false,
      ));
    } catch (err) {
      // Preserve existing trips on append-failure; just clear the in-flight
      // flag and surface the error key. The infinite-scroll handler will be
      // free to retry on the next scroll tick.
      emit(state.copyWith(
        isLoadingMore: false,
        lastError: mapTripsError(err),
      ));
    }
  }

  void _onTripCleared(TripCleared e, Emitter<TripsState> emit) {
    emit(state.copyWith(trips: const [], lastError: null));
  }

  void _onTripMerged(TripMerged e, Emitter<TripsState> emit) {
    final existing = state.trips;
    final idx = existing.indexWhere((t) => t.id == e.trip.id);
    if (idx == -1) {
      emit(state.copyWith(trips: [...existing, e.trip]));
    } else {
      emit(state.copyWith(trips: [...existing]..[idx] = e.trip));
    }
  }

  Future<void> _onItinerarySave(
    ItinerarySaveRequested e,
    Emitter<TripsState> emit,
  ) async {
    // Free-tier cap. The backend is the source of truth (returns 409 with
    // `trip_limit_reached`), but checking here saves a network round-trip
    // and lets the BuddyScreen save button render its "limit reached" state
    // instantly via a BlocSelector on `state.trips.length`. The guard uses
    // `>= maxSavedTrips`, not `>= 1`, so a cold-start with unloaded trips
    // (length 0) doesn't false-positive.
    if (state.trips.length >= maxSavedTrips) {
      final err = TripServiceException(409, 'trip_limit_reached');
      emit(state.copyWith(lastError: TripsErrorKey.tripLimitReached));
      e.completer?.completeError(err);
      return;
    }
    try {
      final body = e.draft.toCreatePayload(
        userPickedStartDate: e.userPickedStartDate,
      );
      final trip = await _service.createTrip(body, bearerToken: _tokenReader());
      emit(state.copyWith(trips: [trip, ...state.trips]));
      // Notify the chat bubble BEFORE completing the save-button future so
      // the message is patched with `savedTripId` on the same frame the
      // button transitions to its "saved" state — no flicker of saved-
      // -without-thumbnail.
      _buddyBlocProvider().add(BuddySavedTripLinked(
        assistantMessageId: e.assistantMessageId,
        savedTripId: trip.id,
      ));
      e.completer?.complete(trip);
    } catch (err, st) {
      // Race-condition path: client-side check passed (state stale) but the
      // server still rejected with 409. Surface the same lastError key so
      // any UI watching the bloc state reacts identically. BuddyScreen also
      // catches this in `_handleTap` to flip its local _SaveState.
      if (mapTripsError(err) == TripsErrorKey.tripLimitReached) {
        emit(state.copyWith(lastError: TripsErrorKey.tripLimitReached));
      }
      e.completer?.completeError(err, st);
      rethrow;
    }
  }

  Future<void> _onTripRename(
    TripRenameRequested e,
    Emitter<TripsState> emit,
  ) async {
    final trimmed = e.newTitle.trim();
    if (trimmed.isEmpty) return;
    final prev = state.trips;
    final idx = prev.indexWhere((t) => t.id == e.tripId);
    if (idx == -1) return;
    final optimistic = prev[idx].copyWith(title: trimmed);
    emit(state.copyWith(
      trips: [...prev]..[idx] = optimistic,
      pendingTripIds: {...state.pendingTripIds, e.tripId},
    ));
    try {
      final server = await _service.patchTrip(
        e.tripId,
        {'title': trimmed},
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingTripIds: state.pendingTripIds.difference({e.tripId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, e.tripId, optimistic, prev[idx], err)
          .copyWith(pendingTripIds: state.pendingTripIds.difference({e.tripId})));
    }
  }

  Future<void> _onTripSummaryUpdate(
    TripSummaryUpdateRequested e,
    Emitter<TripsState> emit,
  ) async {
    final prev = state.trips;
    final idx = prev.indexWhere((t) => t.id == e.tripId);
    if (idx == -1) return;
    final optimistic = prev[idx].copyWith(summary: e.newSummary);
    emit(state.copyWith(
      trips: [...prev]..[idx] = optimistic,
      pendingTripIds: {...state.pendingTripIds, e.tripId},
    ));
    try {
      final server = await _service.patchTrip(
        e.tripId,
        {'summary': e.newSummary},
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingTripIds: state.pendingTripIds.difference({e.tripId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, e.tripId, optimistic, prev[idx], err)
          .copyWith(pendingTripIds: state.pendingTripIds.difference({e.tripId})));
    }
  }

  Future<void> _onTripStartDateUpdate(
    TripStartDateUpdateRequested e,
    Emitter<TripsState> emit,
  ) async {
    final prev = state.trips;
    final idx = prev.indexWhere((t) => t.id == e.tripId);
    if (idx == -1) return;
    Trip optimistic;
    Map<String, dynamic> body;
    if (e.clear) {
      optimistic = prev[idx].copyWith(startDate: null);
      body = {'start_date': null};
    } else if (e.startDate != null) {
      optimistic = prev[idx].copyWith(startDate: e.startDate);
      body = {'start_date': DateFormat('yyyy-MM-dd').format(e.startDate!)};
    } else {
      return;
    }
    emit(state.copyWith(
      trips: [...prev]..[idx] = optimistic,
      pendingTripIds: {...state.pendingTripIds, e.tripId},
    ));
    try {
      final server = await _service.patchTrip(
        e.tripId,
        body,
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingTripIds: state.pendingTripIds.difference({e.tripId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, e.tripId, optimistic, prev[idx], err)
          .copyWith(pendingTripIds: state.pendingTripIds.difference({e.tripId})));
    }
  }

  Future<void> _onTripDelete(
    TripDeleteRequested e,
    Emitter<TripsState> emit,
  ) async {
    final prev = state.trips;
    emit(state.copyWith(
      trips: prev.where((t) => t.id != e.tripId).toList(growable: false),
      pendingTripIds: {...state.pendingTripIds, e.tripId},
    ));
    try {
      await _service.deleteTrip(e.tripId, bearerToken: _tokenReader());
      emit(state.copyWith(
        pendingTripIds: state.pendingTripIds.difference({e.tripId}),
      ));
    } catch (err) {
      emit(state.copyWith(
        trips: prev,
        lastError: mapTripsError(err),
        pendingTripIds: state.pendingTripIds.difference({e.tripId}),
      ));
    }
  }

  Future<void> _onTripClearAll(
    TripClearAllRequested e,
    Emitter<TripsState> emit,
  ) async {
    final prev = state.trips;
    if (prev.isEmpty) return;
    final ids = prev.map((t) => t.id).toSet();
    emit(state.copyWith(
      trips: const [],
      pendingTripIds: {...state.pendingTripIds, ...ids},
    ));
    try {
      for (final id in ids) {
        await _service.deleteTrip(id, bearerToken: _tokenReader());
      }
      emit(state.copyWith(
        pendingTripIds: state.pendingTripIds.difference(ids),
      ));
    } catch (err) {
      emit(state.copyWith(
        trips: prev,
        lastError: mapTripsError(err),
        pendingTripIds: state.pendingTripIds.difference(ids),
      ));
    }
  }

  Future<void> _onStopEdit(
    StopEditRequested e,
    Emitter<TripsState> emit,
  ) async {
    if (e.patch.isEmpty) return;
    final prev = state.trips;
    final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
    if (tripIdx == -1) return;
    final trip = prev[tripIdx];
    final dayIdx = trip.days.indexWhere((d) => d.id == e.dayId);
    if (dayIdx == -1) return;
    final day = trip.days[dayIdx];
    final stopIdx = day.stops.indexWhere((s) => s.id == e.stopId);
    if (stopIdx == -1) return;
    final original = day.stops[stopIdx];
    final updatedStop = _applyPatchToStop(original, e.patch);
    final updatedDay = day.copyWith(
      stops: [...day.stops]..[stopIdx] = updatedStop,
    );
    final optimistic = trip.copyWith(
      days: [...trip.days]..[dayIdx] = updatedDay,
    );
    emit(state.copyWith(
      trips: [...prev]..[tripIdx] = optimistic,
      pendingStopIds: {...state.pendingStopIds, e.stopId},
    ));
    try {
      final server = await _service.patchStop(
        e.tripId,
        e.stopId,
        e.patch,
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingStopIds: state.pendingStopIds.difference({e.stopId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, e.tripId, optimistic, trip, err)
          .copyWith(pendingStopIds: state.pendingStopIds.difference({e.stopId})));
    }
  }

  Future<void> _onStopVisitMark(
    StopVisitMarkRequested e,
    Emitter<TripsState> emit,
  ) async {
    await _patchStopCompletedAt(
      tripId: e.tripId,
      dayId: e.dayId,
      stopId: e.stopId,
      completedAt: e.visitedAt,
      emit: emit,
    );
  }

  Future<void> _onStopVisitReset(
    StopVisitResetRequested e,
    Emitter<TripsState> emit,
  ) async {
    await _patchStopCompletedAt(
      tripId: e.tripId,
      dayId: e.dayId,
      stopId: e.stopId,
      completedAt: null,
      emit: emit,
    );
  }

  /// Shared mark/reset path — single `completed_at` PATCH; everything else
  /// matches the [_onStopEdit] shape (optimistic emit → PATCH → revert on
  /// failure).
  Future<void> _patchStopCompletedAt({
    required String tripId,
    required String dayId,
    required String stopId,
    required DateTime? completedAt,
    required Emitter<TripsState> emit,
  }) async {
    final prev = state.trips;
    final tripIdx = prev.indexWhere((t) => t.id == tripId);
    if (tripIdx == -1) return;
    final trip = prev[tripIdx];
    final dayIdx = trip.days.indexWhere((d) => d.id == dayId);
    if (dayIdx == -1) return;
    final day = trip.days[dayIdx];
    final stopIdx = day.stops.indexWhere((s) => s.id == stopId);
    if (stopIdx == -1) return;
    final original = day.stops[stopIdx];
    // No-op if state already matches (e.g. auto-detector races a re-fetch).
    if (original.completedAt == completedAt) return;
    final updatedStop = original.copyWith(completedAt: completedAt);
    final updatedDay = day.copyWith(
      stops: [...day.stops]..[stopIdx] = updatedStop,
    );
    final optimistic = trip.copyWith(
      days: [...trip.days]..[dayIdx] = updatedDay,
    );
    emit(state.copyWith(
      trips: [...prev]..[tripIdx] = optimistic,
      pendingStopIds: {...state.pendingStopIds, stopId},
    ));
    try {
      final server = await _service.patchStop(
        tripId,
        stopId,
        {'completed_at': completedAt?.toUtc().toIso8601String()},
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingStopIds: state.pendingStopIds.difference({stopId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, tripId, optimistic, trip, err)
          .copyWith(pendingStopIds: state.pendingStopIds.difference({stopId})));
    }
  }

  Future<void> _onStopAdd(StopAddRequested e, Emitter<TripsState> emit) async {
    await _serializeOnDay(e.tripId, e.dayId, () async {
      final prev = state.trips;
      final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
      if (tripIdx == -1) return;
      final trip = prev[tripIdx];
      final dayIdx = trip.days.indexWhere((d) => d.id == e.dayId);
      if (dayIdx == -1) return;
      final day = trip.days[dayIdx];
      final tempId = '__pending-${DateTime.now().microsecondsSinceEpoch}';
      final maxSort = day.stops.fold<int>(
        -1,
        (acc, s) => math.max(acc, s.sortOrder),
      );
      final insertAt = e.sortOrder ?? (maxSort + 1);
      final tempStop = TripStop(
        id: tempId,
        sortOrder: insertAt,
        name: (e.stopBody['name'] as String?) ?? '',
        kind: stopKindFromString(e.stopBody['kind'] as String?),
        city: e.stopBody['city'] as String?,
        address: e.stopBody['address'] as String?,
        durationMinutes: (e.stopBody['duration_minutes'] as num?)?.toInt(),
        arrivalTime: e.stopBody['arrival_time'] as String?,
        endTime: e.stopBody['end_time'] as String?,
        transportation: transportationKindFromString(
          e.stopBody['transportation'] as String?,
        ),
        notes: e.stopBody['notes'] as String?,
        lat: (e.stopBody['lat'] as num?)?.toDouble(),
        lng: (e.stopBody['lng'] as num?)?.toDouble(),
      );
      final newStops = [...day.stops];
      if (e.sortOrder != null && e.sortOrder! < newStops.length) {
        newStops.insert(e.sortOrder!, tempStop);
        for (var i = e.sortOrder! + 1; i < newStops.length; i++) {
          newStops[i] = newStops[i].copyWith(sortOrder: newStops[i].sortOrder + 1);
        }
      } else {
        newStops.add(tempStop);
      }
      final updatedDay = day.copyWith(stops: newStops);
      final optimistic = trip.copyWith(
        days: [...trip.days]..[dayIdx] = updatedDay,
      );
      emit(state.copyWith(
        trips: [...prev]..[tripIdx] = optimistic,
        pendingDayIds: {...state.pendingDayIds, e.dayId},
      ));
      try {
        final body = Map<String, dynamic>.from(e.stopBody);
        if (e.sortOrder != null) body['sort_order'] = e.sortOrder;
        final server = await _service.addStop(
          e.tripId,
          e.dayId,
          body,
          bearerToken: _tokenReader(),
        );
        emit(state.copyWith(
          trips: _withTrip(state.trips, server),
          pendingDayIds: state.pendingDayIds.difference({e.dayId}),
        ));
      } catch (err) {
        emit(_revertTrip(state, e.tripId, optimistic, trip, err)
            .copyWith(pendingDayIds: state.pendingDayIds.difference({e.dayId})));
      }
    });
  }

  Future<void> _onStopDelete(
    StopDeleteRequested e,
    Emitter<TripsState> emit,
  ) async {
    await _serializeOnDay(e.tripId, e.dayId, () async {
      final prev = state.trips;
      final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
      if (tripIdx == -1) return;
      final trip = prev[tripIdx];
      final dayIdx = trip.days.indexWhere((d) => d.id == e.dayId);
      if (dayIdx == -1) return;
      final day = trip.days[dayIdx];
      final stopIdx = day.stops.indexWhere((s) => s.id == e.stopId);
      if (stopIdx == -1) return;
      final stop = day.stops[stopIdx];
      // Build the inline-undo record BEFORE we mutate state. If the server
      // delete succeeds, the record drives the banner for `_undoWindow`;
      // if it fails, we still emit a clear so the banner doesn't linger.
      final undoBody = _undoBodyFromStop(stop);
      final newStops = [...day.stops]..removeAt(stopIdx);
      final updatedDay = day.copyWith(stops: newStops);
      final optimistic = trip.copyWith(
        days: [...trip.days]..[dayIdx] = updatedDay,
      );
      final undoRecord = UndoStopRecord(
        tripId: e.tripId,
        dayId: e.dayId,
        stopId: e.stopId,
        stopName: stop.name,
        originalSortOrder: stop.sortOrder,
        body: undoBody,
      );
      emit(state.copyWith(
        trips: [...prev]..[tripIdx] = optimistic,
        pendingStopIds: {...state.pendingStopIds, e.stopId},
        pendingUndoStops: {...state.pendingUndoStops, e.stopId: undoRecord},
      ));
      try {
        final server = await _service.deleteStop(
          e.tripId,
          e.stopId,
          bearerToken: _tokenReader(),
        );
        emit(state.copyWith(
          trips: _withTrip(state.trips, server),
          pendingStopIds: state.pendingStopIds.difference({e.stopId}),
        ));
        // Arm the undo expiry only after the server confirmed the delete.
        // If the user already tapped UNDO during the in-flight DELETE, the
        // record is gone here and we skip scheduling a no-op.
        if (state.pendingUndoStops.containsKey(e.stopId)) {
          _undoTimers[e.stopId]?.cancel();
          _undoTimers[e.stopId] = Timer(_undoWindow, () {
            if (!isClosed) add(StopDeleteUndoExpired(e.stopId));
          });
        }
      } catch (err) {
        // Server delete failed — revert the optimistic state AND drop the
        // pending undo (the row's still on the server, nothing to undo).
        final cleared = Map<String, UndoStopRecord>.from(state.pendingUndoStops)
          ..remove(e.stopId);
        emit(_revertTrip(state, e.tripId, optimistic, trip, err).copyWith(
          pendingStopIds: state.pendingStopIds.difference({e.stopId}),
          pendingUndoStops: cleared,
        ));
      }
    });
  }

  /// User tapped UNDO inside the 5s window. Look up the record, cancel
  /// the expiry timer, and dispatch a normal [StopAddRequested] so the
  /// optimistic insert + server POST + revert-on-failure machinery is
  /// reused verbatim.
  void _onStopDeleteUndo(
    StopDeleteUndoRequested e,
    Emitter<TripsState> emit,
  ) {
    final record = state.pendingUndoStops[e.stopId];
    if (record == null) return;
    _undoTimers.remove(e.stopId)?.cancel();
    final cleared = Map<String, UndoStopRecord>.from(state.pendingUndoStops)
      ..remove(e.stopId);
    emit(state.copyWith(pendingUndoStops: cleared));
    add(StopAddRequested(
      record.tripId,
      record.dayId,
      record.body,
      sortOrder: record.originalSortOrder,
    ));
  }

  /// 5-second timer fired without an UNDO tap. The stop is gone for good
  /// (server already accepted the DELETE); we just clear the banner.
  void _onStopDeleteUndoExpired(
    StopDeleteUndoExpired e,
    Emitter<TripsState> emit,
  ) {
    if (!state.pendingUndoStops.containsKey(e.stopId)) return;
    _undoTimers.remove(e.stopId);
    final cleared = Map<String, UndoStopRecord>.from(state.pendingUndoStops)
      ..remove(e.stopId);
    emit(state.copyWith(pendingUndoStops: cleared));
  }

  /// Build a `TripStopCreateBody`-shaped map from an existing stop so the
  /// undo path can re-POST it. Mirrors `ItineraryDraft.toCreateJson`'s
  /// kind / transportation coercion (Pydantic's Literal rejects
  /// `unknown`). Excludes `id`, `sort_order`, `completed_at`, and any
  /// server-enriched fields (photos, formatted_address, rating).
  static Map<String, dynamic> _undoBodyFromStop(TripStop stop) {
    final kindStr =
        stop.kind == StopKind.unknown ? 'activity' : stop.kind.name;
    final transportStr =
        (stop.transportation == null ||
                stop.transportation == TransportationKind.unknown)
            ? null
            : stop.transportation!.name;
    return <String, dynamic>{
      'name': stop.name,
      'kind': kindStr,
      if (stop.city != null && stop.city!.isNotEmpty) 'city': stop.city,
      if (stop.address != null && stop.address!.isNotEmpty)
        'address': stop.address,
      if (stop.durationMinutes != null)
        'duration_minutes': stop.durationMinutes,
      if (stop.arrivalTime != null) 'arrival_time': stop.arrivalTime,
      if (stop.endTime != null) 'end_time': stop.endTime,
      if (transportStr != null) 'transportation': transportStr,
      if (stop.notes != null && stop.notes!.isNotEmpty) 'notes': stop.notes,
      if (stop.lat != null) 'lat': stop.lat,
      if (stop.lng != null) 'lng': stop.lng,
    };
  }

  Future<void> _onStopsReorder(
    StopsReorderRequested e,
    Emitter<TripsState> emit,
  ) async {
    await _serializeOnDay(e.tripId, e.dayId, () async {
      final prev = state.trips;
      final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
      if (tripIdx == -1) return;
      final trip = prev[tripIdx];
      final dayIdx = trip.days.indexWhere((d) => d.id == e.dayId);
      if (dayIdx == -1) return;
      final day = trip.days[dayIdx];
      final byId = {for (final s in day.stops) s.id: s};
      if (e.orderedStopIds.length != day.stops.length ||
          !e.orderedStopIds.every(byId.containsKey)) {
        return;
      }
      // Optimistic preview: slot-anchor times to position so the user sees
      // a believable intermediate state during the round-trip. The server
      // is the authoritative re-scheduler (recompute_times=true below),
      // and its response replaces these placeholder times with forward-
      // walked realistic ones a few hundred ms later.
      final newStops = <TripStop>[
        for (var i = 0; i < e.orderedStopIds.length; i++)
          byId[e.orderedStopIds[i]]!.copyWith(
            sortOrder: i,
            arrivalTime: day.stops[i].arrivalTime,
            endTime: day.stops[i].endTime,
            durationMinutes: day.stops[i].durationMinutes,
          ),
      ];
      final updatedDay = day.copyWith(stops: newStops);
      final optimistic = trip.copyWith(
        days: [...trip.days]..[dayIdx] = updatedDay,
      );
      emit(state.copyWith(
        trips: [...prev]..[tripIdx] = optimistic,
        pendingDayIds: {...state.pendingDayIds, e.dayId},
      ));
      // Payload omits per-position time fields: with recomputeTimes:true,
      // the server discards them and forward-walks instead. Refine tools
      // (LLM-driven reorders) still send explicit times by setting
      // recomputeTimes:false.
      final order = [
        for (var i = 0; i < e.orderedStopIds.length; i++)
          {
            'stop_id': e.orderedStopIds[i],
            'sort_order': i,
          },
      ];
      try {
        final server = await _service.reorderStops(
          e.tripId,
          e.dayId,
          order,
          bearerToken: _tokenReader(),
          recomputeTimes: true,
        );
        emit(state.copyWith(
          trips: _withTrip(state.trips, server),
          pendingDayIds: state.pendingDayIds.difference({e.dayId}),
        ));
      } catch (err) {
        emit(_revertTrip(state, e.tripId, optimistic, trip, err)
            .copyWith(pendingDayIds: state.pendingDayIds.difference({e.dayId})));
      }
    });
  }

  Future<void> _onStopMoveToDay(
    StopMoveToDayRequested e,
    Emitter<TripsState> emit,
  ) async {
    // Lock both source and target days so a concurrent reorder/edit/delete
    // on either side waits its turn — without this, a same-tick reorder on
    // the source day could race with the optimistic emit below and corrupt
    // sortOrder. Backend serializes via the request itself, but the optimistic
    // state needs the same guarantee or the user briefly sees a wrong order.
    await _serializeOnDays(e.tripId, {e.sourceDayId, e.targetDayId}, () async {
      final prev = state.trips;
      final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
      if (tripIdx == -1) return;
      final trip = prev[tripIdx];
      final sourceIdx = trip.days.indexWhere((d) => d.id == e.sourceDayId);
      final targetIdx = trip.days.indexWhere((d) => d.id == e.targetDayId);
      if (sourceIdx == -1 || targetIdx == -1 || sourceIdx == targetIdx) {
        return;
      }
      final source = trip.days[sourceIdx];
      final target = trip.days[targetIdx];
      final movingIdx = source.stops.indexWhere((s) => s.id == e.stopId);
      if (movingIdx == -1) return;
      final moving = source.stops[movingIdx];

      final newSource = <TripStop>[
        for (var i = 0; i < source.stops.length; i++)
          if (i < movingIdx)
            source.stops[i].copyWith(sortOrder: i)
          else if (i > movingIdx)
            source.stops[i].copyWith(sortOrder: i - 1),
      ];

      final insertAt = (e.sortOrder == null || e.sortOrder! >= target.stops.length)
          ? target.stops.length
          : math.max(0, e.sortOrder!);
      final newTarget = <TripStop>[
        ...target.stops.sublist(0, insertAt),
        moving,
        ...target.stops.sublist(insertAt),
      ]
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(sortOrder: entry.key))
          .toList(growable: false);

      final updatedDays = [...trip.days];
      updatedDays[sourceIdx] = source.copyWith(stops: newSource);
      updatedDays[targetIdx] = target.copyWith(stops: newTarget);
      final optimistic = trip.copyWith(days: updatedDays);
      emit(state.copyWith(
        trips: [...prev]..[tripIdx] = optimistic,
        pendingDayIds: {
          ...state.pendingDayIds,
          e.sourceDayId,
          e.targetDayId,
        },
        pendingStopIds: {...state.pendingStopIds, e.stopId},
      ));
      try {
        // recomputeTimes:true forward-walks the destination day's times so
        // the moved stop fits the day's path; autoPosition lets the server
        // pick a geographically-best insertion index when the user didn't
        // specify one (the "Move to day" sheet leaves sortOrder null).
        final server = await _service.moveStop(
          e.tripId,
          e.stopId,
          targetDayId: e.targetDayId,
          sortOrder: e.sortOrder,
          bearerToken: _tokenReader(),
          recomputeTimes: true,
          autoPosition: e.sortOrder == null,
        );
        emit(state.copyWith(
          trips: _withTrip(state.trips, server),
          pendingDayIds: state.pendingDayIds
              .difference({e.sourceDayId, e.targetDayId}),
          pendingStopIds: state.pendingStopIds.difference({e.stopId}),
        ));
      } catch (err) {
        emit(_revertTrip(state, e.tripId, optimistic, trip, err).copyWith(
          pendingDayIds: state.pendingDayIds
              .difference({e.sourceDayId, e.targetDayId}),
          pendingStopIds: state.pendingStopIds.difference({e.stopId}),
        ));
      }
    });
  }

  Future<void> _onDayAdd(DayAddRequested e, Emitter<TripsState> emit) async {
    final prev = state.trips;
    final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
    if (tripIdx == -1) return;
    final trip = prev[tripIdx];
    final tempDay = TripDay(
      id: '__pending-${DateTime.now().microsecondsSinceEpoch}',
      dayNumber: e.dayNumber,
      title: e.title,
      baseCity: e.baseCity,
      stops: const [],
    );
    final newDays = [...trip.days, tempDay]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    final optimistic = trip.copyWith(days: newDays);
    emit(state.copyWith(
      trips: [...prev]..[tripIdx] = optimistic,
      pendingTripIds: {...state.pendingTripIds, e.tripId},
    ));
    try {
      final body = <String, dynamic>{'day_number': e.dayNumber};
      if (e.title != null) body['title'] = e.title;
      if (e.baseCity != null) body['base_city'] = e.baseCity;
      final server = await _service.addDay(
        e.tripId,
        body,
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingTripIds: state.pendingTripIds.difference({e.tripId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, e.tripId, optimistic, trip, err)
          .copyWith(pendingTripIds: state.pendingTripIds.difference({e.tripId})));
    }
  }

  Future<void> _onDayDelete(
    DayDeleteRequested e,
    Emitter<TripsState> emit,
  ) async {
    final prev = state.trips;
    final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
    if (tripIdx == -1) return;
    final trip = prev[tripIdx];
    final newDays = trip.days
        .where((d) => d.id != e.dayId)
        .toList(growable: false);
    if (newDays.length == trip.days.length) return;
    final optimistic = trip.copyWith(days: newDays);
    emit(state.copyWith(
      trips: [...prev]..[tripIdx] = optimistic,
      pendingDayIds: {...state.pendingDayIds, e.dayId},
    ));
    try {
      final server = await _service.deleteDay(
        e.tripId,
        e.dayId,
        bearerToken: _tokenReader(),
      );
      emit(state.copyWith(
        trips: _withTrip(state.trips, server),
        pendingDayIds: state.pendingDayIds.difference({e.dayId}),
      ));
    } catch (err) {
      emit(_revertTrip(state, e.tripId, optimistic, trip, err)
          .copyWith(pendingDayIds: state.pendingDayIds.difference({e.dayId})));
    }
  }

  Future<void> _onDayMetaUpdate(
    DayMetaUpdateRequested e,
    Emitter<TripsState> emit,
  ) async {
    if (e.patch.isEmpty) return;
    await _serializeOnDay(e.tripId, e.dayId, () async {
      final prev = state.trips;
      final tripIdx = prev.indexWhere((t) => t.id == e.tripId);
      if (tripIdx == -1) return;
      final trip = prev[tripIdx];
      final dayIdx = trip.days.indexWhere((d) => d.id == e.dayId);
      if (dayIdx == -1) return;
      final day = trip.days[dayIdx];
      final updatedDay = day.copyWith(
        title: e.patch.containsKey('title')
            ? e.patch['title'] as String?
            : day.title,
        baseCity: e.patch.containsKey('base_city')
            ? e.patch['base_city'] as String?
            : day.baseCity,
      );
      final optimistic = trip.copyWith(
        days: [...trip.days]..[dayIdx] = updatedDay,
      );
      emit(state.copyWith(
        trips: [...prev]..[tripIdx] = optimistic,
        pendingDayIds: {...state.pendingDayIds, e.dayId},
      ));
      try {
        final server = await _service.updateDay(
          e.tripId,
          e.dayId,
          e.patch,
          bearerToken: _tokenReader(),
        );
        emit(state.copyWith(
          trips: _withTrip(state.trips, server),
          pendingDayIds: state.pendingDayIds.difference({e.dayId}),
        ));
      } catch (err) {
        emit(_revertTrip(state, e.tripId, optimistic, trip, err)
            .copyWith(pendingDayIds: state.pendingDayIds.difference({e.dayId})));
      }
    });
  }

  void _onErrorDismissed(ErrorDismissed e, Emitter<TripsState> emit) {
    if (state.lastError != null) emit(state.copyWith(lastError: null));
  }

  void _onErrorSurfaced(TripsErrorSurfaced e, Emitter<TripsState> emit) {
    emit(state.copyWith(lastError: e.message));
  }

  // ---- internals ----

  /// Chain ops on the same `(tripId, dayId)` so the server never sees two
  /// concurrent ops on the same day. Different days run in parallel; failures
  /// of the prior op don't block subsequent ops — they observe the
  /// post-revert state and proceed. Direct port of `TripsLogic._serializeOnDay`.
  Future<void> _serializeOnDay(
    String tripId,
    String dayId,
    Future<void> Function() task,
  ) async {
    final key = '$tripId#$dayId';
    final prior = _dayInflight[key];
    final completer = Completer<void>();
    _dayInflight[key] = completer.future;
    try {
      if (prior != null) {
        try {
          await prior;
        } catch (_) {
          // ignore — the prior op handled its own error
        }
      }
      await task();
    } finally {
      completer.complete();
      if (_dayInflight[key] == completer.future) {
        _dayInflight.remove(key);
      }
    }
  }

  /// Multi-day variant of [_serializeOnDay]. Waits for any in-flight op on
  /// every passed day to settle, then locks all of them for the task's
  /// duration. Used by cross-day moves so neither side can race during the
  /// optimistic emit + server call. Dart's single-threaded model means the
  /// atomic key registration before any await is enough to avoid deadlock —
  /// every concurrent waiter sees the same future and just waits.
  Future<void> _serializeOnDays(
    String tripId,
    Set<String> dayIds,
    Future<void> Function() task,
  ) async {
    final keys = [for (final d in dayIds) '$tripId#$d'];
    final priors = [for (final k in keys) _dayInflight[k]];
    final completer = Completer<void>();
    for (final k in keys) {
      _dayInflight[k] = completer.future;
    }
    try {
      for (final p in priors) {
        if (p == null) continue;
        try {
          await p;
        } catch (_) {
          // prior op handled its own error
        }
      }
      await task();
    } finally {
      completer.complete();
      for (final k in keys) {
        if (_dayInflight[k] == completer.future) {
          _dayInflight.remove(k);
        }
      }
    }
  }

  static List<Trip> _withTrip(List<Trip> trips, Trip updated) => trips
      .map((t) => t.id == updated.id ? updated : t)
      .toList(growable: false);

  /// Equality-guarded revert: only restore `original` if the trip at
  /// `tripId` is still our optimistic guess. Newer edits in between are
  /// preserved. Mirrors `TripsLogic._revertTrip`.
  static TripsState _revertTrip(
    TripsState state,
    String tripId,
    Trip optimistic,
    Trip original,
    Object err,
  ) {
    final after = state.trips;
    final i = after.indexWhere((t) => t.id == tripId);
    final next = (i != -1 && after[i] == optimistic)
        ? ([...after]..[i] = original)
        : after;
    return state.copyWith(trips: next, lastError: mapTripsError(err));
  }

  static TripStop _applyPatchToStop(TripStop stop, Map<String, dynamic> patch) {
    return TripStop(
      id: stop.id,
      sortOrder: stop.sortOrder,
      name: patch.containsKey('name') && patch['name'] != null
          ? patch['name'] as String
          : stop.name,
      kind: patch.containsKey('kind') && patch['kind'] != null
          ? stopKindFromString(patch['kind'] as String?)
          : stop.kind,
      city: patch.containsKey('city')
          ? patch['city'] as String?
          : stop.city,
      address: patch.containsKey('address')
          ? patch['address'] as String?
          : stop.address,
      durationMinutes: patch.containsKey('duration_minutes')
          ? (patch['duration_minutes'] as num?)?.toInt()
          : stop.durationMinutes,
      arrivalTime: patch.containsKey('arrival_time')
          ? patch['arrival_time'] as String?
          : stop.arrivalTime,
      endTime: patch.containsKey('end_time')
          ? patch['end_time'] as String?
          : stop.endTime,
      transportation: patch.containsKey('transportation')
          ? transportationKindFromString(patch['transportation'] as String?)
          : stop.transportation,
      notes: patch.containsKey('notes')
          ? patch['notes'] as String?
          : stop.notes,
      lat: patch.containsKey('lat')
          ? (patch['lat'] as num?)?.toDouble()
          : stop.lat,
      lng: patch.containsKey('lng')
          ? (patch['lng'] as num?)?.toDouble()
          : stop.lng,
      // Server-enriched fields (photo, rating, address) are read-only here —
      // optimistic edits never include them, so preserve from the original.
      photoUrl: stop.photoUrl,
      rating: stop.rating,
      formattedAddress: stop.formattedAddress,
    );
  }
}
