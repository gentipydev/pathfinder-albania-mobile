import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/artifact_data.dart';

class CollectibleState {
  static const int lost = 0;
  static const int discovered = 1;
  static const int explored = 2;
}

/// Hidden collectible artifact for the gameplay loop. Populated at runtime
/// by `ArtifactsBloc.getForDestination` — `iconName` comes from the
/// catalog's `icon_name` field and maps onto a bundled asset
/// (`assets/images/collectibles/{iconName}.png`). Falls back to 'jewelry'
/// if the catalog leaves it blank.
class CollectibleData {
  CollectibleData._({
    required this.title,
    required this.iconName,
    required this.artifactId,
    required this.destination,
    required this.imageUrl,
    required this.imageUrlSmall,
  }) {
    icon = AssetImage('${ImagePaths.collectibles}/$iconName.png');
  }

  factory CollectibleData.fromArtifact(ArtifactData a, DestinationType destination) {
    final icon = a.iconName.isEmpty ? 'jewelry' : a.iconName;
    return CollectibleData._(
      title: a.title,
      iconName: icon,
      artifactId: a.objectId,
      destination: destination,
      imageUrl: a.image,
      imageUrlSmall: a.imageSmall,
    );
  }

  final String title;
  final String iconName;
  late final ImageProvider icon;
  final String artifactId;
  final DestinationType destination;
  final String imageUrl;
  final String imageUrlSmall;

  String get id => artifactId;
  String get subtitle => destinationsLogic.getData(destination).artifactCulture;

  static final Map<DestinationType, List<CollectibleData>> _byDestination = {};

  static List<CollectibleData> get all =>
      _byDestination.values.expand((e) => e).toList(growable: false);

  static List<CollectibleData> forDestination(DestinationType destination) =>
      _byDestination[destination] ?? const [];

  static void replaceForDestination(DestinationType destination, List<ArtifactData> artifacts) {
    _byDestination[destination] = [
      for (final a in artifacts) CollectibleData.fromArtifact(a, destination),
    ];
  }
}

/// Legacy global accessor retained for synchronous reads from UI sites
/// that don't go through `CollectiblesBloc`. Kept as a getter so it
/// always reflects the latest catalog state.
List<CollectibleData> get collectiblesData => CollectibleData.all;
