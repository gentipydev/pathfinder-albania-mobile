import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/common/animate_utils.dart';
import 'package:pathfinder_albania/logic/common/platform_info.dart';
import 'package:pathfinder_albania/logic/common/string_utils.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';
import 'package:pathfinder_albania/ui/common/app_backdrop.dart';
import 'package:pathfinder_albania/ui/common/app_icons.dart';
import 'package:pathfinder_albania/ui/common/centered_box.dart';
import 'package:pathfinder_albania/ui/common/controls/app_header.dart';
import 'package:pathfinder_albania/ui/common/curved_clippers.dart';
import 'package:pathfinder_albania/ui/common/hidden_collectible.dart';
import 'package:pathfinder_albania/ui/common/list_gradient.dart';
import 'package:pathfinder_albania/ui/common/themed_text.dart';
import 'package:pathfinder_albania/ui/common/timeline_event_card.dart';
import 'package:pathfinder_albania/ui/common/utils/duration_utils.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_title_text.dart';

part 'widgets/_events_list.dart';
part 'widgets/_timeline_btn.dart';
part 'widgets/_destination_image_with_timeline.dart';

class DestinationEvents extends StatefulWidget {
  const DestinationEvents({super.key, required this.type, this.contentPadding = EdgeInsets.zero});
  final DestinationType type;
  final EdgeInsets contentPadding;
  @override
  State<DestinationEvents> createState() => _DestinationEventsState();
}

class _DestinationEventsState extends State<DestinationEvents> {
  late final _data = destinationsLogic.getData(widget.type);
  final _eventsListKey = GlobalKey<_EventsListState>();
  double _scrollPos = 0;

  void _handleScroll(double pos) => _scrollPos = pos;

  @override
  Widget build(BuildContext context) {
    void handleTimelineBtnPressed() => context.go(ScreenPaths.timeline(widget.type));
    // Main view content switches between 1 and 2 column layouts
    // On mobile, use the 2 column layout on screens close to landscape (>.85). This is primarily an optimization for foldable devices which have square-ish dimensions when opened.
    final twoColumnAspect = PlatformInfo.isMobile ? .85 : 1;
    bool useTwoColumnLayout = context.mq.size.aspectRatio > twoColumnAspect;
    bool smallMode = context.heightPx < 550;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: $styles.colors.black,
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                /// Main view
                Positioned.fill(
                  top: smallMode ? 0 : $styles.insets.sm,
                  child: Padding(
                    padding: widget.contentPadding,
                    child: useTwoColumnLayout ? _buildTwoColumn(context) : _buildSingleColumn(),
                  ),
                ),

                /// Header w/ TimelineBtn
                TopCenter(
                  child: AppHeader(
                    showBackBtn: false,
                    isTransparent: true,
                    trailing: (_) => CircleIconBtn(
                      icon: AppIcons.timeline,
                      onPressed: handleTimelineBtnPressed,
                      semanticLabel: $strings.eventsListButtonOpenTimeline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Landscape layout is a row, with the DestinationImage on left and EventsList on the right
  Widget _buildTwoColumn(BuildContext context) {
    bool smallMode = context.heightPx < 550;
    final double timelineImageSize = (context.heightPx - 200).clamp(200, 500);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: smallMode ? $styles.insets.sm : $styles.insets.lg,
        horizontal: $styles.insets.sm,
      ),
      child: Row(
        children: [
          /// DestinationImage w/ Timeline btn
          Expanded(
            child: CenteredBox(
              width: $styles.sizes.maxContentWidth3,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: smallMode ? $styles.insets.sm : $styles.insets.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DestinationImageWithTimeline(data: _data, height: timelineImageSize),
                    Gap(smallMode ? $styles.insets.md : $styles.insets.lg),
                    SizedBox(width: 400, child: _TimelineBtn(type: widget.type)),
                  ],
                ),
              ),
            ),
          ),

          /// EventsList
          Expanded(
            child: CenteredBox(
              width: $styles.sizes.maxContentWidth2,
              child: _EventsList(
                key: _eventsListKey,
                data: _data,
                topHeight: 100,
                blurOnScroll: false,
                onScroll: _handleScroll,
                initialScrollOffset: _scrollPos,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Portrait layout is a stack with the EventsList scrolling overtop of the DestinationImage
  Widget _buildSingleColumn() {
    return LayoutBuilder(
      builder: (_, constraints) {
        double topHeight = max(constraints.maxHeight * .55, 200);
        return CenteredBox(
          width: $styles.sizes.maxContentWidth2,
          child: Stack(
            children: [
              /// Top content, sits underneath scrolling list
              _DestinationImageWithTimeline(height: topHeight, data: _data),

              /// EventsList + TimelineBtn
              Column(
                children: [
                  Expanded(
                    /// EventsList
                    child: _EventsList(
                      key: _eventsListKey,
                      data: _data,
                      topHeight: topHeight,
                      blurOnScroll: true,
                      showTopGradient: false,
                      onScroll: _handleScroll,
                      initialScrollOffset: _scrollPos,
                    ),
                  ),
                  Gap($styles.insets.lg),

                  /// TimelineBtn
                  _TimelineBtn(type: _data.type, width: $styles.sizes.maxContentWidth2),
                  Gap($styles.insets.lg),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
