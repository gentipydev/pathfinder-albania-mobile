import 'package:equatable/equatable.dart';
import 'package:travel_buddy/agent/domain/entities/trip_stop.dart';

/// Server-acknowledged day with its ordered stops.
class TripDay extends Equatable {
  const TripDay({
    required this.id,
    required this.dayNumber,
    required this.stops,
    this.title,
    this.baseCity,
  });

  final String id;
  final int dayNumber;
  final String? title;
  final String? baseCity;
  final List<TripStop> stops;

  factory TripDay.fromJson(Map<String, dynamic> json) {
    final raw = json['day_number'];
    final dayNumber = raw is int ? raw : int.tryParse('$raw') ?? 1;
    return TripDay(
      id: (json['id'] as String?) ?? '',
      dayNumber: dayNumber < 1 ? 1 : dayNumber,
      title: json['title'] as String?,
      baseCity: json['base_city'] as String?,
      // Sort by sortOrder so callers can iterate by index without re-sorting.
      // Defends against a backend quirk where a fresh PATCH/reorder response
      // can return stops in DB-insertion order with the new sort_order set
      // on each row — array order would mismatch the new sort_order.
      stops: (json['stops'] is List)
          ? ((json['stops'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map(TripStop.fromJson)
                  .toList(growable: false)
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
          : const [],
    );
  }

  TripDay copyWith({
    String? id,
    int? dayNumber,
    Object? title = _sentinel,
    Object? baseCity = _sentinel,
    List<TripStop>? stops,
  }) {
    return TripDay(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      title: identical(title, _sentinel) ? this.title : title as String?,
      baseCity: identical(baseCity, _sentinel)
          ? this.baseCity
          : baseCity as String?,
      stops: stops ?? this.stops,
    );
  }

  @override
  List<Object?> get props => [id, dayNumber, title, baseCity, stops];
}

const _sentinel = Object();
