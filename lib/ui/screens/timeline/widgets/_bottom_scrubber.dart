part of '../timeline_screen.dart';

class _BottomScrubber extends StatelessWidget {
  const _BottomScrubber(
    this.scroller, {
    required this.scrollMetrics,
    required this.size,
    required this.selectedDestination,
  });
  final ScrollController? scroller;

  /// Notifies when the main timeline's extent or viewport changes, which resizes the box.
  final Listenable scrollMetrics;
  final double size;
  final DestinationType? selectedDestination;

  /// Calculate what fraction the scroller has travelled
  double _calculateScrollFraction(ScrollPosition? pos) {
    if (pos == null || pos.maxScrollExtent == 0) return 0;
    return (pos.pixels / pos.maxScrollExtent).clamp(0, 1);
  }

  /// Width, in scrubber pixels, of the span of years the main timeline currently shows.
  /// The main view's scroll extent equals its content height, so viewport / extent is the visible share of the years.
  double _calculateViewWidth(ScrollPosition? pos, double trackWidth, double maxWidth) {
    if (pos == null || pos.maxScrollExtent == 0) return maxWidth;
    return (pos.viewportDimension / pos.maxScrollExtent * trackWidth).clamp(0, maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    final scroller = this.scroller;

    /// It might take a frame until we receive a valid scroller
    if (scroller == null) return SizedBox.shrink();

    // The mini timeline below is inset by this padding, so its years span the width minus the padding on each side.
    final inset = $styles.insets.md;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final trackWidth = math.max(1.0, width - inset * 2);

        // Dragging moves the "now" line 1:1 with the finger.
        void handleScrubberPan(DragUpdateDetails details) {
          if (!scroller.hasClients) return;
          final pos = scroller.position;
          double newPos = pos.pixels + details.delta.dx * pos.maxScrollExtent / trackWidth;
          pos.jumpTo(newPos.clamp(0, pos.maxScrollExtent));
        }

        // Tapping glides the timeline to the tapped year.
        void handleScrubberTap(TapUpDetails details) {
          if (!scroller.hasClients) return;
          final pos = scroller.position;
          final fraction = ((details.localPosition.dx - inset) / trackWidth).clamp(0.0, 1.0);
          scroller.animateTo(
            fraction * pos.maxScrollExtent,
            duration: $styles.times.med,
            curve: Curves.easeOutCubic,
          );
        }

        return SizedBox(
          height: size,
          child: Stack(
            children: [
              /// Timeline background
              Container(
                padding: EdgeInsets.all(inset),
                decoration: BoxDecoration(
                  color: $styles.colors.greyStrong,
                  borderRadius: BorderRadius.circular($styles.corners.md),
                ),
                child: DestinationsTimelineBuilder(
                  crossAxisGap: 4,
                  selectedDestinations: selectedDestination != null ? [selectedDestination!] : [],
                ),
              ),

              /// Visible area, follows the position of scroller
              AnimatedBuilder(
                animation: Listenable.merge([scroller, scrollMetrics]),
                builder: (_, _) {
                  ScrollPosition? pos;
                  if (scroller.hasClients) pos = scroller.position;
                  final scrollFraction = _calculateScrollFraction(pos);
                  // The dashed line marks the current year on the mini timeline.
                  final lineX = inset + scrollFraction * trackWidth;
                  // The box shows the visible span, centred on the line, and stops at the panel's edges.
                  final boxWidth = _calculateViewWidth(pos, trackWidth, width);
                  final boxLeft = (lineX - boxWidth / 2).clamp(0.0, width - boxWidth);
                  final startYr = destinationsLogic.timelineStartYear, endYr = destinationsLogic.timelineEndYear;
                  final currentYr = (startYr + scrollFraction * (endYr - startYr)).round();

                  return Positioned.fill(
                    child: Semantics(
                      container: true,
                      slider: true,
                      label: $strings.bottomScrubberSemanticTimeline,
                      value: StringUtils.formatYr(currentYr),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        // Count the drag from touch-down, so the line doesn't trail the finger by the drag slop.
                        dragStartBehavior: DragStartBehavior.down,
                        onPanUpdate: handleScrubberPan,
                        onTapUp: handleScrubberTap,
                        child: Stack(
                          children: [
                            /// Scrub area
                            Positioned(
                              left: boxLeft,
                              width: boxWidth,
                              top: 0,
                              bottom: 0,
                              child: _buildOutlineBox(),
                            ),

                            /// Current year (DashedLine paints at its left edge). Inset by the box's 1px border
                            /// so the last dash can't poke past the box's rounded bottom edge.
                            Positioned(
                              left: lineX,
                              width: 2,
                              top: 1,
                              bottom: 1,
                              child: DashedLine(vertical: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Rounded like the panel, so at either end it sits flush with the panel's corners.
  Widget _buildOutlineBox() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: $styles.colors.white),
        borderRadius: BorderRadius.circular($styles.corners.md),
      ),
    );
  }
}
