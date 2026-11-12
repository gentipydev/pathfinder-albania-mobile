import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/fade_color_transition.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/illustration_piece.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/paint_textures.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_builder.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_config.dart';

class ButrintIllustration extends StatelessWidget {
  ButrintIllustration({super.key, required this.config});
  final DestinationIllustrationConfig config;
  final assetPath = DestinationType.butrint.assetPath;
  final fgColor = DestinationType.butrint.fgColor;
  @override
  Widget build(BuildContext context) {
    return DestinationIllustrationBuilder(
      config: config,
      bgBuilder: _buildBg,
      mgBuilder: _buildMg,
      fgBuilder: _buildFg,
      destinationType: DestinationType.butrint,
    );
  }

  List<Widget> _buildBg(BuildContext context, Animation<double> anim) {
    return [
      FadeColorTransition(animation: anim, color: fgColor),
      Positioned.fill(
        child: IllustrationTexture(
          ImagePaths.roller2,
          color: Color(0xffDC762A),
          opacity: anim.drive(Tween(begin: 0, end: .5)),
          flipY: true,
          scale: config.shortMode ? 4 : 1.15,
        ),
      ),
      IllustrationPiece(
        fileName: 'sun.png',
        initialOffset: Offset(0, 50),
        enableHero: true,
        heightFactor: .4,
        minHeight: 200,
        fractionalOffset: Offset(.55, config.shortMode ? .2 : -.35),
      ),
    ];
  }

  List<Widget> _buildMg(BuildContext context, Animation<double> anim) {
    // We want to size to the shortest side
    return [
      Transform.translate(
        offset: Offset(0, config.shortMode ? 70 : -30),
        child: IllustrationPiece(
          fileName: 'butrint.png',
          heightFactor: .4,
          minHeight: 180,
          zoomAmt: -.1,
          enableHero: true,
        ),
      ),
    ];
  }

  List<Widget> _buildFg(BuildContext context, Animation<double> anim) {
    return [
      IllustrationPiece(
        fileName: 'foreground-right.png',
        alignment: Alignment.bottomCenter,
        initialOffset: Offset(20, 40),
        initialScale: .95,
        heightFactor: .4,
        fractionalOffset: Offset(.5, -.1),
        zoomAmt: .1,
        dynamicHzOffset: 250,
      ),
      IllustrationPiece(
        fileName: 'foreground-left.png',
        alignment: Alignment.bottomCenter,
        initialScale: .9,
        initialOffset: Offset(-40, 60),
        heightFactor: .65,
        fractionalOffset: Offset(-.4, .2),
        zoomAmt: .25,
        dynamicHzOffset: -250,
      ),
      IllustrationPiece(
        fileName: 'top-left.png',
        alignment: Alignment.topLeft,
        initialScale: .9,
        initialOffset: Offset(-40, 60),
        heightFactor: .65,
        fractionalOffset: Offset(-.4, -.4),
        zoomAmt: .05,
        dynamicHzOffset: 100,
      ),
      IllustrationPiece(
        fileName: 'top-right.png',
        alignment: Alignment.topRight,
        initialOffset: Offset(20, 40),
        initialScale: .95,
        heightFactor: .65,
        fractionalOffset: Offset(.35, -.4),
        zoomAmt: .05,
        dynamicHzOffset: -100,
      ),
    ];
  }
}
