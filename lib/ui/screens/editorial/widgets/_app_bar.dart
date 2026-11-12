part of '../editorial_screen.dart';

class _AppBar extends StatelessWidget {
  _AppBar(this.destinationType, {required this.sectionIndex, required this.scrollPos});
  final DestinationType destinationType;
  final ValueNotifier<int> sectionIndex;
  final ValueNotifier<double> scrollPos;
  final _titleValues = [
    $strings.appBarTitleFactsHistory,
    $strings.appBarTitleConstruction,
    $strings.appBarTitleLocation,
  ];

  final _iconValues = const [
    'history.png',
    'construction.png',
    'geography.png',
  ];

  ArchType _getArchType() {
    return switch (destinationType) {
      DestinationType.butrint => ArchType.flatPyramid,
      DestinationType.berat => ArchType.wideArch,
      DestinationType.gjirokaster => ArchType.arch,
      DestinationType.apollonia => ArchType.arch,
      DestinationType.theth => ArchType.pyramid,
      DestinationType.kruja => ArchType.wideArch,
      DestinationType.albanianAlps => ArchType.pyramid,
      DestinationType.korca => ArchType.spade,
    };
  }

  @override
  Widget build(BuildContext context) {
    final arch = _getArchType();
    return LayoutBuilder(
      builder: (_, constraints) {
        bool showOverlay = constraints.biggest.height < 300;
        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
                  duration: $styles.times.med,
                  child: Stack(
                    key: ValueKey(showOverlay),
                    fit: StackFit.expand,
                    children: [
                      /// Masked image
                      BottomCenter(
                        child: SizedBox(
                          width: showOverlay ? double.infinity : $styles.sizes.maxContentWidth1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: ClipPath(
                              // Switch arch type to Rect if we are showing the title bar
                              clipper: showOverlay ? null : ArchClipper(arch),
                              child: ValueListenableBuilder<double>(
                                valueListenable: scrollPos,
                                builder: (_, value, child) {
                                  double opacity = (.4 + (value / 1500)).clamp(0, 1);
                                  return ScalingListItem(
                                    scrollPos: scrollPos,
                                    child: Image.asset(
                                      destinationType.photo1,
                                      fit: BoxFit.cover,
                                      opacity: AlwaysStoppedAnimation(opacity),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// Colored overlay
                      if (showOverlay) ...[
                        AnimatedContainer(
                          duration: $styles.times.med,
                          color: destinationType.bgColor.withValues(alpha: showOverlay ? .8 : 0),
                        ),
                      ],
                    ],
                  ),
                )
                // The delayed intro fade wraps the switcher so it plays once when the page opens. Inside the
                // switched child it replayed on every arch <-> overlay swap, hiding the photo for ~0.7s.
                .maybeAnimate(delay: $styles.times.pageTransition + 500.delayMs)
                .fadeIn(duration: $styles.times.slow),

            /// Circular Titlebar
            BottomCenter(
              child: ValueListenableBuilder<int>(
                valueListenable: sectionIndex,
                builder: (_, value, _) {
                  return _CircularTitleBar(
                    index: value,
                    titles: _titleValues,
                    icons: _iconValues,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
