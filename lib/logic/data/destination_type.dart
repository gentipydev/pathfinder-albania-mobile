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
  /// Snake-case slug keying the bundled content manifests and naming the
  /// snapshot folders (`assets/backend_snapshot/.../<slug>/`). It was the
  /// destination id of the old backend's image endpoints, kept so the same
  /// data can come from a network source again later.
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
}
