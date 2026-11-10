import 'package:equatable/equatable.dart';

/// Server-acknowledged route segment between two stops on the same day.
/// Carries the encoded polyline ready for `flutter_polyline_points` decode
/// (PR 3) and the travel mode the backend planner picked. Per-leg distance
/// and duration are optional — older or partially-enriched trips may omit
/// them.
class TripRoute extends Equatable {
  const TripRoute({
    required this.id,
    required this.tripDayId,
    required this.fromStopId,
    required this.toStopId,
    required this.encodedPolyline,
    required this.travelMode,
    this.distanceMeters,
    this.durationSeconds,
  });

  final String id;
  final String tripDayId;
  final String fromStopId;
  final String toStopId;
  final String encodedPolyline;

  /// 'driving' or 'walking'. Backend defaults to 'driving' when missing.
  final String travelMode;
  final int? distanceMeters;
  final int? durationSeconds;

  factory TripRoute.fromJson(Map<String, dynamic> json) {
    return TripRoute(
      id: (json['id'] as String?) ?? '',
      tripDayId: (json['trip_day_id'] as String?) ?? '',
      fromStopId: (json['from_stop_id'] as String?) ?? '',
      toStopId: (json['to_stop_id'] as String?) ?? '',
      encodedPolyline: (json['encoded_polyline'] as String?) ?? '',
      travelMode: (json['travel_mode'] as String?) ?? 'driving',
      distanceMeters: (json['distance_meters'] as num?)?.toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_day_id': tripDayId,
        'from_stop_id': fromStopId,
        'to_stop_id': toStopId,
        'encoded_polyline': encodedPolyline,
        'travel_mode': travelMode,
        if (distanceMeters != null) 'distance_meters': distanceMeters,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      };

  TripRoute copyWith({
    String? id,
    String? tripDayId,
    String? fromStopId,
    String? toStopId,
    String? encodedPolyline,
    String? travelMode,
    Object? distanceMeters = _sentinel,
    Object? durationSeconds = _sentinel,
  }) {
    return TripRoute(
      id: id ?? this.id,
      tripDayId: tripDayId ?? this.tripDayId,
      fromStopId: fromStopId ?? this.fromStopId,
      toStopId: toStopId ?? this.toStopId,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      travelMode: travelMode ?? this.travelMode,
      distanceMeters: identical(distanceMeters, _sentinel)
          ? this.distanceMeters
          : distanceMeters as int?,
      durationSeconds: identical(durationSeconds, _sentinel)
          ? this.durationSeconds
          : durationSeconds as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripDayId,
        fromStopId,
        toStopId,
        encodedPolyline,
        travelMode,
        distanceMeters,
        durationSeconds,
      ];
}

const _sentinel = Object();
