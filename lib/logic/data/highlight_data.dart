import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/artifact_data.dart';

/// Featured artifacts for one destination, surfaced in the artifact
/// carousel screen. The list is populated at runtime by
/// `ArtifactsBloc.getForDestination` from the backend manifest — there is
/// no longer a hardcoded MET object-ID catalog.
class HighlightData {
  HighlightData._({
    required this.title,
    required this.culture,
    required this.artifactId,
    required this.destination,
    required this.date,
    required this.imageUrl,
    required this.imageUrlSmall,
  });

  factory HighlightData.fromArtifact(ArtifactData a, DestinationType destination) =>
      HighlightData._(
        title: a.title,
        culture: a.culture,
        artifactId: a.objectId,
        destination: destination,
        date: a.date,
        imageUrl: a.image,
        imageUrlSmall: a.imageSmall,
      );

  final String title;
  final String culture;
  final String date;
  final String artifactId;
  final DestinationType destination;
  final String imageUrl;
  final String imageUrlSmall;

  String get id => artifactId;
  String get subtitle => destinationsLogic.getData(destination).artifactCulture;

  static final Map<DestinationType, List<HighlightData>> _byDestination = {};

  static HighlightData? fromId(String? id) {
    if (id == null) return null;
    for (final list in _byDestination.values) {
      for (final h in list) {
        if (h.id == id) return h;
      }
    }
    return null;
  }

  static List<HighlightData> forDestination(DestinationType destination) =>
      _byDestination[destination] ?? const [];

  static List<HighlightData> get all =>
      _byDestination.values.expand((e) => e).toList(growable: false);

  /// Replaces the cached highlights for one destination with a freshly
  /// fetched list. Called by `ArtifactsBloc` after a successful manifest
  /// fetch so synchronous `forDestination` callers keep working.
  static void replaceForDestination(DestinationType destination, List<ArtifactData> artifacts) {
    _byDestination[destination] = [
      for (final a in artifacts) HighlightData.fromArtifact(a, destination),
    ];
  }
}
