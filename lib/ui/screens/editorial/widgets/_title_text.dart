part of '../editorial_screen.dart';

class _TitleText extends StatelessWidget {
  const _TitleText(this.data, {required this.scroller});
  final DestinationData data;
  final ScrollController scroller;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: DefaultTextColor(
        color: $styles.colors.offWhite,
        child: StaticTextScale(
          child: Center(
            child: SizedBox(
              width: $styles.sizes.maxContentWidth1,
              child: Column(
                children: [
                  Gap($styles.insets.md),
                  Gap(30),

                  /// Destination title text
                  Semantics(
                    sortKey: OrdinalSortKey(0),
                    child: AnimatedBuilder(
                      animation: scroller,
                      builder: (_, _) {
                        final yPos = ContextUtils.getGlobalPos(context)?.dy ?? 0;
                        bool enableHero = yPos > -100;
                        return DestinationTitleText(data, enableHero: enableHero);
                      },
                    ),
                  ),
                  Gap($styles.insets.xs),

                  /// Region
                  Text(
                    data.regionTitle.toUpperCase(),
                    style: $styles.text.title1,
                    textAlign: TextAlign.center,
                  ),
                  Gap($styles.insets.md),

                  /// Date
                  Text(
                    $strings.titleLabelDate(
                      StringUtils.formatYr(data.startYr),
                      StringUtils.formatEndYr(data.endYr),
                    ),
                    style: $styles.text.h4,
                    textAlign: TextAlign.center,
                  ),
                  Gap($styles.insets.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
