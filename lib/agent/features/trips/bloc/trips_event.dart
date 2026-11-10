import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:travel_buddy/agent/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';

abstract class TripsEvent extends Equatable {
  const TripsEvent();

  @override
  List<Object?> get props => const [];
}

/// Marker for events that mutate within a specific (trip, day). The bloc
/// serializes these per-key so the server never sees concurrent ops on the
/// same day; different days run in parallel.
abstract class TripsDayScopedEvent extends TripsEvent {
  const TripsDayScopedEvent();

  String get tripId;
  String get dayId;
}

class LoadAllRequested extends TripsEvent {
  const LoadAllRequested();
}

/// Fetch the next page of `GET /trips` using `state.nextCursor`. Idempotent:
/// no-ops if `!hasMore || isLoadingMore || nextCursor == null`. The infinite-
/// scroll handler in `MyTripsScreen` dispatches this on near-bottom scroll.
class TripsLoadMoreRequested extends TripsEvent {
  const TripsLoadMoreRequested();
}

class TripCleared extends TripsEvent {
  const TripCleared();
}

class TripMerged extends TripsEvent {
  const TripMerged(this.trip);
  final Trip trip;

  @override
  List<Object?> get props => [trip];
}

/// Persist a streamed itinerary as a real trip. Pass a [completer] if the
/// caller awaits the saved [Trip] (the chat-itinerary save button does).
/// [assistantMessageId] is the id of the assistant ChatMessage that emitted
/// this draft — TripsBloc forwards it through `BuddySavedTripLinked` so the
/// chat bubble can resolve and render the saved trip's static-map thumbnail.
class ItinerarySaveRequested extends TripsEvent {
  const ItinerarySaveRequested(
    this.draft, {
    required this.assistantMessageId,
    this.userPickedStartDate,
    this.completer,
  });

  final ItineraryDraft draft;
  final String assistantMessageId;
  final DateTime? userPickedStartDate;
  final Completer<Trip>? completer;

  @override
  List<Object?> get props =>
      [draft, assistantMessageId, userPickedStartDate, completer];
}

class TripRenameRequested extends TripsEvent {
  const TripRenameRequested(this.tripId, this.newTitle);
  final String tripId;
  final String newTitle;

  @override
  List<Object?> get props => [tripId, newTitle];
}

class TripSummaryUpdateRequested extends TripsEvent {
  const TripSummaryUpdateRequested(this.tripId, this.newSummary);
  final String tripId;
  final String? newSummary;

  @override
  List<Object?> get props => [tripId, newSummary];
}

class TripStartDateUpdateRequested extends TripsEvent {
  const TripStartDateUpdateRequested(this.tripId, {this.startDate, this.clear = false});
  final String tripId;
  final DateTime? startDate;
  final bool clear;

  @override
  List<Object?> get props => [tripId, startDate, clear];
}

class TripDeleteRequested extends TripsEvent {
  const TripDeleteRequested(this.tripId);
  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

/// User-initiated "Clear all trips" from MyTrips. Distinct from [TripCleared],
/// which only wipes the local cache on sign-out. This one fans out server
/// deletes and rolls back the optimistic empty state if any call fails.
class TripClearAllRequested extends TripsEvent {
  const TripClearAllRequested();
}

class StopEditRequested extends TripsEvent {
  const StopEditRequested(this.tripId, this.dayId, this.stopId, this.patch);
  final String tripId;
  final String dayId;
  final String stopId;
  final Map<String, dynamic> patch;

  @override
  List<Object?> get props => [tripId, dayId, stopId, patch];
}

/// Mark a stop visited. Optimistic + revert-on-failure, same shape as
/// [StopEditRequested]. `source` is informational ('auto' from
/// VisitDetectorBloc, 'manual' from the rail-node popover) so future
/// analytics can split confidence by origin.
class StopVisitMarkRequested extends TripsEvent {
  const StopVisitMarkRequested({
    required this.tripId,
    required this.dayId,
    required this.stopId,
    required this.visitedAt,
    required this.source,
  });
  final String tripId;
  final String dayId;
  final String stopId;
  final DateTime visitedAt;
  final String source; // 'auto' | 'manual'

  @override
  List<Object?> get props => [tripId, dayId, stopId, visitedAt, source];
}

/// Clear a stop's visited timestamp. Used by the "Reset to upcoming"
/// menu item on the rail-node popover.
class StopVisitResetRequested extends TripsEvent {
  const StopVisitResetRequested({
    required this.tripId,
    required this.dayId,
    required this.stopId,
  });
  final String tripId;
  final String dayId;
  final String stopId;

  @override
  List<Object?> get props => [tripId, dayId, stopId];
}

class StopAddRequested extends TripsDayScopedEvent {
  const StopAddRequested(this.tripId, this.dayId, this.stopBody, {this.sortOrder});

  @override
  final String tripId;
  @override
  final String dayId;
  final Map<String, dynamic> stopBody;
  final int? sortOrder;

  @override
  List<Object?> get props => [tripId, dayId, stopBody, sortOrder];
}

class StopDeleteRequested extends TripsDayScopedEvent {
  const StopDeleteRequested(this.tripId, this.dayId, this.stopId);

  @override
  final String tripId;
  @override
  final String dayId;
  final String stopId;

  @override
  List<Object?> get props => [tripId, dayId, stopId];
}

/// Inline-undo dispatch for a just-deleted stop. Looks up the matching
/// `UndoStopRecord` in `state.pendingUndoStops`, cancels the bloc's expiry
/// timer, and re-creates the stop via [StopAddRequested] at the original
/// position. The recreated stop gets a NEW server id; `completed_at` and
/// any external references to the original id are lost.
class StopDeleteUndoRequested extends TripsEvent {
  const StopDeleteUndoRequested(this.stopId);
  final String stopId;

  @override
  List<Object?> get props => [stopId];
}

/// Internal: emitted by the bloc's 5s timer to clear an expired undo
/// record. Not for external dispatch — kept here so tests can `add()` it
/// to simulate timer expiry without waiting.
class StopDeleteUndoExpired extends TripsEvent {
  const StopDeleteUndoExpired(this.stopId);
  final String stopId;

  @override
  List<Object?> get props => [stopId];
}

class StopsReorderRequested extends TripsDayScopedEvent {
  const StopsReorderRequested(this.tripId, this.dayId, this.orderedStopIds);

  @override
  final String tripId;
  @override
  final String dayId;
  final List<String> orderedStopIds;

  @override
  List<Object?> get props => [tripId, dayId, orderedStopIds];
}

/// Move a stop to a different day in the same trip, preserving `stop.id`,
/// times, completed_at, and any enrichment. Serialized on BOTH source and
/// target day ids so a concurrent edit on either side waits its turn.
/// `sortOrder` omitted appends; pass a non-null value to insert at a
/// position (shifts existing target stops up by one).
class StopMoveToDayRequested extends TripsEvent {
  const StopMoveToDayRequested({
    required this.tripId,
    required this.sourceDayId,
    required this.targetDayId,
    required this.stopId,
    this.sortOrder,
  });
  final String tripId;
  final String sourceDayId;
  final String targetDayId;
  final String stopId;
  final int? sortOrder;

  @override
  List<Object?> get props =>
      [tripId, sourceDayId, targetDayId, stopId, sortOrder];
}

class DayAddRequested extends TripsEvent {
  const DayAddRequested(this.tripId, this.dayNumber, {this.title, this.baseCity});
  final String tripId;
  final int dayNumber;
  final String? title;
  final String? baseCity;

  @override
  List<Object?> get props => [tripId, dayNumber, title, baseCity];
}

class DayDeleteRequested extends TripsEvent {
  const DayDeleteRequested(this.tripId, this.dayId);
  final String tripId;
  final String dayId;

  @override
  List<Object?> get props => [tripId, dayId];
}

/// Patch a day's metadata. `patch` mirrors the backend's
/// `TripDayUpdate.model_dump(exclude_unset=True)`: present keys with null
/// clear the column, absent keys leave it untouched. Keys are snake_case
/// to match the wire — `title`, `base_city`. Empty patch is a no-op.
class DayMetaUpdateRequested extends TripsEvent {
  const DayMetaUpdateRequested(this.tripId, this.dayId, this.patch);
  final String tripId;
  final String dayId;
  final Map<String, dynamic> patch;

  @override
  List<Object?> get props => [tripId, dayId, patch];
}

class ErrorDismissed extends TripsEvent {
  const ErrorDismissed();
}

/// Surface a banner-worthy message that originated outside the bloc (e.g.
/// BuddyBloc dispatching when a streamed trip-update references a deleted
/// trip, or the detail screen's local "day number already exists" guard).
class TripsErrorSurfaced extends TripsEvent {
  const TripsErrorSurfaced(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
