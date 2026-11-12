part of '../collection_screen.dart';

@immutable
class _CollectionFooter extends StatelessWidget {
  const _CollectionFooter({required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: $styles.insets.md, vertical: $styles.insets.sm),
          color: $styles.colors.greyStrong,
          child: SafeArea(
            top: false,
            child: CenteredBox(
              width: $styles.sizes.maxContentWidth1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressRow(context),
                  Gap($styles.insets.sm),
                  _buildProgressBar(context),
                  Gap($styles.insets.sm),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 0..1; the catalog is read asynchronously, so it can still be empty and must not divide by zero.
  double get _progress => total == 0 ? 0 : count / total;

  Widget _buildProgressRow(BuildContext context) {
    int percent = (_progress * 100).round();
    return Row(
      children: [
        Text(
          $strings.collectionLabelDiscovered(percent),
          style: $styles.text.body.copyWith(color: $styles.colors.accent1),
        ),
        Spacer(),
        Text(
          $strings.collectionLabelCount(count, total),
          style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final bar = Container(
      decoration: BoxDecoration(
        color: $styles.colors.accent1,
        borderRadius: BorderRadius.circular(1000),
      ),
    );
    return RepaintBoundary(
      child: Container(
        height: $styles.insets.xs,
        decoration: BoxDecoration(
          color: $styles.colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: $styles.disableAnimations
            // With reduce-motion the effects below never run, and they are the only thing that sizes the
            // bar, so it showed a full track. Size it directly instead.
            ? FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: _progress, child: bar)
            : bar
                  .maybeAnimate()
                  .fade(duration: 1500.animateMs, curve: Curves.easeOutExpo)
                  .custom(
                    builder: (_, m, child) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: m * _progress,
                      child: child,
                    ),
                  ),
      ),
    );
  }
}
