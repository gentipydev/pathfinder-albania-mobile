import 'dart:ui';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:pathfinder_albania/common_libs.dart' hide ShimmerEffect;
import 'package:pathfinder_albania/logic/common/animate_utils.dart';
import 'package:pathfinder_albania/logic/common/platform_info.dart';
import 'package:pathfinder_albania/logic/data/highlight_data.dart';
import 'package:pathfinder_albania/ui/common/controls/app_header.dart';
import 'package:pathfinder_albania/ui/common/controls/app_page_indicator.dart';
import 'package:pathfinder_albania/ui/common/ignore_pointer.dart';
import 'package:pathfinder_albania/ui/common/image_skeleton.dart';
import 'package:pathfinder_albania/ui/common/remote_photo.dart';
import 'package:pathfinder_albania/ui/common/static_text_scale.dart';

part 'widgets/_blurred_image_bg.dart';
part 'widgets/_bottom_text_content.dart';
part 'widgets/_collapsing_carousel_item.dart';

class ArtifactCarouselScreen extends StatefulWidget {
  const ArtifactCarouselScreen({
    super.key,
    required this.type,
    this.contentPadding = EdgeInsets.zero,
  });
  final DestinationType type;
  final EdgeInsets contentPadding;

  @override
  State<ArtifactCarouselScreen> createState() => _ArtifactScreenState();
}

class _ArtifactScreenState extends State<ArtifactCarouselScreen> {
  PageController? _pageController;
  final _currentPage = ValueNotifier<double>(9999);

  /// Loaded asynchronously from the bundled catalog. While it loads, the
  /// carousel is built from [_placeholders] as a skeleton, so wraparound
  /// math and `_BlurredImageBg` never see an empty list.
  late List<HighlightData> _artifacts;
  late final _currentArtifactIndex = ValueNotifier<int>(0);
  bool _isLoading = false;

  static final _placeholders = List.generate(5, HighlightData.placeholder);

  /// True while the skeleton carousel is showing.
  bool get _showSkeleton => _isLoading && _artifacts.isEmpty;

  /// What the carousel renders: the real highlights, or placeholders.
  List<HighlightData> get _items => _showSkeleton ? _placeholders : _artifacts;

  @override
  void initState() {
    super.initState();
    _artifacts = HighlightData.forDestination(widget.type);
    if (_artifacts.isEmpty) {
      _isLoading = true;
      _loadArtifacts();
    }
    _currentArtifactIndex.value = _wrappedPageIndex;
  }

  Future<void> _loadArtifacts() async {
    await artifactsBloc.getForDestination(widget.type);
    if (!mounted) return;
    setState(() {
      _artifacts = HighlightData.forDestination(widget.type);
      _isLoading = false;
      _currentArtifactIndex.value = _artifacts.isEmpty ? 0 : _wrappedPageIndex;
    });
  }

  int get _wrappedPageIndex => _currentPage.value.round() % _items.length;

  void _handlePageChanged() {
    _currentPage.value = _pageController?.page ?? 0;
    _currentArtifactIndex.value = _wrappedPageIndex;
  }

  void _handleArtifactTap(int index) {
    if (_showSkeleton) return;
    int delta = index - _currentPage.value.round();
    if (delta == 0) {
      HighlightData data = _artifacts[index % _artifacts.length];
      context.go(ScreenPaths.artifact(data.artifactId));
    } else {
      _pageController?.animateToPage(
        _currentPage.value.round() + delta,
        duration: $styles.times.fast,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) {
      return ColoredBox(
        color: $styles.colors.greyStrong,
        child: Stack(
          children: [
            Center(child: _buildEmptyState()),
            AppHeader(
              title: $strings.artifactsTitleArtifacts,
              showBackBtn: false,
              isTransparent: true,
            ),
          ],
        ),
      );
    }
    bool shortMode = context.heightPx <= 800;
    bool overlapMode = context.heightPx <= 450;
    final double bottomHeight = context.heightPx / (overlapMode ? 2 : 2.75); // Prev 340, dynamic seems to work better
    // Allow objects to become wider as the screen becomes tall, this allows
    // them to grow taller as well, filling the available space better.
    double itemHeight = (context.heightPx - 200 - bottomHeight).clamp(250, 400);
    double itemWidth = itemHeight * .666;
    // TODO: This could be optimized to only run if the size has changed...is it worth it?
    _pageController?.dispose();
    _pageController = PageController(
      viewportFraction: itemWidth / context.widthPx,
      initialPage: _currentPage.value.round(),
    );
    _pageController?.addListener(_handlePageChanged);
    final pages = items.map((e) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: _DoubleBorderImage(e),
      );
    }).toList();

    return Stack(
      children: [
        /// Blurred Bg
        Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: _currentArtifactIndex,
            builder: (_, value, _) {
              // The small copy is plenty: it's drawn blurred at half size.
              return _BlurredImageBg(url: items[value].imageUrlSmall);
            },
          ),
        ),

        Padding(
          padding: widget.contentPadding,
          child: Stack(
            children: [
              /// BgCircle
              _buildBgCircle(bottomHeight),

              /// Carousel Items
              PageView.builder(
                controller: _pageController,
                itemBuilder: (_, index) {
                  final wrappedIndex = index % pages.length;
                  final child = pages[wrappedIndex];
                  return ValueListenableBuilder<double>(
                    valueListenable: _currentPage,
                    builder: (_, value, _) {
                      final int offset = (value.round() - index).abs();
                      return _CollapsingCarouselItem(
                        width: itemWidth,
                        indexOffset: min(3, offset),
                        onPressed: () => _handleArtifactTap(index),
                        title: items[wrappedIndex].title,
                        child: child,
                      );
                    },
                  );
                },
              ),

              /// Bottom Text
              BottomCenter(
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentArtifactIndex,
                  builder: (_, value, _) => _BottomTextContent(
                    artifact: items[value],
                    height: bottomHeight,
                    shortMode: shortMode,
                    overlapMode: overlapMode,
                    state: this,
                  ),
                ),
              ),

              /// Header
              AppHeader(
                title: $strings.artifactsTitleArtifacts,
                showBackBtn: false,
                isTransparent: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final color = $styles.colors.offWhite;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.museum_outlined, size: $styles.insets.xl, color: color.withValues(alpha: 0.5)),
        Gap($styles.insets.xs),
        Text(
          $strings.artifactCarouselLabelNoArtifacts,
          style: $styles.text.body.copyWith(color: color.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  OverflowBox _buildBgCircle(double height) {
    const double size = 2000;
    return OverflowBox(
      maxWidth: size,
      maxHeight: size,
      child: Transform.translate(
        offset: Offset(0, size / 2),
        child: Container(
          decoration: BoxDecoration(
            color: $styles.colors.offWhite.withValues(alpha: 0.8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(size)),
          ),
        ),
      ),
    );
  }
}
