import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_day.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_stop.dart';
import 'package:pathfinder_albania/agent/logic/buddy/live_stop.dart';

/// Id of the synthetic [Trip] assembled from `itinerary_stop` frames while a
/// plan is still streaming. Never persisted and never sent to the server — it
/// exists only so the live preview can reuse `TripMapScreen`, which speaks
/// [Trip]. A real saved trip carries a server UUID, so this constant can never
/// collide with one.
const String kLiveTripId = 'live';

/// Epoch placeholder for the live trip's timestamps. [Trip] requires them; a
/// preview has no server-assigned created/updated moment, and nothing in the
/// map path reads them.
final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

Trip emptyLiveTrip() => Trip(
      id: kLiveTripId,
      title: '',
      days: const [],
      routes: const [],
      createdAt: _epoch,
      updatedAt: _epoch,
    );

/// Folds one streamed [LiveStop] into the in-progress [Trip], creating its day
/// on first sight. Idempotent on stop id: a re-sent frame replaces the existing
/// stop rather than duplicating the marker.
///
/// Passing a [trip] that isn't the live trip (or null) starts a fresh one, so a
/// stray stop can never graft itself onto a saved itinerary.
Trip appendLiveStop(Trip? trip, LiveStop stop) {
  final base = (trip != null && trip.id == kLiveTripId) ? trip : emptyLiveTrip();
  final days = base.days
      .map((d) => d.copyWith(stops: List<TripStop>.of(d.stops)))
      .toList();

  var dayIndex = days.indexWhere((d) => d.dayNumber == stop.dayNumber);
  if (dayIndex < 0) {
    days.add(TripDay(
      // Must match the `live-day-{n}` ids the backend stamps on
      // `itinerary_routes` legs, or the map can't attribute a leg to its day.
      id: 'live-day-${stop.dayNumber}',
      dayNumber: stop.dayNumber,
      title: stop.dayTitle,
      stops: const [],
    ));
    days.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    dayIndex = days.indexWhere((d) => d.dayNumber == stop.dayNumber);
  } else if (days[dayIndex].title == null && stop.dayTitle != null) {
    // Day titles can arrive on any stop of that day, not just the first.
    days[dayIndex] = days[dayIndex].copyWith(title: stop.dayTitle);
  }

  final day = days[dayIndex];
  final stops = List<TripStop>.of(day.stops);
  final tripStop = TripStop(
    id: stop.id,
    sortOrder: stop.sortOrder,
    name: stop.name,
    kind: stop.kind,
    city: stop.city,
    notes: stop.description,
    lat: stop.lat,
    lng: stop.lng,
  );
  final existing = stops.indexWhere((s) => s.id == tripStop.id);
  if (existing >= 0) {
    stops[existing] = tripStop;
  } else {
    stops.add(tripStop);
    stops.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  days[dayIndex] = day.copyWith(stops: stops);

  // The map header shows `trip.title`. Until the `itinerary` frame lands with
  // Claude's real title, the streamed city is the most truthful label we have.
  final title = base.title.isNotEmpty ? base.title : (stop.city?.trim() ?? '');
  return base.copyWith(days: days, title: title);
}

/// Fallback for when per-stop streaming surfaced nothing mappable but the
/// `itinerary` frame still arrived: flattens the draft into the same row shape
/// the live list renders, so the structured plan shows either way.
///
/// Chat-list only. These carry the draft's coordinates, which may be absent —
/// the map's own fallback is the server-geocoded `itinerary_preview` frame.
List<LiveStop> liveStopsFromDraft(ItineraryDraft draft) {
  final out = <LiveStop>[];
  var index = 0;
  for (final day in draft.days) {
    for (var i = 0; i < day.stops.length; i++) {
      final s = day.stops[i];
      index++;
      out.add(LiveStop(
        id: 'live-${day.dayNumber}-$i',
        index: index,
        dayNumber: day.dayNumber,
        dayTitle: day.title,
        sortOrder: i,
        name: s.name,
        kind: s.kind,
        city: s.city,
        description: s.notes,
        lat: s.lat ?? 0,
        lng: s.lng ?? 0,
      ));
    }
  }
  return out;
}
