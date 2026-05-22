/// Typed model for the `place_card` SSE event payload emitted by the backend.
///
/// Falls back gracefully when individual fields are missing so the widget
/// can still render even with partial data.
class PlaceCard {
  PlaceCard({
    required this.id,
    required this.name,
    this.city,
    this.region,
    this.description,
    this.tags = const [],
    this.heroImageUrl,
    this.photos = const [],
    this.rating,
    this.lat,
    this.lng,
    this.googlePlaceId,
  });

  factory PlaceCard.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final rawPhotos = json['photos'];
    return PlaceCard(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      city: json['city'] as String?,
      region: json['region'] as String?,
      description: json['description'] as String?,
      tags: rawTags is List
          ? rawTags.whereType<String>().toList(growable: false)
          : const [],
      heroImageUrl: json['hero_image_url'] as String?,
      photos: rawPhotos is List
          ? rawPhotos.whereType<String>().toList(growable: false)
          : const [],
      rating: (json['rating'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      googlePlaceId: json['google_place_id'] as String?,
    );
  }

  final String id;
  final String name;
  final String? city;
  final String? region;
  final String? description;
  final List<String> tags;
  final String? heroImageUrl;
  final List<String> photos;
  final double? rating;
  final double? lat;
  final double? lng;
  final String? googlePlaceId;

  /// Photos to render in the stack. Falls back to a single-entry list built
  /// from `heroImageUrl` when `photos` is empty so we never show a broken
  /// image. Returns an empty list only when both are absent.
  List<String> get effectivePhotos {
    if (photos.isNotEmpty) return photos;
    final hero = heroImageUrl;
    if (hero != null && hero.isNotEmpty) return [hero];
    return const [];
  }

  String? get subtitle {
    final c = city;
    final r = region;
    final hasCity = c != null && c.isNotEmpty;
    final hasRegion = r != null && r.isNotEmpty;
    if (hasCity && hasRegion && c != r) return '$c, $r';
    if (hasCity) return c;
    if (hasRegion) return r;
    return null;
  }
}
