import 'package:equatable/equatable.dart';
import 'package:travel_buddy/domain/entities/itinerary_draft.dart';

/// Server-acknowledged stop. Same field set as [StopDraft] plus the assigned
/// `id` and `sortOrder`. Time fields stay as raw `HH:MM` strings to match
/// the wire format; use [deriveStopStartDateTime] / [deriveStopEndDateTime]
/// to compose a real [DateTime] when rendering.
class TripStop extends Equatable {
  const TripStop({
    required this.id,
    required this.sortOrder,
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
    this.photoUrl,
    this.photos = const [],
    this.rating,
    this.formattedAddress,
    this.completedAt,
  });

  final String id;
  final int sortOrder;
  final String name;
  final StopKind kind;
  final String? city;
  final String? address;
  final int? durationMinutes;
  final String? arrivalTime;
  final String? endTime;
  final TransportationKind? transportation;
  final String? notes;
  final double? lat;
  final double? lng;
  final String? googlePlaceId;

  /// Server-enriched photo (Google Places). Null when the place lacks a
  /// `google_place_id`, when enrichment quota is exhausted, or when the
  /// trip was saved before PR 1 deployed.
  final String? photoUrl;

  /// Ordered photo list, primary at index 0 (mirrors [photoUrl]). Empty for
  /// pre-014 / un-enriched stops; in that case [effectivePhotos] falls back
  /// to `[photoUrl]` so the UI still shows the legacy single photo.
  final List<String> photos;

  /// Google Places rating (0.0–5.0). Null when unavailable.
  final double? rating;

  /// Canonical formatted address from Google Places. Distinct from `address`
  /// (which can be a free-form planner string); prefer this when present.
  final String? formattedAddress;

  /// When the stop was marked visited — by the foreground auto-detector
  /// (location + time-window match) or by the manual override popover.
  /// Null until then. Server is source of truth; mobile mirrors via PATCH.
  final DateTime? completedAt;

  /// Photos to render in the stop sheet's photo region. Caps at 3 (the UI
  /// hero + 2 thumb slots). Falls back to a single-entry list built from
  /// [photoUrl] when [photos] is empty so old trips keep rendering one image.
  /// Empty only when both are absent.
  List<String> get effectivePhotos {
    if (photos.isNotEmpty) {
      return photos.length > 3
          ? photos.sublist(0, 3)
          : List<String>.unmodifiable(photos);
    }
    final hero = photoUrl;
    if (hero != null && hero.isNotEmpty) return [hero];
    return const [];
  }

  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      id: (json['id'] as String?) ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
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
      photoUrl: json['photo_url'] as String?,
      photos: (json['photos'] as List?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const [],
      rating: (json['rating'] as num?)?.toDouble(),
      formattedAddress: json['formatted_address'] as String?,
      completedAt: _parseUtcIso(json['completed_at']),
    );
  }

  TripStop copyWith({
    String? id,
    int? sortOrder,
    String? name,
    StopKind? kind,
    Object? city = _sentinel,
    Object? address = _sentinel,
    Object? durationMinutes = _sentinel,
    Object? arrivalTime = _sentinel,
    Object? endTime = _sentinel,
    Object? transportation = _sentinel,
    Object? notes = _sentinel,
    Object? lat = _sentinel,
    Object? lng = _sentinel,
    Object? googlePlaceId = _sentinel,
    Object? photoUrl = _sentinel,
    List<String>? photos,
    Object? rating = _sentinel,
    Object? formattedAddress = _sentinel,
    Object? completedAt = _sentinel,
  }) {
    return TripStop(
      id: id ?? this.id,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      city: identical(city, _sentinel) ? this.city : city as String?,
      address: identical(address, _sentinel)
          ? this.address
          : address as String?,
      durationMinutes: identical(durationMinutes, _sentinel)
          ? this.durationMinutes
          : durationMinutes as int?,
      arrivalTime: identical(arrivalTime, _sentinel)
          ? this.arrivalTime
          : arrivalTime as String?,
      endTime: identical(endTime, _sentinel)
          ? this.endTime
          : endTime as String?,
      transportation: identical(transportation, _sentinel)
          ? this.transportation
          : transportation as TransportationKind?,
      notes: identical(notes, _sentinel) ? this.notes : notes as String?,
      lat: identical(lat, _sentinel) ? this.lat : lat as double?,
      lng: identical(lng, _sentinel) ? this.lng : lng as double?,
      googlePlaceId: identical(googlePlaceId, _sentinel)
          ? this.googlePlaceId
          : googlePlaceId as String?,
      photoUrl: identical(photoUrl, _sentinel)
          ? this.photoUrl
          : photoUrl as String?,
      photos: photos ?? this.photos,
      rating: identical(rating, _sentinel)
          ? this.rating
          : rating as double?,
      formattedAddress: identical(formattedAddress, _sentinel)
          ? this.formattedAddress
          : formattedAddress as String?,
      completedAt: identical(completedAt, _sentinel)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sortOrder,
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
    photoUrl,
    photos,
    rating,
    formattedAddress,
    completedAt,
  ];
}

const _sentinel = Object();

/// Parse a UTC ISO-8601 string from the backend. Returns null for absent /
/// empty / malformed values so the rail node stays in "upcoming" semantics.
DateTime? _parseUtcIso(dynamic raw) {
  if (raw is! String || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// Compose a wall-clock DateTime by anchoring `arrivalTime` (HH:MM) to the
/// trip's `startDate` plus the day offset. Returns null if the trip has no
/// known start date or the time string is malformed.
DateTime? deriveStopStartDateTime({
  required DateTime? tripStartDate,
  required int dayNumber,
  required String? arrivalTime,
}) => _composeDateTime(tripStartDate, dayNumber, arrivalTime);

DateTime? deriveStopEndDateTime({
  required DateTime? tripStartDate,
  required int dayNumber,
  required String? endTime,
}) => _composeDateTime(tripStartDate, dayNumber, endTime);

DateTime? _composeDateTime(DateTime? tripStartDate, int dayNumber, String? hhmm) {
  if (tripStartDate == null || hhmm == null || hhmm.isEmpty) return null;
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  final dayOffset = (dayNumber - 1).clamp(0, 365);
  final base = tripStartDate.add(Duration(days: dayOffset));
  return DateTime(base.year, base.month, base.day, hour, minute);
}
