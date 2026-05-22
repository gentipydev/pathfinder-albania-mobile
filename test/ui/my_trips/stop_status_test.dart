import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/domain/entities/trip_day.dart';
import 'package:travel_buddy/domain/entities/trip_stop.dart';
import 'package:travel_buddy/ui/screens/my_trips/trip_detail_screen.dart';

/// Pure-function tests for the rail-node status resolver. No widget tree.
void main() {
  // Trip starts 2026-05-21; day 1 = same date.
  final tripStart = DateTime(2026, 5, 21);
  final trip = Trip(
    id: 't1',
    title: 'Test',
    startDate: tripStart,
    days: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  final day = TripDay(id: 'd1', dayNumber: 1, stops: const []);

  TripStop stop({
    String? arrival,
    String? end,
    DateTime? completedAt,
  }) =>
      TripStop(
        id: 's1',
        sortOrder: 0,
        name: 'Skanderbeg',
        kind: StopKind.sight,
        arrivalTime: arrival,
        endTime: end,
        completedAt: completedAt,
      );

  test('completedAt set → visited (regardless of time)', () {
    final s = stop(arrival: '14:00', end: '15:00', completedAt: DateTime.now());
    final now = DateTime(2026, 5, 21, 9, 0); // before window
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: now),
        StopStatus.visited);
  });

  test('trip has no startDate → untimed', () {
    final tripNoDate = Trip(
      id: 't1',
      title: 'Test',
      startDate: null,
      days: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final s = stop(arrival: '14:00', end: '15:00');
    expect(
      stopStatusFor(trip: tripNoDate, day: day, stop: s, now: DateTime.now()),
      StopStatus.untimed,
    );
  });

  test('now well before arrival → upcoming', () {
    final s = stop(arrival: '14:00', end: '15:00');
    final now = DateTime(2026, 5, 21, 10, 0);
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: now),
        StopStatus.upcoming);
  });

  test('now inside window → current', () {
    final s = stop(arrival: '14:00', end: '15:00');
    final now = DateTime(2026, 5, 21, 14, 30);
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: now),
        StopStatus.current);
  });

  test('now within +15 min slack of end → still current', () {
    final s = stop(arrival: '14:00', end: '15:00');
    final now = DateTime(2026, 5, 21, 15, 10);
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: now),
        StopStatus.current);
  });

  test('now well after end → upcoming (past, not visited)', () {
    // Past stops that were never marked visited collapse back to "upcoming"
    // semantics — the rail node renders muted, and long-press still works.
    final s = stop(arrival: '14:00', end: '15:00');
    final now = DateTime(2026, 5, 21, 18, 0);
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: now),
        StopStatus.upcoming);
  });

  test('no endTime → 1h default window', () {
    // arrivalTime only: window is [arrival, arrival + 1h].
    final s = stop(arrival: '14:00');
    final now = DateTime(2026, 5, 21, 14, 45);
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: now),
        StopStatus.current);
    final later = DateTime(2026, 5, 21, 15, 30);
    expect(stopStatusFor(trip: trip, day: day, stop: s, now: later),
        StopStatus.upcoming);
  });

  test('day 2 stop honors dayNumber offset', () {
    final day2 = TripDay(id: 'd2', dayNumber: 2, stops: const []);
    final s = stop(arrival: '09:00', end: '10:00');
    final now = DateTime(2026, 5, 22, 9, 30); // day 2 of trip
    expect(stopStatusFor(trip: trip, day: day2, stop: s, now: now),
        StopStatus.current);
  });
}
