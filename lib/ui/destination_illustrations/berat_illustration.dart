import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/fade_color_transition.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/illustration_piece.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/paint_textures.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_builder.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_config.dart';

class BeratIllustration extends StatelessWidget {
  BeratIllustration({super.key, required this.config});
  final DestinationIllustrationConfig config;
  final String assetPath = DestinationType.berat.assetPath;
  final fgColor = DestinationType.berat.fgColor;

  @override
  Widget build(BuildContext context) {
    return DestinationIllustrationBuilder(
      config: config,
      bgBuilder: _buildBg,
      mgBuilder: _buildMg,
      fgBuilder: _buildFg,
      destinationType: DestinationType.berat,
    );
  }

  List<Widget> _buildBg(BuildContext context, Animation<double> anim) {
    return [
      FadeColorTransition(animation: anim, color: fgColor),
      Positioned.fill(
        child: IllustrationTexture(
          ImagePaths.roller1,
          color: Color(0xffFAE5C8),
          flipX: false,
          opacity: anim.drive(Tween(begin: 0, end: .8)),
          scale: config.shortMode ? 3.5 : 1.15,
        ),
      ),
      IllustrationPiece(
        fileName: 'sun.png',
        initialOffset: Offset(0, 50),
        enableHero: true,
        heightFactor: .25,
        minHeight: 120,
        fractionalOffset: Offset(.7, config.shortMode ? -.5 : -1.35),
      ),
    ];
  }

  List<Widget> _buildMg(BuildContext context, Animation<double> anim) {
    return [
      ClipRect(
        clipBehavior: config.shortMode ? Clip.hardEdge : Clip.none,
        child: IllustrationPiece(
          fileName: 'berat.png',
          enableHero: true,
          heightFactor: 1,
          alignment: Alignment.bottomCenter,
          fractionalOffset: Offset(0, config.shortMode ? .5 : .1),
          zoomAmt: .7,
        ),
      ),
      //
    ];
  }

  List<Widget> _buildFg(BuildContext context, Animation<double> anim) {
    return [
      IllustrationPiece(
        fileName: 'foreground-left.png',
        alignment: Alignment.bottomCenter,
        initialScale: .95,
        initialOffset: Offset(-140, 60),
        heightFactor: .65,
        fractionalOffset: Offset(-.25, .05),
        zoomAmt: .15,
        dynamicHzOffset: -100,
      ),
      IllustrationPiece(
        fileName: 'foreground-right.png',
        alignment: Alignment.bottomCenter,
        initialOffset: Offset(120, 40),
        initialScale: .9,
        heightFactor: .55,
        fractionalOffset: Offset(.35, .2),
        zoomAmt: .1,
        dynamicHzOffset: 100,
      ),
    ];
  }
}
