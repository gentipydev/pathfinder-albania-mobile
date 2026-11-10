import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';
import 'package:travel_buddy/ui/common/collectible_item.dart';

/// Shows a [CollectibleItem], for a specific set of destinations.
/// The item is looked up via index. If `destinations` is empty, then the
/// collectible is always shown. Renders nothing while the catalog is still
/// being loaded — collectibles populate asynchronously via the post-warmup
/// preload, so a first-launch render can race the network.
class HiddenCollectible extends StatelessWidget {
  const HiddenCollectible(
    this.currentDestination, {
    super.key,
    required this.index,
    this.matches = const [],
    this.size = 64,
    this.focus,
  }) : assert(index <= 2, 'index should not exceed 2');
  final int index;
  final double size;
  final List<DestinationType> matches;
  final DestinationType currentDestination;
  final FocusNode? focus;
  @override
  Widget build(BuildContext context) {
    // Rebuild when ArtifactsBloc finishes populating CollectibleData.
    context.watch<ArtifactsBloc>().state.dataVersion;
    if (matches.isNotEmpty && matches.contains(currentDestination) == false) {
      return SizedBox.shrink();
    }
    final data = CollectibleData.forDestination(currentDestination);
    if (index >= data.length) return SizedBox.shrink();
    return CollectibleItem(data[index], size: size, focus: focus);
  }
}
