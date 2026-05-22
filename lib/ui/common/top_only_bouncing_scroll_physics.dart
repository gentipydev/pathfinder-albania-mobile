import 'package:flutter/widgets.dart';

/// Bounces at the top (preserves PopRouterOnOverScroll back-pop) but clamps
/// at the bottom so the parent Stack's destination bgColor can't bleed
/// through during a bottom overscroll bounce.
class TopOnlyBouncingScrollPhysics extends BouncingScrollPhysics {
  const TopOnlyBouncingScrollPhysics({super.parent});

  @override
  TopOnlyBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      TopOnlyBouncingScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value > position.maxScrollExtent) return value - position.maxScrollExtent;
    return 0.0;
  }
}
