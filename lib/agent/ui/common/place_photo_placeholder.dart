import 'package:pathfinder_albania/common_libs.dart';

/// Stands in for a place photo we don't have.
///
/// Most stops don't have one: the backend's geocoder returns no imagery, so
/// only stops matching a row in the curated places table carry a photo. This
/// is the shared "no photo" look across every surface that shows one — the
/// map sheet's photo stack and the trip-detail stop thumbnails — so a stop
/// looks the same wherever it appears.
///
/// [icon] defaults to a generic image glyph; callers that know what kind of
/// stop this is (a restaurant, a sight) should pass that icon instead — it
/// carries more meaning than "picture missing". [iconSize] exists because the
/// thumbnails are much smaller than the hero, where a 36 dp glyph would swamp
/// an 80 dp tile.
///
/// To use a real photographic default instead, replace the [ColoredBox] body
/// with an `Image.asset(...)` here — every caller picks it up.
class PlacePhotoPlaceholder extends StatelessWidget {
  const PlacePhotoPlaceholder({
    super.key,
    this.icon = Icons.image_outlined,
    this.iconSize = 36,
  });

  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: $styles.colors.greyMedium.withValues(alpha: 0.25),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: $styles.colors.greyMedium,
        ),
      ),
    );
  }
}
