import 'package:pathfinder_albania/common_libs.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.title,
    this.showBackBtn = true,
    this.isTransparent = false,
    this.onBack,
    this.trailing,
  });
  final String? title;
  final bool showBackBtn;
  final bool isTransparent;
  final VoidCallback? onBack;
  final Widget Function(BuildContext context)? trailing;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isTransparent ? Colors.transparent : $styles.colors.black,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64 * $styles.scale,
          child: Stack(
            children: [
              MergeSemantics(
                child: Semantics(
                  header: true,
                  child: Center(
                    child: Padding(
                      // Keep long titles clear of the back and trailing buttons.
                      padding: EdgeInsets.symmetric(horizontal: CircleBtn.defaultSize + $styles.insets.sm * 1.5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                title!.toUpperCase(),
                                textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
                                style: $styles.text.h4.copyWith(
                                  color: $styles.colors.offWhite,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Row(
                    children: [
                      Gap($styles.insets.sm),
                      if (showBackBtn) BackBtn(onPressed: onBack),
                      Spacer(),
                      if (trailing != null) trailing!.call(context),
                      Gap($styles.insets.sm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
