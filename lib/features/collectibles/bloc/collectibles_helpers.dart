import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';

/// Returns the first discovered collectible by `destinationsLogic.all`
/// order, or null if none have been discovered. Lifted verbatim from
/// `CollectiblesLogic.getFirstDiscoveredOrNull`.
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

/// True when the collectible at index `i` for the given destination has
/// not yet been discovered (or doesn't exist in the catalog). Lifted
/// verbatim from `CollectiblesLogic.isLost`.
bool isCollectibleLost(
  Map<String, int> states,
  DestinationType destinationType,
  int i,
) {
  final datas = CollectibleData.forDestination(destinationType);
  if (datas.length > i && states.containsKey(datas[i].id)) {
    return states[datas[i].id] == CollectibleState.lost;
  }
  return true;
}
