import 'package:flutter/foundation.dart';
import 'package:image_fade/image_fade.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/common/retry_image.dart';
import 'package:travel_buddy/ui/common/controls/app_loading_indicator.dart';
import 'package:travel_buddy/ui/common/image_skeleton.dart';

class AppImage extends StatefulWidget {
  const AppImage({
    super.key,
    required this.image,
    this.fit = BoxFit.scaleDown,
    this.syncDuration,
    this.distractor = false,
    this.progress = false,
    this.skeleton = false,
    this.skeletonTone = SkeletonTone.dark,
    this.scale,
  });

  final ImageProvider? image;
  final BoxFit fit;
  final Duration? syncDuration;
  final bool distractor;
  final bool progress;

  /// Shows a shimmering placeholder (instead of a spinner) until the image
  /// is ready, then fades it out while the image fades in. An image that is
  /// already in memory shows straight away with no placeholder.
  final bool skeleton;
  final SkeletonTone skeletonTone;
  final double? scale;

  /// The provider [AppImage] actually loads for [image] at [scale]: decoded
  /// at screen width (times [scale]) so large photos don't decode at full
  /// size. Precaching this exact provider means the widget finds it in the
  /// memory cache.
  static ImageProvider sized(ImageProvider image, BuildContext context, double? scale) {
    // Disable resizing for web as it is currently single-threaded and causes the UI to lock up when resizing large images
    if (kIsWeb || scale == null) {
      return image; // TODO: Remove this when the web engine is updated to support non-blocking image resizing
    }
    final MediaQueryData mq = MediaQuery.of(context);
    final Size screenSize = mq.size * mq.devicePixelRatio * scale;
    return ResizeImage(image, width: screenSize.width.round());
  }

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  ImageProvider? _displayImage;
  ImageProvider? _sourceImage;

  // Skeleton state: [_loaded] flips when the image (or its error) arrives,
  // which starts the skeleton's fade-out; [_skeletonGone] removes it once
  // faded, so its shimmer stops running underneath the photo.
  ImageStream? _stream;
  ImageStreamListener? _listener;
  bool _loaded = false;
  bool _skeletonGone = false;

  Duration get _fadeDuration => $styles.times.fast;

  @override
  void didChangeDependencies() {
    _updateImage();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    _updateImage();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _stopWatching();
    super.dispose();
  }

  void _updateImage() {
    if (widget.image == _sourceImage) return;
    _sourceImage = widget.image;
    _displayImage = _capImageSize(_addRetry(_sourceImage));
    _watchLoad();
  }

  void _watchLoad() {
    _stopWatching();
    _loaded = false;
    _skeletonGone = false;
    final image = _displayImage;
    if (!widget.skeleton || image == null) return;
    // Resolves through the same image cache as ImageFade, so it doesn't
    // load anything twice. Fires synchronously when already in memory.
    _listener = ImageStreamListener(
      (_, sync) => _handleLoaded(sync),
      onError: (_, _) => _handleLoaded(false),
    );
    _stream = image.resolve(createLocalImageConfiguration(context))..addListener(_listener!);
  }

  void _stopWatching() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _stream = null;
    _listener = null;
  }

  void _handleLoaded(bool sync) {
    if (_loaded) return;
    _stopWatching();
    if (sync) {
      // Already in memory: skip the skeleton entirely.
      _loaded = _skeletonGone = true;
    } else if (mounted) {
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (!widget.skeleton || _skeletonGone || _displayImage == null) return image;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _loaded ? 0 : 1,
            duration: _fadeDuration,
            onEnd: () {
              if (_loaded && mounted) setState(() => _skeletonGone = true);
            },
            child: ImageSkeleton(tone: widget.skeletonTone),
          ),
        ),
        image,
      ],
    );
  }

  Widget _buildImage() {
    return ImageFade(
      image: _displayImage,
      fit: widget.fit,
      alignment: Alignment.center,
      duration: $styles.times.fast,
      syncDuration: widget.syncDuration ?? 0.ms,
      loadingBuilder: (_, value, _) {
        if (widget.skeleton || (!widget.distractor && !widget.progress)) return SizedBox();
        return Center(
          child: AppLoadingIndicator(value: widget.progress ? value : null),
        );
      },
      errorBuilder: (_, _) => Container(
        padding: EdgeInsets.all($styles.insets.xs),
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (_, constraints) {
            double size = min(constraints.biggest.width, constraints.biggest.height);
            if (size < 16) return SizedBox();
            return Icon(
              Icons.image_not_supported_outlined,
              color: $styles.colors.white.withValues(alpha: 0.1),
              size: min(size, $styles.insets.lg),
            );
          },
        ),
      ),
    );
  }

  ImageProvider? _addRetry(ImageProvider? image) {
    return image == null ? image : RetryImage(image);
  }

  ImageProvider? _capImageSize(ImageProvider? image) =>
      image == null ? null : AppImage.sized(image, context, widget.scale);
}
