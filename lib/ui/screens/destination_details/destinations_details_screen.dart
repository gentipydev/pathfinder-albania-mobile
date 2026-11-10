import 'dart:async';

import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/common/photo_cache.dart';
import 'package:travel_buddy/ui/common/lazy_indexed_stack.dart';
import 'package:travel_buddy/ui/common/measurable_widget.dart';
import 'package:travel_buddy/ui/screens/artifact/artifact_carousel/artifact_carousel_screen.dart';
import 'package:travel_buddy/ui/screens/editorial/editorial_screen.dart';
import 'package:travel_buddy/ui/screens/photo_gallery/photo_gallery.dart';
import 'package:travel_buddy/ui/screens/destination_details/destination_details_tab_menu.dart';
import 'package:travel_buddy/ui/screens/destination_events/destination_events.dart';

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({super.key, required this.type, this.tabIndex = 0});
  final DestinationType type;
  final int tabIndex;

  @override
  State<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(
    length: 4,
    vsync: this,
    initialIndex: _clampIndex(widget.tabIndex),
  )..addListener(_handleTabChanged);
  AnimationController? _fade;

  double? _tabBarSize;
  bool _useNavRail = false;
  // Tracks whether the photo gallery currently has photos to display.
  // Drives `showTabBarBg`: the pill hides under fullscreen photos but stays
  // visible while the gallery is loading or empty so icons aren't floating
  // on a black void.
  bool _photoTabHasContent = false;

  @override
  void initState() {
    super.initState();
    _prefetchMedia();
  }

  @override
  void didUpdateWidget(covariant DestinationDetailsScreen oldWidget) {
    if (oldWidget.tabIndex != widget.tabIndex) {
      _tabController.index = _clampIndex(widget.tabIndex);
    }
    if (oldWidget.type != widget.type) _prefetchMedia();
    super.didUpdateWidget(oldWidget);
  }

  /// The Photos and Artifacts tabs are only built when first opened. Start
  /// loading their lists and small images now, in the background, so those
  /// tabs open without a wait. Both lists are cached, so the tabs reuse them.
  void _prefetchMedia() {
    final type = widget.type;
    unawaited(destinationPhotosLogic.prefetch(type));
    unawaited(
      artifactsBloc.getForDestination(type).then((a) => prefetchPhotoUrls(a.highlights.map((h) => h.imageSmall))),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _clampIndex(int index) => index.clamp(0, 3);

  void _handleTabChanged() {
    _fade?.forward(from: 0);
    setState(() {});
  }

  void _handleTabTapped(int index) {
    _tabController.index = index;
    context.go(ScreenPaths.destinationDetails(widget.type, tabIndex: _tabController.index));
  }

  void _handleTabMenuSized(Size size) {
    setState(() {
      _tabBarSize = (_useNavRail ? size.width : size.height) - DestinationDetailsTabMenu.buttonInset;
    });
  }

  @override
  Widget build(BuildContext context) {
    _useNavRail = appLogic.shouldUseNavRail();

    final destination = destinationsLogic.getData(widget.type);
    int tabIndex = _tabController.index;
    bool showTabBarBg = tabIndex != 1 || !_photoTabHasContent;
    final tabBarSize = _tabBarSize ?? 0;
    final menuPadding = _useNavRail ? EdgeInsets.only(left: tabBarSize) : EdgeInsets.only(bottom: tabBarSize);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          /// Fullscreen tab views
          LazyIndexedStack(
            index: _tabController.index,
            children: [
              DestinationEditorialScreen(destination, contentPadding: menuPadding),
              PhotoGallery(
                destinationType: destination.type,
                onHasPhotosChanged: (has) {
                  if (_photoTabHasContent != has) {
                    setState(() => _photoTabHasContent = has);
                  }
                },
              ),
              ArtifactCarouselScreen(type: destination.type, contentPadding: menuPadding),
              DestinationEvents(type: widget.type, contentPadding: menuPadding),
            ],
          ),

          /// Tab menu
          Align(
            alignment: _useNavRail ? Alignment.centerLeft : Alignment.bottomCenter,
            child: MeasurableWidget(
              onChange: _handleTabMenuSized,
              child: DestinationDetailsTabMenu(
                tabController: _tabController,
                onTap: _handleTabTapped,
                destinationType: destination.type,
                showBg: showTabBarBg,
                axis: _useNavRail ? Axis.vertical : Axis.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
