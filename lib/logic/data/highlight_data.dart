import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/artifact_data.dart';

/// Featured artifacts for one destination, surfaced in the artifact
/// carousel screen. The list is populated at runtime by
/// `ArtifactsBloc.getForDestination` from the bundled catalog manifest.
class HighlightData {
  HighlightData._({
    required this.title,
    required this.artifactId,
    required this.date,
    required this.imageUrl,
    required this.imageUrlSmall,
    this.isPlaceholder = false,
  });

  factory HighlightData.fromArtifact(ArtifactData a) => HighlightData._(
    title: a.title,
    artifactId: a.objectId,
    date: a.date,
    imageUrl: a.image,
    imageUrlSmall: a.imageSmall,
  );

  final String title;
  final String date;
  final String artifactId;
  final String imageUrl;
  final String imageUrlSmall;

  /// A stand-in shown as a skeleton while the real highlights load. Its
  /// title/date only give the skeleton bones a realistic width.
  final bool isPlaceholder;

  factory HighlightData.placeholder(int index) => HighlightData._(
    title: 'Artifact title here',
    artifactId: 'placeholder-$index',
    date: '4th century BC',
    imageUrl: '',
    imageUrlSmall: '',
    isPlaceholder: true,
  );

  String get id => artifactId;

  static final Map<DestinationType, List<HighlightData>> _byDestination = {};

  static List<HighlightData> forDestination(DestinationType destination) =>
      _byDestination[destination] ?? const [];

  /// Replaces the cached highlights for one destination with a freshly
  /// read list. Called by `ArtifactsBloc` after a successful manifest
  /// read so synchronous `forDestination` callers keep working.
  static void replaceForDestination(DestinationType destination, List<ArtifactData> artifacts) {
    _byDestination[destination] = [
      for (final a in artifacts) HighlightData.fromArtifact(a),
    ];
  }
}
