// ignore_for_file: constant_identifier_names
import 'package:pathfinder_albania/common_libs.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 22, this.color});
  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    String i = icon.name.toLowerCase().replaceAll('_', '-');
    String path = 'assets/images/_common/icons/icon-$i.png';
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          path,
          width: size,
          height: size,
          color: color ?? $styles.colors.offWhite,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

enum AppIcons {
  next_large,
  north,
  prev,
  timeline,
}
