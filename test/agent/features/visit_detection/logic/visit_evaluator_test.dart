import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_day.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_stop.dart';
import 'package:pathfinder_albania/agent/features/visit_detection/logic/visit_evaluator.dart';

/// Pure-Dart tests for the visit evaluator. No Flutter binding, no
/// geolocator — synthetic positions only.
void main() {
  // Skanderbeg Square, Tirana — anchor for all positional tests.
  const skanderbergLat = 41.328;
  const skanderbergLng = 19.819;
  // ~50 m east — well within the 150 m default radius.
  const nearbyLat = 41.328;
  const nearbyLng = 19.81960; // ~50m
  // ~5 km north — clearly outside.
  const farLat = 41.378;
  const farLng = 19.819;

  final tripStart = DateTime(2026, 5, 21);

  TripStop stop({
    required String id,
    String arrival = '14:00',
    String end = '15:00',
    double? lat = skanderbergLat,
    double? lng = skanderbergLng,
    DateTime? completedAt,
  }) =>
      TripStop(
        id: id,
        sortOrder: 0,
        name: id,
        kind: StopKind.sight,
        arrivalTime: arrival,
        endTime: end,
        lat: lat,
        lng: lng,
        completedAt: completedAt,
      );

  Trip tripWith(List<TripStop> stops) => Trip(
        id: 't1',
        title: 'Test',
        startDate: tripStart,
        days: [TripDay(id: 'd1', dayNumber: 1, stops: stops)],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  test('yields candidate when within window and within radius', () {
    final trip = tripWith([stop(id: 's1')]);
    final result = evaluateVisits(
      trip: trip,
      pos: const VisitEvaluatorPosition(
          latitude: nearbyLat, longitude: nearbyLng),
      now: DateTime(2026, 5, 21, 14, 30),
    ).toList();
    expect(result, hasLength(1));
    expect(result.first.stopId, 's1');
    expect(result.first.distanceMeters, lessThan(150));
  });

  test('skips when outside radius (5 km away)', () {
    final trip = tripWith([stop(id: 's1')]);
    final result = evaluateVisits(
      trip: trip,
      pos: const VisitEvaluatorPosition(latitude: farLat, longitude: farLng),
      now: DateTime(2026, 5, 21, 14, 30),
    ).toList();
    expect(result, isEmpty);
  });

  test('skips when before window even at the stop', () {
    final trip = tripWith([stop(id: 's1', arrival: '14:00', end: '15:00')]);
    // 4 hours before — past the 90 min slack.
    final result = evaluateVisits(
      trip: trip,
      pos: const VisitEvaluatorPosition(
          latitude: nearbyLat, longitude: nearbyLng),
      now: DateTime(2026, 5, 21, 10, 0),
    ).toList();
    expect(result, isEmpty);
  });

  test('respects time slack (60 min before arrival is still in)', () {
    final trip = tripWith([stop(id: 's1', arrival: '14:00', end: '15:00')]);
    final result = evaluateVisits(
      trip: trip,
      pos: const VisitEvaluatorPosition(
          latitude: nearbyLat, longitude: nearbyLng),
      now: DateTime(2026, 5, 21, 13, 0),
    ).toList();
    expect(result, hasLength(1));
  });

  test('skips already-visited stops (idempotency anchor)', () {
    final trip = tripWith([
      stop(id: 's1', completedAt: DateTime(2026, 5, 21, 14, 30)),
    ]);
    final result = evaluateVisits(
      trip: trip,
      pos: const VisitEvaluatorPosition(
          latitude: nearbyLat, longitude: nearbyLng),
      now: DateTime(2026, 5, 21, 14, 35),
    ).toList();
    expect(result, isEmpty);
  });

  test('skips stops missing lat/lng', () {
    final trip = tripWith([stop(id: 's1', lat: null, lng: null)]);
    final result = evaluateVisits(
      trip: trip,
      pos: const VisitEvaluatorPosition(
          latitude: nearbyLat, longitude: nearbyLng),
      now: DateTime(2026, 5, 21, 14, 30),
    ).toList();
    expect(result, isEmpty);
  });

  test('haversine: 0 distance for identical points', () {
    expect(
      haversineMeters(
        lat1: skanderbergLat,
        lon1: skanderbergLng,
        lat2: skanderbergLat,
        lon2: skanderbergLng,
      ),
      closeTo(0, 0.01),
    );
  });

  test('haversine: ~50 m for a 0.0006° lng offset at this latitude', () {
    final m = haversineMeters(
      lat1: skanderbergLat,
      lon1: skanderbergLng,
      lat2: nearbyLat,
      lon2: nearbyLng,
    );
    expect(m, greaterThan(40));
    expect(m, lessThan(80));
  });
}
