import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/settings/bloc/settings_event.dart';
import 'package:travel_buddy/logic/common/animate_utils.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';
import 'package:travel_buddy/ui/common/app_icons.dart';
import 'package:travel_buddy/ui/common/controls/app_page_indicator.dart';
import 'package:travel_buddy/ui/common/controls/locale_switcher.dart';
import 'package:travel_buddy/ui/common/controls/trackpad_listener.dart';
import 'package:travel_buddy/ui/common/gradient_container.dart';
import 'package:travel_buddy/ui/common/ignore_pointer.dart';
import 'package:travel_buddy/ui/common/previous_next_navigation.dart';
import 'package:travel_buddy/ui/common/themed_text.dart';
import 'package:travel_buddy/ui/common/utils/app_haptics.dart';
import 'package:travel_buddy/ui/common/utils/duration_utils.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/animated_clouds.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_illustration.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_illustration_config.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_title_text.dart';

part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Shows a horizontally scrollable list PageView sandwiched between Foreground and Background layers
/// arranged in a parallax style.
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  List<DestinationData> get _destinations => destinationsLogic.all;

  /// Set initial destinationIndex
  late int _destinationIndex = 0;
  int get _numDestinations => _destinations.length;

  /// Used to polish the transition when leaving this page for the details view.
  /// Used to capture the _swipeAmt at the time of transition, and freeze the destination foreground in place as we transition away.
  double? _swipeOverride;

  /// Used to let the foreground fade in when this view is returned to (from details)
  bool _fadeInOnNextBuild = false;

  /// All of the items that should fade in when returning from details view.
  /// Using individual tweens is more efficient than tween the entire parent
  final _fadeAnims = <AnimationController>[];

  DestinationData get currentDestination => _destinations[_destinationIndex];

  late final _VerticalSwipeController _swipeController = _VerticalSwipeController(
    this,
    _showDetailsPage,
  );

  bool _isSelected(DestinationType t) => t == currentDestination.type;

  @override
  void initState() {
    super.initState();
    // Load previously saved destinationIndex if we have one
    _destinationIndex = settingsBloc.state.prevDestinationIndex ?? 0;
    // allow 'infinite' scrolling by starting at a very high page number, add destinationIndex to start on the correct page
    final initialPage = _numDestinations * 100 + _destinationIndex;
    // Create page controller,
    _pageController = PageController(viewportFraction: 1, initialPage: initialPage);
  }

  void _handlePageChanged(int value) {
    final newIndex = value % _numDestinations;
    if (newIndex == _destinationIndex) {
      return; // Exit early if we're already on this page
    }
    setState(() {
      _destinationIndex = newIndex;
      settingsBloc.add(SettingsPrevDestinationIndexChanged(_destinationIndex));
    });
    AppHaptics.lightImpact();
  }

  void _handleFadeAnimInit(AnimationController controller) {
    _fadeAnims.add(controller);
    controller.value = 1;
  }

  void _handlePageIndicatorDotPressed(int index) => _setPageIndex(index);

  void _handlePrevNext(int i) => _setPageIndex(_destinationIndex + i, animate: true);

  void _setPageIndex(int index, {bool animate = false}) {
    if (index == _destinationIndex) return;
    // To support infinite scrolling, we can't jump directly to the pressed index. Instead, make it relative to our current position.
    final pos = ((_pageController.page ?? 0) / _numDestinations).floor() * _numDestinations;
    final newIndex = pos + index;
    if (animate == true) {
      _pageController.animateToPage(
        newIndex,
        duration: $styles.times.med,
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.jumpToPage(newIndex);
    }
  }

  void _showDetailsPage() async {
    _swipeOverride = _swipeController.swipeAmt.value;
    context.go(ScreenPaths.destinationDetails(currentDestination.type, tabIndex: 0));
    await Future.delayed(100.delayMs);
    _swipeOverride = null;
    _fadeInOnNextBuild = true;
  }

  void _startDelayedFgFade() async {
    try {
      for (var a in _fadeAnims) {
        a.value = 0;
      }
      await Future.delayed(300.delayMs);
      for (var a in _fadeAnims) {
        a.forward();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handleTrackpadScroll(Offset direction) {
    if (direction.dy < 0) {
      _showDetailsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeInOnNextBuild == true) {
      _startDelayedFgFade();
      _fadeInOnNextBuild = false;
    }

    return _swipeController.wrapGestureDetector(
      Container(
        color: $styles.colors.black,
        child: TrackpadListener(
          scrollSensitivity: 60,
          onScroll: _handleTrackpadScroll,
          child: PreviousNextNavigation(
            listenToMouseWheel: false,
            onPreviousPressed: () => _handlePrevNext(-1),
            onNextPressed: () => _handlePrevNext(1),
            child: Stack(
              children: [
                /// Background
                ..._buildBgAndClouds(),

                /// Destinations Illustrations (main content)
                _buildMgPageView(),

                /// Foreground illustrations and gradients
                _buildFgAndGradients(),

                /// Controls that float on top of the various illustrations
                _buildFloatingUi(),
              ],
            ).maybeAnimate().fadeIn(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  Widget _buildMgPageView() {
    return ExcludeSemantics(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemBuilder: (_, index) {
          final destination = _destinations[index % _destinations.length];
          final destinationType = destination.type;
          bool isShowing = _isSelected(destinationType);
          return _swipeController.buildListener(
            builder: (swipeAmt, _, child) {
              final config = DestinationIllustrationConfig.mg(
                isShowing: isShowing,
                zoom: .05 * swipeAmt,
              );
              return DestinationIllustration(destinationType, config: config);
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBgAndClouds() {
    return [
      // Background
      ..._destinations.map((e) {
        final config = DestinationIllustrationConfig.bg(isShowing: _isSelected(e.type));
        return DestinationIllustration(e.type, config: config);
      }),
      // Clouds
      FractionallySizedBox(
        widthFactor: 1,
        heightFactor: .5,
        child: AnimatedClouds(destinationType: currentDestination.type, opacity: 1),
      ),
    ];
  }

  Widget _buildFgAndGradients() {
    Widget buildSwipeableBgGradient(Color fgColor) {
      return _swipeController.buildListener(
        builder: (swipeAmt, isPointerDown, _) {
          return IgnorePointerAndSemantics(
            child: FractionallySizedBox(
              heightFactor: .6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fgColor.withValues(alpha: 0),
                      fgColor.withValues(
                        alpha: .5 + fgColor.a * .25 + (isPointerDown ? .05 : 0) + swipeAmt * .20,
                      ),
                    ],
                    stops: const [0, 1],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final gradientColor = currentDestination.type.bgColor;
    return Stack(
      children: [
        /// Foreground gradient-1, gets darker when swiping up
        BottomCenter(
          child: buildSwipeableBgGradient(gradientColor.withValues(alpha: .65)),
        ),

        /// Foreground decorators
        ..._destinations.map((e) {
          return _swipeController.buildListener(
            builder: (swipeAmt, _, child) {
              final config = DestinationIllustrationConfig.fg(
                isShowing: _isSelected(e.type),
                zoom: .4 * (_swipeOverride ?? swipeAmt),
              );
              return Animate(
                effects: const [FadeEffect()],
                onPlay: _handleFadeAnimInit,
                child: IgnorePointerAndSemantics(child: DestinationIllustration(e.type, config: config)),
              );
            },
          );
        }),

        /// Foreground gradient-2, gets darker when swiping up
        BottomCenter(
          child: buildSwipeableBgGradient(gradientColor),
        ),
      ],
    );
  }

  Widget _buildFloatingUi() {
    return Stack(
      children: [
        /// Floating controls / UI
        AnimatedSwitcher(
          duration: $styles.times.fast,
          child: RepaintBoundary(
            child: OverflowBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: double.infinity),
                  const Spacer(),

                  /// Title Content
                  LightText(
                    child: IgnorePointerKeepSemantics(
                      child: Transform.translate(
                        offset: Offset(0, 30),
                        child: Column(
                          children: [
                            Semantics(
                              liveRegion: true,
                              button: true,
                              header: true,
                              onIncrease: () => _setPageIndex(_destinationIndex + 1),
                              onDecrease: () => _setPageIndex(_destinationIndex - 1),
                              onTap: () => _showDetailsPage(),
                              child: DestinationTitleText(currentDestination, enableShadows: true),
                            ),
                            Gap($styles.insets.md),
                            AppPageIndicator(
                              count: _numDestinations,
                              controller: _pageController,
                              color: $styles.colors.white,
                              dotSize: 8,
                              onDotPressed: _handlePageIndicatorDotPressed,
                              semanticPageTitle: $strings.homeSemanticDestination,
                            ),
                            Gap($styles.insets.md),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Animated arrow and background
                  /// Wrap in a container that is full-width to make it easier to find for screen readers
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,

                    /// Lose state of child objects when index changes, this will re-run all the animated switcher and the arrow anim
                    key: ValueKey(_destinationIndex),
                    child: Stack(
                      children: [
                        /// Expanding rounded rect that grows in height as user swipes up
                        Positioned.fill(
                          child: _swipeController.buildListener(
                            builder: (swipeAmt, _, child) {
                              double heightFactor = .5 + .5 * (1 + swipeAmt * 4);
                              return FractionallySizedBox(
                                alignment: Alignment.bottomCenter,
                                heightFactor: heightFactor,
                                child: Opacity(opacity: swipeAmt * .5, child: child),
                              );
                            },
                            child: VtGradient(
                              [
                                $styles.colors.white.withValues(alpha: 0),
                                $styles.colors.white.withValues(alpha: 1),
                              ],
                              const [.3, 1],
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),

                        /// Arrow Btn that fades in and out
                        _AnimatedArrowButton(
                          onTap: _showDetailsPage,
                          semanticTitle: currentDestination.title,
                        ),
                      ],
                    ),
                  ),
                  // Keep the arrow clear of the iOS home indicator when this
                  // screen is shown full-screen (APP_MODE=showcase). Inside the
                  // full-mode bottom nav the inset is already consumed, so this is 0.
                  Gap($styles.insets.md + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        ),

        /// Language toggle (same geometry as an AppHeader trailing btn)
        TopRight(
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64 * $styles.scale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const LocaleSwitcher(), Gap($styles.insets.sm)],
              ),
            ),
          ),
        ),

        /// Story timeline (same geometry as an AppHeader back btn)
        TopLeft(
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64 * $styles.scale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap($styles.insets.sm),
                  CircleIconBtn(
                    icon: AppIcons.timeline,
                    onPressed: () => context.go(ScreenPaths.timeline(null)),
                    semanticLabel: $strings.eventsListButtonOpenTimeline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
