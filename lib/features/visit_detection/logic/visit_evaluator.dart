import 'dart:math' as math;

import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/domain/entities/trip_stop.dart';

/// Pure-Dart visit detection. No Flutter / geolocator imports so it's
/// trivially testable with synthetic coordinates and times.
///
/// A stop is a visit candidate when ALL of:
///   - `stop.completedAt` is null (not already visited),
///   - `stop.lat` and `stop.lng` are set,
///   - the trip has a `startDate` so the stop's wall-clock window resolves,
///   - `now` is inside `[arrival - timeSlack, end + timeSlack]`
///     (default 90 min slack on each side),
///   - the user's position is within `radiusMeters` (default 150 m) of
///     the stop's coordinates.
///
/// The slack is wider than the UI's 15-min "current" highlight because
/// the user may arrive early or stay late — we want to credit the visit
/// even if the schedule is off.

class VisitCandidate {
  const VisitCandidate({
    required this.dayId,
    required this.stopId,
    required this.detectedAt,
    required this.distanceMeters,
  });
  final String dayId;
  final String stopId;
  final DateTime detectedAt;
  final double distanceMeters;
}

class VisitEvaluatorPosition {
  const VisitEvaluatorPosition({
    required this.latitude,
    required this.longitude,
  });
  final double latitude;
  final double longitude;
}

Iterable<VisitCandidate> evaluateVisits({
  required Trip trip,
  required VisitEvaluatorPosition pos,
  required DateTime now,
  double radiusMeters = 150,
  Duration timeSlack = const Duration(minutes: 90),
}) sync* {
  for (final day in trip.days) {
    for (final stop in day.stops) {
      if (stop.completedAt != null) continue;
      final lat = stop.lat;
      final lng = stop.lng;
      if (lat == null || lng == null) continue;
      final start = deriveStopStartDateTime(
        tripStartDate: trip.startDate,
        dayNumber: day.dayNumber,
        arrivalTime: stop.arrivalTime,
      );
      if (start == null) continue;
      final end = deriveStopEndDateTime(
            tripStartDate: trip.startDate,
            dayNumber: day.dayNumber,
            endTime: stop.endTime,
          ) ??
          start.add(const Duration(hours: 1));
      if (now.isBefore(start.subtract(timeSlack))) continue;
      if (now.isAfter(end.add(timeSlack))) continue;
      final meters = haversineMeters(
        lat1: pos.latitude,
        lon1: pos.longitude,
        lat2: lat,
        lon2: lng,
      );
      if (meters > radiusMeters) continue;
      yield VisitCandidate(
        dayId: day.id,
        stopId: stop.id,
        detectedAt: now,
        distanceMeters: meters,
      );
    }
  }
}

/// Great-circle distance between two WGS-84 points in meters. Used here
/// (rather than `Geolocator.distanceBetween`) so the file has zero
/// platform-channel dependencies and can be unit-tested without a Flutter
/// binding. Accuracy is ~50 cm at the radii (≤ a few km) we care about.
double haversineMeters({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const earthRadiusM = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusM * c;
}

double _toRad(double deg) => deg * (math.pi / 180.0);
