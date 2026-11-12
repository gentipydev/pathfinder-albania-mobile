import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/fade_color_transition.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/illustration_piece.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/paint_textures.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_builder.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_config.dart';

class AlbanianAlpsIllustration extends StatelessWidget {
  AlbanianAlpsIllustration({super.key, required this.config});
  final DestinationIllustrationConfig config;
  final String assetPath = DestinationType.albanianAlps.assetPath;
  final fgColor = DestinationType.albanianAlps.fgColor;
  final bgColor = DestinationType.albanianAlps.bgColor;

  @override
  Widget build(BuildContext context) {
    return DestinationIllustrationBuilder(
      destinationType: DestinationType.albanianAlps,
      config: config,
      bgBuilder: _buildBg,
      mgBuilder: _buildMg,
      fgBuilder: _buildFg,
    );
  }

  List<Widget> _buildBg(BuildContext context, Animation<double> anim) {
    return [
      FadeColorTransition(animation: anim, color: fgColor),
      Positioned.fill(
        child: IllustrationTexture(
          ImagePaths.roller2,
          color: Color(0xFF797FD8),
          opacity: anim.drive(Tween(begin: 0, end: .75)),
          flipY: true,
          scale: config.shortMode ? 4 : 1.15,
        ),
      ),
      IllustrationPiece(
        fileName: 'moon.png',
        initialOffset: Offset(0, 50),
        enableHero: true,
        heightFactor: .15,
        minHeight: 100,
        offset: config.shortMode ? Offset(120, context.heightPx * -.05) : Offset(120, context.heightPx * -.35),
        zoomAmt: .05,
      ),
    ];
  }

  List<Widget> _buildMg(BuildContext context, Animation<double> anim) {
    return [
      IllustrationPiece(
        fileName: 'albanian_alps.png',
        enableHero: true,
        heightFactor: .5,
        minHeight: 300,
        zoomAmt: config.shortMode ? -.2 : -2,
        // The peaks end ~22% above the bottom of their canvas; in the short header push them down so
        // their base covers the sky/page edge instead of floating above it.
        fractionalOffset: Offset(config.shortMode ? .015 : 0, config.shortMode ? .25 : -.15),
      ),
    ];
  }

  List<Widget> _buildFg(BuildContext context, Animation<double> anim) {
    return [
      IllustrationPiece(
        fileName: 'foreground-back.png',
        alignment: Alignment.bottomCenter,
        initialOffset: Offset(20, 40),
        initialScale: .95,
        heightFactor: .55,
        fractionalOffset: Offset(.2, -.01),
        zoomAmt: .1,
        dynamicHzOffset: 150,
      ),
      IllustrationPiece(
        fileName: 'foreground-front.png',
        alignment: Alignment.bottomCenter,
        initialScale: .9,
        initialOffset: Offset(-40, 60),
        heightFactor: .55,
        fractionalOffset: Offset(-.09, 0.02),
        zoomAmt: .25,
        dynamicHzOffset: -150,
      ),
    ];
  }
}
