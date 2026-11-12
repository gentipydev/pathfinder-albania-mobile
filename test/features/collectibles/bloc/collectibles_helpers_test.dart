import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/features/collectibles/bloc/collectibles_helpers.dart';
import 'package:pathfinder_albania/logic/data/artifact_data.dart';
import 'package:pathfinder_albania/logic/data/collectible_data.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';

ArtifactData _artifact(String id) => ArtifactData(
      objectId: id,
      title: 'Test',
      image: '',
      imageSmall: '',
      date: '',
      period: '',
      country: '',
      medium: '',
      dimension: '',
      classification: '',
      culture: '',
    );

void main() {
  setUp(() {
    for (final t in DestinationType.values) {
      CollectibleData.replaceForDestination(t, const []);
    }
    CollectibleData.replaceForDestination(
      DestinationType.butrint,
      [_artifact('col-1'), _artifact('col-2')],
    );
  });

  test('collectibleStateOf treats an id with no saved state as lost', () {
    expect(collectibleStateOf(const {}, 'col-1'), CollectibleState.lost);
    expect(
      collectibleStateOf(const {'col-1': CollectibleState.explored}, 'col-1'),
      CollectibleState.explored,
    );
  });

  group('isCollectibleLost', () {
    test('false when the destination has no collectible at that index', () {
      expect(isCollectibleLost(const {}, DestinationType.berat, 1), isFalse);
      expect(isCollectibleLost(const {}, DestinationType.butrint, 5), isFalse);
    });

    test('true when the collectible exists but has no saved state yet', () {
      expect(isCollectibleLost(const {}, DestinationType.butrint, 1), isTrue);
    });

    test('follows the saved state otherwise', () {
      expect(
        isCollectibleLost(const {'col-2': CollectibleState.lost}, DestinationType.butrint, 1),
        isTrue,
      );
      expect(
        isCollectibleLost(const {'col-2': CollectibleState.discovered}, DestinationType.butrint, 1),
        isFalse,
      );
    });
  });
}
