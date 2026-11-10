import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_bloc.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_event.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_helpers.dart';
import 'package:travel_buddy/logic/common/animate_utils.dart';
import 'package:travel_buddy/logic/data/collectible_data.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';
import 'package:travel_buddy/ui/common/centered_box.dart';
import 'package:travel_buddy/ui/common/controls/app_header.dart';
import 'package:travel_buddy/ui/common/modals/app_modals.dart';
import 'package:travel_buddy/ui/common/utils/duration_utils.dart';

part 'widgets/_collectible_image.dart';
part 'widgets/_collection_footer.dart';
part 'widgets/_collection_list.dart';
part 'widgets/_collection_list_card.dart';
part 'widgets/_newly_discovered_items_btn.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({required this.fromId, super.key});

  final String fromId;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final GlobalKey _scrollKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final states = context.read<CollectiblesBloc>().state.statesById;
    if (widget.fromId.isNotEmpty && states[widget.fromId] == CollectibleState.discovered) {
      scheduleMicrotask(() => _scrollToTarget(false));
    }
  }

  void _scrollToTarget([bool animate = true]) {
    if (_scrollKey.currentContext != null) {
      Scrollable.ensureVisible(
        _scrollKey.currentContext!,
        alignment: 0.15,
        duration: (animate ? 300 : 0).animateMs,
      );
    }
  }

  void _handleReset() async {
    String msg = $strings.collectionPopupResetConfirm;
    final result = await showModal(context, child: OkCancelModal(msg: msg));
    if (result == true && mounted) {
      context.read<CollectiblesBloc>().add(const CollectiblesResetRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when collectible states change
    final bloc = context.watch<CollectiblesBloc>();
    int discovered = bloc.state.discoveredCount;
    int explored = bloc.state.exploredCount;
    int total = collectiblesData.length;

    return ColoredBox(
      color: $styles.colors.greyStrong,
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(title: $strings.collectionTitleCollection, isTransparent: true),
                _NewlyDiscoveredItemsBtn(count: discovered, onPressed: _scrollToTarget),
                Flexible(
                  child: _CollectionList(
                    fromId: widget.fromId,
                    scrollKey: _scrollKey,
                    onReset: discovered + explored > 0 ? _handleReset : null,
                  ),
                ),
              ],
            ),
          ),
          _CollectionFooter(count: discovered + explored, total: total),
        ],
      ),
    );
  }
}
