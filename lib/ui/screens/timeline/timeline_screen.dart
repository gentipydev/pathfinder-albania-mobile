import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/common/animate_utils.dart';
import 'package:pathfinder_albania/logic/common/debouncer.dart';
import 'package:pathfinder_albania/logic/common/string_utils.dart';
import 'package:pathfinder_albania/logic/data/timeline_data.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';
import 'package:pathfinder_albania/ui/common/blend_mask.dart';
import 'package:pathfinder_albania/ui/common/centered_box.dart';
import 'package:pathfinder_albania/ui/common/controls/app_header.dart';
import 'package:pathfinder_albania/ui/common/dashed_line.dart';
import 'package:pathfinder_albania/ui/common/ignore_pointer.dart';
import 'package:pathfinder_albania/ui/common/list_gradient.dart';
import 'package:pathfinder_albania/ui/common/timeline_event_card.dart';
import 'package:pathfinder_albania/ui/common/utils/app_haptics.dart';
import 'package:pathfinder_albania/ui/common/utils/duration_utils.dart';
import 'package:pathfinder_albania/ui/common/destinations_timeline_builder.dart';

part 'widgets/_animated_era_text.dart';
part 'widgets/_bottom_scrubber.dart';
part 'widgets/_dashed_divider_with_year.dart';
part 'widgets/_event_markers.dart';
part 'widgets/_event_popups.dart';
part 'widgets/_scrolling_viewport.dart';
part 'widgets/_scrolling_viewport_controller.dart';
part 'widgets/_timeline_section.dart';
part 'widgets/_year_markers.dart';

class TimelineScreen extends StatefulWidget {
  final DestinationType? type;

  const TimelineScreen({super.key, required this.type});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  /// Create a scroll controller that the top and bottom timelines can share
  final ScrollController _scroller = ScrollController();

  /// Starts where the viewport starts (the timeline's first year), so the era label is right before any scroll.
  final _year = ValueNotifier<int>(destinationsLogic.timelineStartYear);

  /// Ticks when the main timeline's extent or viewport changes (first layout, zoom, resize). The scroll offset
  /// doesn't always move then (e.g. when opening at 1500 BCE), so the scrubber listens to this as well.
  final _scrollMetricsVersion = ValueNotifier<int>(0);

  @override
  void dispose() {
    _scroller.dispose();
    _year.dispose();
    _scrollMetricsVersion.dispose();
    super.dispose();
  }

  bool _handleScrollMetricsChanged(ScrollMetricsNotification n) {
    if (n.depth == 0) _scrollMetricsVersion.value++;
    return false;
  }

  void _handleViewportYearChanged(int value) => _year.value = value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // Determine min and max size of the timeline based on the size available to this widget
        const double scrubberSize = 80;
        const double minSize = 1200;
        const double maxSize = 5500;
        return Container(
          color: $styles.colors.black,
          child: Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: Column(
              children: [
                AppHeader(title: $strings.timelineTitle),

                /// Vertically scrolling timeline, manages a ScrollController.
                Expanded(
                  child: NotificationListener<ScrollMetricsNotification>(
                    onNotification: _handleScrollMetricsChanged,
                    child: _ScrollingViewport(
                      scroller: _scroller,
                      minSize: minSize,
                      maxSize: maxSize,
                      selectedDestination: widget.type,
                      onYearChanged: _handleViewportYearChanged,
                    ),
                  ),
                ),

                /// Era Text (classical, modern etc)
                ValueListenableBuilder<int>(
                  valueListenable: _year,
                  builder: (_, value, _) => _AnimatedEraText(value),
                ),
                Gap($styles.insets.xs),

                /// Mini Horizontal timeline, reacts to the state of the larger scrolling timeline,
                /// and changes the timelines scroll position on Hz drag
                CenteredBox(
                  width: $styles.sizes.maxContentWidth1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
                    child: _BottomScrubber(
                      _scroller,
                      scrollMetrics: _scrollMetricsVersion,
                      size: scrubberSize,
                      selectedDestination: widget.type,
                    ),
                  ),
                ),
                Gap($styles.insets.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}
