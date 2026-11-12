import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/collectible_data.dart';

/// Returns the first discovered collectible by `destinationsLogic.all`
/// order, or null if none have been discovered.
CollectibleData? firstDiscoveredOrNull(Map<String, int> states) {
  final discovered = <CollectibleData>[];
  states.forEach((id, state) {
    if (state == CollectibleState.discovered) {
      final c = collectiblesData.firstWhereOrNull((o) => o.id == id);
      if (c != null) discovered.add(c);
    }
  });
  for (final w in destinationsLogic.all) {
    for (final d in discovered) {
      if (d.destination == w.type) return d;
    }
  }
  return null;
}

/// The saved state of collectible [id]. An id with no saved state yet (a
/// fresh install, or a collectible newly added to the catalog) has
/// not been found, so it reads as lost.
int collectibleStateOf(Map<String, int> states, String id) =>
    states[id] ?? CollectibleState.lost;

/// True when the destination has a collectible at index `i` that has not
/// been found yet. False when there is no collectible there (e.g. the
/// catalog hasn't loaded), so the caller shows its normal content instead.
bool isCollectibleLost(
  Map<String, int> states,
  DestinationType destinationType,
  int i,
) {
  final datas = CollectibleData.forDestination(destinationType);
  if (i >= datas.length) return false;
  return collectibleStateOf(states, datas[i].id) == CollectibleState.lost;
}
