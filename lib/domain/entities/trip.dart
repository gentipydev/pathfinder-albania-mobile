import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/domain/entities/trip_day.dart';
import 'package:travel_buddy/domain/entities/trip_route.dart';

/// Server-acknowledged itinerary returned by `POST /trips` and `GET /trips`.
/// Carries DB IDs and timestamps; days are ordered by `dayNumber`.
class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.title,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    this.startDate,
    this.staticMapUrl,
    this.routes = const [],
  });

  final String id;
  final String title;
  final String? summary;
  final DateTime? startDate;
  final List<TripDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Pre-rendered Google Static Maps URL covering all stops + polylines.
  /// Null when enrichment is unavailable (e.g. backend API key missing or
  /// trip saved before PR 1 deployed).
  final String? staticMapUrl;

  /// Per-leg routes. Empty when the backend planner hasn't computed them
  /// (older trips, walking-only days, or routing quota exhausted).
  final List<TripRoute> routes;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      summary: json['summary'] as String?,
      startDate: _parseIsoDate(json['start_date']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      staticMapUrl: json['static_map_url'] as String?,
      days: (json['days'] is List)
          ? (json['days'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TripDay.fromJson)
                .toList(growable: false)
          : const [],
      routes: (json['routes'] is List)
          ? (json['routes'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TripRoute.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  /// Pass `null` to clear a nullable field (`summary`, `startDate`,
  /// `staticMapUrl`); omit the named arg to leave it untouched. The
  /// sentinel distinguishes "not supplied" from "explicit null" — Dart
  /// can't otherwise express both.
  Trip copyWith({
    String? id,
    String? title,
    Object? summary = _sentinel,
    Object? startDate = _sentinel,
    List<TripDay>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? staticMapUrl = _sentinel,
    List<TripRoute>? routes,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: identical(summary, _sentinel)
          ? this.summary
          : summary as String?,
      startDate: identical(startDate, _sentinel)
          ? this.startDate
          : startDate as DateTime?,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      staticMapUrl: identical(staticMapUrl, _sentinel)
          ? this.staticMapUrl
          : staticMapUrl as String?,
      routes: routes ?? this.routes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    startDate,
    days,
    createdAt,
    updatedAt,
    staticMapUrl,
    routes,
  ];
}

const _sentinel = Object();

DateTime? _parseIsoDate(dynamic raw) {
  if (raw is! String || raw.isEmpty) return null;
  try {
    return DateFormat('yyyy-MM-dd').parseStrict(raw);
  } catch (_) {
    return null;
  }
}

DateTime? _parseDateTime(dynamic raw) {
  if (raw is! String || raw.isEmpty) return null;
  try {
    return DateTime.parse(raw);
  } catch (_) {
    return null;
  }
}
