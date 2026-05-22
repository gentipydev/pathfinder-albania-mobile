import 'package:travel_buddy/logic/data/artifact_data.dart';

class DestinationArtifacts {
  const DestinationArtifacts({
    required this.highlights,
    required this.collectibles,
  });

  final List<ArtifactData> highlights;
  final List<ArtifactData> collectibles;

  List<ArtifactData> get all => [...highlights, ...collectibles];
}
