import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/common/photo_cache.dart';
import 'package:pathfinder_albania/ui/common/image_skeleton.dart';

export 'package:pathfinder_albania/logic/common/photo_cache.dart' show photoImageProvider, prefetchPhotoUrls;

/// Renders a backend photo (public Supabase Storage URL) or a bundled asset
/// path, with a shimmering skeleton until it arrives. `AppImage` retries
/// failed loads, so network blips don't leave a blank frame.
///
/// With [placeholderUrl] (a small copy of the same photo, usually already
/// cached from a grid or carousel), that copy shows at once and the full
/// image fades in over it when ready.
class RemotePhoto extends StatelessWidget {
  const RemotePhoto(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.placeholderUrl,
    this.scale = 1,
    this.skeletonTone = SkeletonTone.dark,
  });
  final String url;
  final BoxFit fit;
  final String? placeholderUrl;
  final double scale;
  final SkeletonTone skeletonTone;

  @override
  Widget build(BuildContext context) {
    final small = placeholderUrl;
    final hasPlaceholder = small != null && small.isNotEmpty && small != url;
    final full = AppImage(
      image: url.isEmpty ? null : photoImageProvider(url),
      fit: fit,
      scale: scale,
      skeleton: !hasPlaceholder,
      skeletonTone: skeletonTone,
    );
    if (!hasPlaceholder) return full;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Scale 1 matches the grid/carousel, so this is usually a memory hit.
        AppImage(image: photoImageProvider(small), fit: fit, scale: 1, skeleton: true, skeletonTone: skeletonTone),
        full,
      ],
    );
  }
}
