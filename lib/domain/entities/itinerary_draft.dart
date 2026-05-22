import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Kind of a single stop on an itinerary day. Mirrors the tool schema's
/// stop.kind enum, with `unknown` reserved as a forward-compat fallback for
/// payloads that introduce new server-side values before the client knows
/// about them.
enum StopKind {
  sight,
  beach,
  hike,
  meal,
  stay,
  transport,
  activity,
  unknown,
}

StopKind stopKindFromString(String? raw) {
  if (raw == null) return StopKind.unknown;
  for (final v in StopKind.values) {
    if (v.name == raw) return v;
  }
  return StopKind.unknown;
}

/// How the traveler arrives at the stop from the previous one.
enum TransportationKind { walk, taxi, tram, bus, car, other, unknown }

TransportationKind? transportationKindFromString(String? raw) {
  if (raw == null) return null;
  for (final v in TransportationKind.values) {
    if (v.name == raw) return v;
  }
  return TransportationKind.unknown;
}

/// In-memory snapshot of the `event: itinerary` SSE payload. Holds no DB
/// IDs — those only exist after a successful save round-trip.
class ItineraryDraft extends Equatable {
  const ItineraryDraft({
    required this.title,
    required this.days,
    this.summary,
    this.startDate,
  });

  final String title;
  final String? summary;

  /// Set only when Claude explicitly emitted `start_date` because the user
  /// gave a concrete calendar start. Otherwise null — the Save flow prompts
  /// the user with a date picker before persisting.
  final DateTime? startDate;
  final List<DayDraft> days;

  factory ItineraryDraft.fromToolJson(Map<String, dynamic> json) {
    return ItineraryDraft(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled itinerary',
      summary: json['summary'] as String?,
      startDate: _parseIsoDate(json['start_date']),
      days: (json['days'] is List)
          ? (json['days'] as List)
                .whereType<Map<String, dynamic>>()
                .map(DayDraft.fromToolJson)
                .toList(growable: false)
          : const [],
    );
  }

  /// Serialize to the exact shape FastAPI's `TripCreate` expects. The
  /// per-stop `_savedItineraryIds` guard on the client makes save
  /// idempotent per chat bubble — server-side dedup is intentionally
  /// not used.
  Map<String, dynamic> toCreatePayload({DateTime? userPickedStartDate}) {
    final effectiveDate = userPickedStartDate ?? startDate;
    return {
      'title': title,
      if (summary != null && summary!.isNotEmpty) 'summary': summary,
      if (effectiveDate != null) 'start_date': _formatIsoDate(effectiveDate),
      'days': days.map((d) => d.toCreateJson()).toList(growable: false),
    };
  }

  ItineraryDraft copyWith({
    String? title,
    String? summary,
    DateTime? startDate,
    List<DayDraft>? days,
  }) {
    return ItineraryDraft(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      days: days ?? this.days,
    );
  }

  @override
  List<Object?> get props => [title, summary, startDate, days];
}

class DayDraft extends Equatable {
  const DayDraft({
    required this.dayNumber,
    required this.stops,
    this.title,
    this.baseCity,
  });

  final int dayNumber;
  final String? title;
  final String? baseCity;
  final List<StopDraft> stops;

  factory DayDraft.fromToolJson(Map<String, dynamic> json) {
    final raw = json['day_number'] ?? json['day'];
    final dayNumber = raw is int ? raw : int.tryParse('$raw') ?? 1;
    return DayDraft(
      dayNumber: dayNumber < 1 ? 1 : dayNumber,
      title: json['title'] as String?,
      baseCity: json['base_city'] as String?,
      stops: (json['stops'] is List)
          ? (json['stops'] as List)
                .whereType<Map<String, dynamic>>()
                .map(StopDraft.fromToolJson)
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'day_number': dayNumber,
      if (title != null && title!.isNotEmpty) 'title': title,
      if (baseCity != null && baseCity!.isNotEmpty) 'base_city': baseCity,
      'stops': stops.map((s) => s.toCreateJson()).toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [dayNumber, title, baseCity, stops];
}

class StopDraft extends Equatable {
  const StopDraft({
    required this.name,
    required this.kind,
    this.city,
    this.address,
    this.durationMinutes,
    this.arrivalTime,
    this.endTime,
    this.transportation,
    this.notes,
    this.lat,
    this.lng,
    this.googlePlaceId,
  });

  final String name;
  final StopKind kind;
  final String? city;
  final String? address;
  final int? durationMinutes;

  /// "HH:MM" 24h. Kept as String to mirror the wire format exactly.
  final String? arrivalTime;
  final String? endTime;
  final TransportationKind? transportation;
  final String? notes;
  final double? lat;
  final double? lng;
  final String? googlePlaceId;

  factory StopDraft.fromToolJson(Map<String, dynamic> json) {
    return StopDraft(
      name: (json['name'] as String?) ?? '',
      kind: stopKindFromString(json['kind'] as String?),
      city: json['city'] as String?,
      address: json['address'] as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      arrivalTime: json['arrival_time'] as String?,
      endTime: json['end_time'] as String?,
      transportation: transportationKindFromString(
        json['transportation'] as String?,
      ),
      notes: json['notes'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      googlePlaceId: json['google_place_id'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    // Pydantic's Literal rejects "unknown" — coerce to "activity" as the
    // safest catch-all category. transportation `unknown` becomes null
    // (omitted) since transportation is itself optional.
    final kindStr = kind == StopKind.unknown ? 'activity' : kind.name;
    final transportStr =
        (transportation == null || transportation == TransportationKind.unknown)
        ? null
        : transportation!.name;
    return {
      'name': name,
      'kind': kindStr,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (arrivalTime != null && arrivalTime!.isNotEmpty)
        'arrival_time': arrivalTime,
      if (endTime != null && endTime!.isNotEmpty) 'end_time': endTime,
      if (transportStr != null) 'transportation': transportStr,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (googlePlaceId != null && googlePlaceId!.isNotEmpty)
        'google_place_id': googlePlaceId,
    };
  }

  @override
  List<Object?> get props => [
    name,
    kind,
    city,
    address,
    durationMinutes,
    arrivalTime,
    endTime,
    transportation,
    notes,
    lat,
    lng,
    googlePlaceId,
  ];
}

DateTime? _parseIsoDate(dynamic raw) {
  if (raw is! String || raw.isEmpty) return null;
  try {
    return DateFormat('yyyy-MM-dd').parseStrict(raw);
  } catch (_) {
    return null;
  }
}

String _formatIsoDate(DateTime d) =>
    DateFormat('yyyy-MM-dd').format(DateTime(d.year, d.month, d.day));
