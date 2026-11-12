import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/features/collectibles/bloc/collectibles_bloc.dart';
import 'package:pathfinder_albania/features/collectibles/bloc/collectibles_event.dart';
import 'package:pathfinder_albania/features/collectibles/bloc/collectibles_helpers.dart';
import 'package:pathfinder_albania/logic/common/animate_utils.dart';
import 'package:pathfinder_albania/logic/data/collectible_data.dart';
import 'package:pathfinder_albania/ui/common/opening_card.dart';
import 'package:pathfinder_albania/ui/common/utils/app_haptics.dart';
import 'package:pathfinder_albania/ui/common/utils/duration_utils.dart';
import 'package:pathfinder_albania/ui/screens/collectible_found/collectible_found_screen.dart';

class CollectibleItem extends StatelessWidget {
  CollectibleItem(this.collectible, {this.size = 64.0, super.key, this.focus}) {
    // Hero into the collectible-found screen uses the artifact image when
    // available; falls back to the bundled icon if the catalog or network
    // hasn't surfaced the URL yet.
    _imageProvider = collectible.imageUrl.isEmpty
        ? collectible.icon
        : NetworkImage(collectible.imageUrl);
  }

  final CollectibleData collectible;
  final double size;
  late final ImageProvider _imageProvider;
  final FocusNode? focus;

  void _handleTap(BuildContext context) async {
    final bloc = context.read<CollectiblesBloc>();
    final screen = CollectibleFoundScreen(collectible: collectible, imageProvider: _imageProvider);
    appLogic.showFullscreenDialogRoute(context, screen);
    AppHaptics.mediumImpact();

    // wait to update the state, to ensure the hero works properly:
    await Future.delayed($styles.times.pageTransition);
    bloc.add(CollectiblesStateChanged(
      id: collectible.id,
      state: CollectibleState.discovered,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final states = context.watch<CollectiblesBloc>().state.statesById;
    bool isLost = collectibleStateOf(states, collectible.id) == CollectibleState.lost;
    // Use an OpeningCard to let the collectible smoothly collapse its size once it has been found
    return SizedBox(
      height: isLost ? size : null,
      child: RepaintBoundary(
        child: OpeningCard(
          isOpen: isLost,
          // Note: In order for the collapse animation to run properly, we must return a non-zero height or width.
          closedBuilder: (_) => SizedBox(width: 1, height: 0),
          openBuilder: (_) => AppBtn.basic(
            focusNode: focus,
            semanticLabel: $strings.collectibleItemSemanticCollectible,
            onPressed: () => _handleTap(context),
            enableFeedback: false,
            child:
                Hero(
                      tag: 'collectible_icon_${collectible.id}',
                      child: Image(
                        image: collectible.icon,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    )
                    .maybeAnimate(onPlay: (controller) => controller.repeat())
                    .shimmer(delay: 4000.delayMs, duration: $styles.times.med * 3)
                    .shake(curve: Curves.easeInOutCubic, hz: 4)
                    .scale(
                      begin: Offset(1.0, 1.0),
                      end: Offset(1.1, 1.1),
                      duration: $styles.times.med,
                    )
                    .then(delay: $styles.times.med)
                    .scale(begin: Offset(1.0, 1.0), end: Offset(1 / 1.1, 1 / 1.1)),
          ),
        ),
      ),
    );
  }
}
