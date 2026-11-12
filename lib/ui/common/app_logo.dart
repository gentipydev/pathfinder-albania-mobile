import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pathfinder_albania/assets.dart';

/// The Pathfinder Albania mark: an eight-point compass star over two peaks,
/// with a trail cut through the mountains. Vector, so it stays crisp at any
/// size. Pass [color] for the single-colour silhouette.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 100, this.color});

  /// Width of the mark; the height follows its 848 x 711 aspect ratio.
  final double width;
  final Color? color;

  /// Wordmark lines shown beside or under the mark. Brand names, so they are
  /// the same in every locale.
  static const String wordmark = 'Pathfinder';
  static const String wordmarkRegion = 'ALBANIA';

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    SvgPaths.appLogo,
    width: width,
    height: width * 711 / 848,
    excludeFromSemantics: true,
    colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}
