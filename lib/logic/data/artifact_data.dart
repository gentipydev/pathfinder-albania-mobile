/// Hydrated from the backend `/artifacts/{id}` and
/// `/destinations/{slug}/artifacts` endpoints. Image bytes live in the
/// `artifact-photos` Supabase Storage bucket; the URL fields below are
/// public Supabase URLs returned by the backend, never built client-side.
class ArtifactData {
  ArtifactData({
    required this.objectId,
    required this.title,
    required this.image,
    required this.imageSmall,
    required this.date,
    required this.period,
    required this.country,
    required this.medium,
    required this.dimension,
    required this.classification,
    required this.culture,
    this.iconName = '',
  });

  factory ArtifactData.fromJson(Map<String, dynamic> json) {
    final url = (json['image'] as String?) ?? '';
    return ArtifactData(
      objectId: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      image: url,
      imageSmall: (json['image_small'] as String?) ?? url,
      date: (json['date'] as String?) ?? '',
      period: (json['period'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      medium: (json['medium'] as String?) ?? '',
      dimension: (json['dimension'] as String?) ?? '',
      classification: (json['classification'] as String?) ?? '',
      culture: (json['culture'] as String?) ?? '',
      iconName: (json['icon_name'] as String?) ?? '',
    );
  }

  final String objectId;
  final String title;
  final String image;
  final String imageSmall;

  final String date;
  final String period;
  final String country;
  final String medium;
  final String dimension;
  final String classification;
  final String culture;
  final String iconName;
}
