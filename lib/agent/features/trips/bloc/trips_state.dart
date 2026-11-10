import 'package:equatable/equatable.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';

class TripsState extends Equatable {
  const TripsState({
    this.trips = const [],
    this.isLoading = false,
    this.lastError,
    this.pendingStopIds = const {},
    this.pendingDayIds = const {},
    this.pendingTripIds = const {},
    this.pendingUndoStops = const {},
    this.nextCursor,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Trip> trips;
  final bool isLoading;

  /// Either a literal user-facing message OR a key constant from
  /// `TripsErrorKey` (the bloc emits keys; the UI resolves to localized
  /// strings via `$strings.<key>`). Existing callers that pass through raw
  /// service errors keep working — keys are just preferred for new emits.
  final String? lastError;

  /// Per-stop pending markers (`stopId`s of in-flight optimistic edits, adds,
  /// deletes). Drives row-level spinners; replaces the ad-hoc booleans the
  /// detail screen used to keep in `setState`.
  final Set<String> pendingStopIds;
  final Set<String> pendingDayIds;
  final Set<String> pendingTripIds;

  /// Per-deleted-stop undo records, keyed by the deleted stop's id. Lives
  /// for ~5 seconds after a [StopDeleteRequested] commits; the timeline
  /// renders an inline UNDO banner at the deleted slot's position so the
  /// user can recover a misclick without a SnackBar. Cleared by the bloc's
  /// internal expiry timer or by a successful undo dispatch.
  final Map<String, UndoStopRecord> pendingUndoStops;

  /// Opaque cursor for the next page of `GET /trips` (item-6 keyset
  /// pagination). Null after a first fetch returns the last page; reset to
  /// null on every `LoadAllRequested` so refresh starts fresh.
  final String? nextCursor;

  /// True until the backend returns `next_cursor == null`. Starts true so the
  /// first `LoadAllRequested` is always allowed through.
  final bool hasMore;

  /// True while a `TripsLoadMoreRequested` fetch is in flight. Distinct from
  /// `isLoading` (which gates the initial-spinner branch).
  final bool isLoadingMore;

  TripsState copyWith({
    List<Trip>? trips,
    bool? isLoading,
    Object? lastError = _sentinel,
    Set<String>? pendingStopIds,
    Set<String>? pendingDayIds,
    Set<String>? pendingTripIds,
    Map<String, UndoStopRecord>? pendingUndoStops,
    Object? nextCursor = _sentinel,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TripsState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      lastError: identical(lastError, _sentinel)
          ? this.lastError
          : lastError as String?,
      pendingStopIds: pendingStopIds ?? this.pendingStopIds,
      pendingDayIds: pendingDayIds ?? this.pendingDayIds,
      pendingTripIds: pendingTripIds ?? this.pendingTripIds,
      pendingUndoStops: pendingUndoStops ?? this.pendingUndoStops,
      nextCursor: identical(nextCursor, _sentinel)
          ? this.nextCursor
          : nextCursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    trips,
    isLoading,
    lastError,
    pendingStopIds,
    pendingDayIds,
    pendingTripIds,
    pendingUndoStops,
    nextCursor,
    hasMore,
    isLoadingMore,
  ];
}

/// Snapshot of a just-deleted stop, retained for the 5-second undo window.
/// Carries everything needed to (a) render the inline banner at the right
/// position in the timeline and (b) re-create the stop via [StopAddRequested]
/// if the user taps UNDO. The recreated stop gets a NEW id — `completed_at`
/// and any external references to the original id are lost. Acceptable for
/// v1; documented in the inline undo banner copy.
class UndoStopRecord extends Equatable {
  const UndoStopRecord({
    required this.tripId,
    required this.dayId,
    required this.stopId,
    required this.stopName,
    required this.originalSortOrder,
    required this.body,
  });
  final String tripId;
  final String dayId;
  // Original id — used only for keying the banner / inflight timer, NOT for
  // the recreated stop (the server assigns a fresh UUID on POST).
  final String stopId;
  // Cached display name so the banner can read it after the live stop is
  // gone from `trips[]`.
  final String stopName;
  final int originalSortOrder;
  // `TripStopCreateBody`-shaped map ready to be sent via StopAddRequested.
  final Map<String, dynamic> body;

  @override
  List<Object?> get props =>
      [tripId, dayId, stopId, stopName, originalSortOrder, body];
}

const _sentinel = Object();
