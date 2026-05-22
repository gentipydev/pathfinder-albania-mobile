import 'package:travel_buddy/common_libs.dart';

class DestinationDetailsTabMenu extends StatelessWidget {
  static const double buttonInset = 12;
  static const double homeBtnSize = 74;
  static const double minTabSize = 25;
  static const double maxTabSize = 100;

  const DestinationDetailsTabMenu({
    super.key,
    required this.tabController,
    this.showBg = false,
    required this.destinationType,
    this.axis = Axis.horizontal,
    required this.onTap,
  });

  final TabController tabController;
  final bool showBg;
  final DestinationType destinationType;
  final Axis axis;
  bool get isVertical => axis == Axis.vertical;

  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    Color iconColor = showBg ? $styles.colors.black : $styles.colors.white;
    // Measure available size after subtracting the home button size and insets
    final availableSize = ((isVertical ? context.heightPx : context.widthPx) - homeBtnSize - $styles.insets.md);
    // Calculate tabBtnSize based on availableSize
    final double tabBtnSize = (availableSize / 4).clamp(minTabSize, maxTabSize);
    // Figure out some extra gap, in the case that the tabBtns are wider than the homeBtn
    final double gapAmt = max(0, tabBtnSize - homeBtnSize);
    // Store off safe areas which we will need to respect in the layout below
    final double safeAreaBtm = context.mq.padding.bottom, safeAreaTop = context.mq.padding.top;
    // Insets the bg from the rounded destination icon making it appear offset. The tab btns will use the same padding.
    final buttonInsetPadding = isVertical ? EdgeInsets.only(right: buttonInset) : EdgeInsets.only(top: buttonInset);
    return Padding(
      padding: isVertical ? EdgeInsets.only(top: safeAreaTop) : EdgeInsets.zero,
      child: Stack(
        children: [
          /// Background, animates in and out based on `showBg`,
          /// has padding along the inside edge which makes the home-btn appear to hang over the edge.
          Positioned.fill(
            child: Padding(
              padding: buttonInsetPadding,
              child: AnimatedOpacity(
                duration: $styles.times.fast,
                opacity: showBg ? 1 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: $styles.colors.white,
                    borderRadius: isVertical ? BorderRadius.only(topRight: Radius.circular(32)) : null,
                  ),
                ),
              ),
            ),
          ),

          /// Buttons
          /// A centered row / column of tabButtons w/ an destination home button
          Padding(
            /// When in hz mode add safeArea bottom padding, vertical layout should not need it
            padding: EdgeInsets.only(bottom: isVertical ? 0 : safeAreaBtm),
            child: SizedBox(
              width: isVertical ? null : double.infinity,
              height: isVertical ? double.infinity : null,
              child: FocusTraversalGroup(
                child: Flex(
                  direction: axis,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Home btn
                    Padding(
                      /// Small amt of padding for home-btn
                      padding: isVertical
                          ? EdgeInsets.only(left: $styles.insets.xs)
                          : EdgeInsets.only(bottom: $styles.insets.xs),
                      child: _DestinationHomeBtn(
                        size: homeBtnSize,
                        destinationType: destinationType,
                        borderSize: showBg ? 6 : 2,
                      ),
                    ),
                    Gap(gapAmt),

                    /// A second Row / Col holding tab buttons
                    /// Add the btn inset padding so they will be centered on the colored background
                    Padding(
                      padding: buttonInsetPadding,
                      child: Flex(
                        direction: axis,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Tabs
                          _TabBtn(
                            0,
                            tabController,
                            iconImg: 'editorial',
                            label: $strings.destinationDetailsTabLabelInformation,
                            color: iconColor,
                            axis: axis,
                            mainAxisSize: tabBtnSize,
                            onTap: onTap,
                          ),
                          _TabBtn(
                            1,
                            tabController,
                            iconImg: 'photos',
                            label: $strings.destinationDetailsTabLabelImages,
                            color: iconColor,
                            axis: axis,
                            mainAxisSize: tabBtnSize,
                            onTap: onTap,
                          ),
                          _TabBtn(
                            2,
                            tabController,
                            iconImg: 'artifacts',
                            label: $strings.destinationDetailsTabLabelArtifacts,
                            color: iconColor,
                            axis: axis,
                            mainAxisSize: tabBtnSize,
                            onTap: onTap,
                          ),
                          _TabBtn(
                            3,
                            tabController,
                            iconImg: 'timeline',
                            label: $strings.destinationDetailsTabLabelEvents,
                            color: iconColor,
                            axis: axis,
                            mainAxisSize: tabBtnSize,
                            onTap: onTap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationHomeBtn extends StatelessWidget {
  const _DestinationHomeBtn({required this.size, required this.destinationType, required this.borderSize});

  final double size;
  final DestinationType destinationType;
  final double borderSize;

  @override
  Widget build(BuildContext context) {
    return CircleBtn(
      onPressed: () => context.go(ScreenPaths.home),
      bgColor: $styles.colors.white,
      semanticLabel: $strings.destinationDetailsTabSemanticBack,
      child: AnimatedContainer(
        curve: Curves.easeOut,
        duration: $styles.times.fast,
        width: size - borderSize * 2,
        height: size - borderSize * 2,
        margin: EdgeInsets.all(borderSize),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: destinationType.fgColor,
          image: DecorationImage(image: AssetImage(destinationType.homeBtn), fit: BoxFit.fill),
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn(
    this.index,
    this.tabController, {
    required this.iconImg,
    required this.color,
    required this.label,
    required this.axis,
    required this.mainAxisSize,
    required this.onTap,
  });

  static const double crossBtnSize = 60;

  final int index;
  final TabController tabController;
  final String iconImg;
  final Color color;
  final String label;
  final Axis axis;
  final double mainAxisSize;
  final void Function(int index) onTap;

  bool get _isVertical => axis == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    bool selected = tabController.index == index;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final iconImgPath = '${ImagePaths.common}/tab-$iconImg${selected ? '-active' : ''}.png';
    String tabLabel = localizations.tabLabel(tabIndex: index + 1, tabCount: tabController.length);
    tabLabel = '$label: $tabLabel';

    final double iconSize = min(mainAxisSize, 32);

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        label: tabLabel,
        child: ExcludeSemantics(
          child: AppBtn.basic(
            onPressed: () => onTap(index),
            semanticLabel: label,
            minimumSize: _isVertical ? Size(crossBtnSize, mainAxisSize) : Size(mainAxisSize, crossBtnSize),
            // Image icon
            child: Image.asset(
              iconImgPath,
              height: iconSize,
              width: iconSize,
              color: selected ? null : color,
            ),
          ),
        ),
      ),
    );
  }
}
