import 'package:skeletonizer/skeletonizer.dart';
import 'package:travel_buddy/common_libs.dart' hide ShimmerEffect;

/// Which background a skeleton sits on: [dark] for photo areas (gallery
/// tiles, artifact cards), [light] for the off-white text panel of the
/// artifact carousel.
enum SkeletonTone { dark, light }

/// Shimmer colours for skeleton placeholders. Static when animations are
/// turned off.
PaintingEffect skeletonEffect(SkeletonTone tone) {
  final colors = $styles.colors;
  final (base, highlight) = switch (tone) {
    SkeletonTone.dark => (
      colors.greyStrong,
      Color.lerp(colors.greyStrong, colors.greyMedium, .22)!,
    ),
    SkeletonTone.light => (
      Color.lerp(colors.offWhite, colors.greyMedium, .28)!,
      Color.lerp(colors.offWhite, colors.greyMedium, .1)!,
    ),
  };
  if ($styles.disableAnimations) return SolidColorEffect(color: base);
  return ShimmerEffect(baseColor: base, highlightColor: highlight, duration: 1500.ms);
}

/// A shimmering box that fills its parent, shown while an image loads.
class ImageSkeleton extends StatelessWidget {
  const ImageSkeleton({super.key, this.tone = SkeletonTone.dark, this.borderRadius});
  final SkeletonTone tone;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      effect: skeletonEffect(tone),
      child: SizedBox.expand(child: Bone(borderRadius: borderRadius)),
    );
  }
}
