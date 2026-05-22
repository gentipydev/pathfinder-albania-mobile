enum DestinationType {
  albanianAlps,
  apollonia,
  berat,
  butrint,
  gjirokaster,
  korca,
  kruja,
  theth,
}

extension DestinationTypeSlug on DestinationType {
  /// Snake-case slug used by backend image manifest endpoints
  /// (`/destinations/{slug}/photos`, `/destinations/{slug}/artifacts`).
  /// Mirrors the validator set in `app/routers/images.py` on the backend.
  String get slug => switch (this) {
        DestinationType.albanianAlps => 'albanian_alps',
        DestinationType.apollonia => 'apollonia',
        DestinationType.berat => 'berat',
        DestinationType.butrint => 'butrint',
        DestinationType.gjirokaster => 'gjirokaster',
        DestinationType.korca => 'korca',
        DestinationType.kruja => 'kruja',
        DestinationType.theth => 'theth',
      };

  static DestinationType? fromSlug(String slug) =>
      DestinationType.values.firstWhereSlugOrNull(slug);
}

extension on Iterable<DestinationType> {
  DestinationType? firstWhereSlugOrNull(String slug) {
    for (final t in this) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}
