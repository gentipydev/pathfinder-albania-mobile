part of '../collection_screen.dart';

@immutable
class _CollectionList extends StatefulWidget {
  const _CollectionList({
    this.onReset,
    required this.fromId,
    this.scrollKey,
  });

  static const double _vtCardExtent = 300;
  static const double _hzCardExtent = 600;
  final VoidCallback? onReset;
  final Key? scrollKey;
  final String fromId;

  @override
  State<_CollectionList> createState() => _CollectionListState();
}

class _CollectionListState extends State<_CollectionList> {
  final ScrollController scrollController = ScrollController();

  late final ValueNotifier<bool> _vtMode = ValueNotifier(true)..addListener(_maintainScrollPos);

  DestinationType? _scrollTargetDestination(Map<String, int> states) {
    if (widget.fromId.isEmpty) {
      return firstDiscoveredOrNull(states)?.destination;
    }
    return collectiblesData
        .firstWhereOrNull((o) => o.id == widget.fromId)
        ?.destination;
  }

  // Maintain scroll position when switching between vertical and horizontal orientation.
  // Multiplies or divides the current scroll position by the ratio of the vertical and horizontal card extents.
  void _maintainScrollPos() {
    if (scrollController.hasClients == false) return;
    const extentFactor = _CollectionList._vtCardExtent / _CollectionList._hzCardExtent;
    final currentPx = scrollController.position.pixels;
    if (_vtMode.value == true) {
      scrollController.jumpTo(currentPx * extentFactor);
    } else {
      scrollController.jumpTo(currentPx / extentFactor);
    }
  }

  void _handleMouseWheel(PointerSignalEvent event) {
    if (event is PointerScrollEvent && event.kind == PointerDeviceKind.mouse && _vtMode.value == false) {
      final offset = event.scrollDelta.dy;
      scrollController.jumpTo(scrollController.offset + offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = context.watch<CollectiblesBloc>().state.statesById;
    List<DestinationData> destinations = destinationsLogic.all;
    _vtMode.value = context.isLandscape == false;
    final scrollDestination = _scrollTargetDestination(states);
    // Create list of collections that is shared by both hz and vt layouts
    List<Widget> collections = [
      ...destinations.map((d) {
        return _CollectionListCard(
          key: d.type == scrollDestination ? widget.scrollKey : null,
          width: _vtMode.value ? null : _CollectionList._hzCardExtent,
          height: _vtMode.value ? _CollectionList._vtCardExtent : 400,
          fromId: widget.fromId,
          data: d,
        );
      }),
    ];
    // Scroll view adapts to scroll vertically or horizontally
    return Listener(
      onPointerSignal: _handleMouseWheel,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: _vtMode.value ? Axis.vertical : Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all($styles.insets.lg),
          child: SeparatedFlex(
            direction: _vtMode.value ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            separatorBuilder: () => Gap($styles.insets.lg),
            children: [
              ...collections,
              Gap($styles.insets.sm),
              if (kDebugMode) _buildResetBtn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetBtn(BuildContext context) {
    Widget btn = AppBtn.from(
      onPressed: widget.onReset ?? () {},
      text: $strings.collectionButtonReset,
      isSecondary: true,
      expand: true,
    );
    return AnimatedOpacity(
      opacity: widget.onReset == null ? 0.25 : 1,
      duration: $styles.times.fast,
      child: btn,
    );
  }
}
