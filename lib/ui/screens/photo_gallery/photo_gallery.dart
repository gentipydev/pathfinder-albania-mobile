import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_bloc.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_helpers.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_state.dart';
import 'package:travel_buddy/logic/common/animate_utils.dart';
import 'package:travel_buddy/ui/common/controls/app_loading_indicator.dart';
import 'package:travel_buddy/ui/common/controls/eight_way_swipe_detector.dart';
import 'package:travel_buddy/ui/common/fullscreen_keyboard_listener.dart';
import 'package:travel_buddy/ui/common/hidden_collectible.dart';
import 'package:travel_buddy/ui/common/modals/fullscreen_url_img_viewer.dart';
import 'package:travel_buddy/ui/common/remote_photo.dart';
import 'package:travel_buddy/ui/common/utils/app_haptics.dart';

part 'widgets/_animated_cutout_overlay.dart';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    this.imageSize,
    required this.destinationType,
    this.onHasPhotosChanged,
  });
  final Size? imageSize;
  final DestinationType destinationType;
  /// Fires `true` when real photos are about to render fullscreen, `false`
  /// while loading or when the manifest is empty. The parent uses this to
  /// keep the tab-bar pill visible on the empty state, where there's no
  /// photo backdrop for the design's edge-to-edge layout to sit on.
  final ValueChanged<bool>? onHasPhotosChanged;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  static const int _gridSize = 5;
  // Index starts in the middle of the grid (eg, 25 items, index will start at 13)
  int _index = ((_gridSize * _gridSize) / 2).round();
  Offset _lastSwipeDir = Offset.zero;
  final double _scale = 1;
  bool _skipNextOffsetTween = false;
  late Duration swipeDuration = $styles.times.med * .4;
  /// Public Supabase URLs returned by the backend manifest, padded out to
  /// `_imgCount` (25) by repeating the catalog if the user hasn't seeded
  /// enough photos yet.
  final _photoUrls = ValueNotifier<List<String>>([]);
  bool _isLoading = true;
  int get _imgCount => pow(_gridSize, 2).round();

  late final List<FocusNode> _focusNodes = List.generate(_imgCount, (index) => FocusNode());

  //TODO: Remove this field (and associated workarounds) once web properly supports ClipPath (https://github.com/flutter/flutter/issues/124675)
  final bool useClipPathWorkAroundForWeb = kIsWeb;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _focusNodes[_index].requestFocus();
  }

  Future<void> _loadPhotos() async {
    final fetched = await destinationPhotosLogic.getPhotos(widget.destinationType);
    if (!mounted) return;
    final padded = List<String>.from(fetched);
    if (padded.isNotEmpty) {
      while (padded.length < _imgCount) {
        padded.addAll(List.from(padded));
      }
      if (padded.length > _imgCount) padded.length = _imgCount;
    }
    setState(() {
      _photoUrls.value = padded;
      _isLoading = false;
    });
    widget.onHasPhotosChanged?.call(padded.isNotEmpty);
  }

  void _setIndex(int value, {bool skipAnimation = false}) {
    if (value < 0 || value >= _imgCount) return;
    _skipNextOffsetTween = skipAnimation;
    setState(() => _index = value);
    _focusNodes[value].requestFocus();
  }

  /// Determine the required offset to show the current selected index.
  /// index=0 is top-left, and the index=max is bottom-right.
  Offset _calculateCurrentOffset(double padding, Size size) {
    double halfCount = (_gridSize / 2).floorToDouble();
    Size paddedImageSize = Size(size.width + padding, size.height + padding);
    // Get the starting offset that would show the top-left image (index 0)
    final originOffset = Offset(
      halfCount * paddedImageSize.width,
      halfCount * paddedImageSize.height,
    );
    // Add the offset for the row/col
    int col = _index % _gridSize;
    int row = (_index / _gridSize).floor();
    final indexedOffset = Offset(-paddedImageSize.width * col, -paddedImageSize.height * row);
    return originOffset + indexedOffset;
  }

  /// Used for hiding collectibles around the photo grid.
  int _getCollectibleIndex() {
    return switch (widget.destinationType) {
      DestinationType.butrint || DestinationType.kruja => 0,
      DestinationType.gjirokaster || DestinationType.albanianAlps => _gridSize - 1,
      DestinationType.berat || DestinationType.theth => _imgCount - 1,
      DestinationType.apollonia || DestinationType.korca => _imgCount - _gridSize,
    };
  }

  bool _handleKeyDown(KeyDownEvent event) {
    final key = event.logicalKey;
    Map<LogicalKeyboardKey, int> keyActions = {
      LogicalKeyboardKey.arrowUp: -_gridSize,
      LogicalKeyboardKey.arrowDown: _gridSize,
      LogicalKeyboardKey.arrowRight: 1,
      LogicalKeyboardKey.arrowLeft: -1,
    };

    // Apply key action, exit early if no action is defined
    int? actionValue = keyActions[key];
    if (actionValue == null) return false;
    int newIndex = _index + actionValue;

    // Block actions along edges of the grid
    bool isRightSide = _index % _gridSize == _gridSize - 1;
    bool isLeftSide = _index % _gridSize == 0;
    bool outOfBounds = newIndex < 0 || newIndex >= _imgCount;
    if ((isRightSide && key == LogicalKeyboardKey.arrowRight) ||
        (isLeftSide && key == LogicalKeyboardKey.arrowLeft) ||
        outOfBounds) {
      return false;
    }
    _setIndex(newIndex);
    return true;
  }

  /// Converts a swipe direction into a new index
  void _handleSwipe(Offset dir) {
    // Calculate new index, y swipes move by an entire row, x swipes move one index at a time
    int newIndex = _index;
    if (dir.dy != 0) newIndex += _gridSize * (dir.dy > 0 ? -1 : 1);
    if (dir.dx != 0) newIndex += (dir.dx > 0 ? -1 : 1);
    // After calculating new index, exit early if we don't like it...
    if (newIndex < 0 || newIndex > _imgCount - 1) {
      return; // keep the index in range
    }
    if (dir.dx < 0 && newIndex % _gridSize == 0) {
      return; // prevent right-swipe when at right side
    }
    if (dir.dx > 0 && newIndex % _gridSize == _gridSize - 1) {
      return; // prevent left-swipe when at left side
    }
    _lastSwipeDir = dir;
    AppHaptics.lightImpact();
    _setIndex(newIndex);
  }

  Future<void> _handleImageTapped(int index, bool isSelected) async {
    final states = collectiblesBloc.state.statesById;
    if (_checkCollectibleIndex(index, states) && isSelected) return;
    if (_index == index) {
      final urls = List<String>.from(_photoUrls.value);
      int? newIndex = await appLogic.showFullscreenDialogRoute(
        context,
        FullscreenUrlImgViewer(urls: urls, index: _index),
      );

      if (newIndex != null) {
        _setIndex(newIndex, skipAnimation: true);
      }
    } else {
      _setIndex(index);
    }
  }

  void _handleImageFocusChanged(int index, bool isFocused) {
    if (isFocused) {
      _setIndex(index);
    }
  }

  bool _checkCollectibleIndex(int index, Map<String, int> states) {
    return index == _getCollectibleIndex() &&
        isCollectibleLost(states, widget.destinationType, 1);
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenKeyboardListener(
      onKeyDown: _handleKeyDown,
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _photoUrls,
        builder: (_, value, _) {
          if (value.isEmpty) {
            return _isLoading ? Center(child: AppLoadingIndicator()) : _buildEmptyState();
          }
          Size imgSize = context.isLandscape
              ? Size(context.widthPx * .5, context.heightPx * .66)
              : Size(context.widthPx * .66, context.heightPx * .5);
          imgSize = (widget.imageSize ?? imgSize) * _scale;
          // Get transform offset for the current _index
          final padding = $styles.insets.md;
          var gridOffset = _calculateCurrentOffset(padding, imgSize);
          gridOffset += Offset(0, -context.mq.padding.top / 2);
          final offsetTweenDuration = _skipNextOffsetTween ? Duration.zero : swipeDuration;
          final cutoutTweenDuration = _skipNextOffsetTween ? Duration.zero : swipeDuration * .5;
          return _AnimatedCutoutOverlay(
            animationKey: ValueKey(_index),
            cutoutSize: imgSize,
            swipeDir: _lastSwipeDir,
            duration: cutoutTweenDuration,
            opacity: _scale == 1 ? .7 : .5,
            enabled: useClipPathWorkAroundForWeb == false,
            child: SafeArea(
              bottom: false,
              // Place content in overflow box, to allow it to flow outside the parent
              child: OverflowBox(
                maxWidth: _gridSize * imgSize.width + padding * (_gridSize - 1),
                maxHeight: _gridSize * imgSize.height + padding * (_gridSize - 1),
                alignment: Alignment.center,
                // Detect swipes in order to change index
                child: EightWaySwipeDetector(
                  onSwipe: _handleSwipe,
                  threshold: 30,
                  // A tween animation builder moves from image to image based on current offset
                  child: TweenAnimationBuilder<Offset>(
                    tween: Tween(begin: gridOffset, end: gridOffset),
                    duration: offsetTweenDuration,
                    curve: Curves.easeOut,
                    builder: (_, value, child) => Transform.translate(offset: value, child: child),
                    child: FocusTraversalGroup(
                      //policy: OrderedTraversalPolicy(),
                      child: GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: _gridSize,
                        childAspectRatio: imgSize.aspectRatio,
                        mainAxisSpacing: padding,
                        crossAxisSpacing: padding,
                        children: List.generate(
                          _imgCount,
                          (i) => _buildImage(i, swipeDuration, imgSize),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(int index, Duration swipeDuration, Size imgSize) {
    /// Bind to collectibles.statesById because we might need to rebuild if a collectible is found.
    return FocusTraversalOrder(
      order: NumericFocusOrder(index.toDouble()),
      child: BlocSelector<CollectiblesBloc, CollectiblesState, Map<String, int>>(
        selector: (s) => s.statesById,
        builder: (_, states) {
          bool isSelected = index == _index;
          final imgUrl = _photoUrls.value[index];
          late String semanticLbl;
          if (_checkCollectibleIndex(index, states)) {
            semanticLbl = $strings.collectibleItemSemanticCollectible;
          } else {
            semanticLbl = !isSelected
                ? $strings.photoGallerySemanticFocus(index + 1, _imgCount)
                : $strings.photoGallerySemanticFullscreen(index + 1, _imgCount);
          }

          final photoWidget = TweenAnimationBuilder<double>(
            duration: $styles.times.med,
            curve: Curves.easeOut,
            tween: Tween(begin: 1, end: isSelected ? 1.15 : 1),
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: RemotePhoto(
              imgUrl,
              fit: BoxFit.cover,
            ).maybeAnimate().fade(),
          );

          return MergeSemantics(
            child: Semantics(
              focused: isSelected,
              image: !_checkCollectibleIndex(index, states),
              liveRegion: isSelected,
              onIncrease: () => _handleImageTapped(_index + 1, false),
              onDecrease: () => _handleImageTapped(_index - 1, false),
              child: _checkCollectibleIndex(index, states)
                  ? Center(
                      child: HiddenCollectible(
                        widget.destinationType,
                        index: 1,
                        size: 100,
                        focus: _focusNodes[index],
                      ),
                    )
                  : AppBtn.basic(
                      semanticLabel: semanticLbl,
                      focusNode: _focusNodes[index],
                      onFocusChanged: (isFocused) => _handleImageFocusChanged(index, isFocused),
                      onPressed: () => _handleImageTapped(index, isSelected),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: imgSize.width,
                          height: imgSize.height,
                          child: (useClipPathWorkAroundForWeb == false)
                              ? photoWidget
                              : Stack(
                                  children: [
                                    photoWidget,
                                    // Because the web platform doesn't support clipPath, we use a workaround to highlight the selected image
                                    Positioned.fill(
                                      child: AnimatedOpacity(
                                        duration: $styles.times.med,
                                        opacity: isSelected ? 0 : ($styles.highContrast ? 0.4 : 0.7),
                                        child: ColoredBox(color: $styles.colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final color = $styles.colors.greyMedium;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: $styles.insets.xl, color: color.withValues(alpha: 0.5)),
          Gap($styles.insets.xs),
          Text(
            $strings.photoGalleryLabelNoPhotos,
            style: $styles.text.body.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
