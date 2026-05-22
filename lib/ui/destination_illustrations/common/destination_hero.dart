import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_illustration_config.dart';

/// Utility class that wraps a normal [Hero] widget, but respects DestinationIllustrationConfig.enableHero setting
class DestinationHero extends StatelessWidget {
  const DestinationHero(this.config, this.tag, {super.key, required this.child});
  final DestinationIllustrationConfig config;
  final Widget child;
  final String tag;

  @override
  Widget build(BuildContext context) => config.enableHero
      ? Hero(
          createRectTween: (begin, end) => RectTween(begin: begin!, end: end!),
          tag: tag,
          child: child,
        )
      : child;
}
