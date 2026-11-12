import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/fade_color_transition.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/illustration_piece.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/paint_textures.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_builder.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_config.dart';

class KorcaIllustration extends StatelessWidget {
  KorcaIllustration({super.key, required this.config});
  final DestinationIllustrationConfig config;

  final fgColor = DestinationType.korca.fgColor;
  final bgColor = DestinationType.korca.bgColor;
  final assetPath = DestinationType.korca.assetPath;

  @override
  Widget build(BuildContext context) {
    return DestinationIllustrationBuilder(
      config: config,
      bgBuilder: _buildBg,
      mgBuilder: _buildMg,
      fgBuilder: _buildFg,
      destinationType: DestinationType.korca,
    );
  }

  List<Widget> _buildBg(BuildContext context, Animation<double> anim) {
    return [
      // Bg color
      FadeColorTransition(color: fgColor, animation: anim),
      // Noise texture
      Positioned.fill(
        child: IllustrationTexture(
          ImagePaths.roller2,
          flipY: true,
          opacity: anim.drive(Tween(begin: 0, end: .7)),
          color: bgColor,
          scale: config.shortMode ? 3 : 1.15,
        ),
      ),
      // Sun
      IllustrationPiece(
        fileName: 'sun.png',
        initialOffset: Offset(0, 50),
        enableHero: true,
        heightFactor: .3,
        minHeight: 140,
        offset: config.shortMode ? Offset(-100, context.heightPx * -.02) : Offset(-150, context.heightPx * -.34),
      ),
    ];
  }

  List<Widget> _buildMg(BuildContext context, Animation<double> anim) {
    return [
      LayoutBuilder(
        builder: (_, constraints) {
          const double minHeight = 230, heightFactor = .6, poolScale = 1;
          return Stack(
            children: [
              IllustrationPiece(
                fileName: 'korca.png',
                heightFactor: heightFactor,
                minHeight: minHeight,
                enableHero: true,
                zoomAmt: .05,
                fractionalOffset: Offset(0, config.shortMode ? .12 : -.15),
                top: config.shortMode
                    ? null
                    : (_) => FractionalTranslation(
                        translation: Offset(0, heightFactor),
                        child: IllustrationPiece(
                          fileName: 'pool.png',
                          heightFactor: heightFactor * poolScale,
                          minHeight: minHeight * poolScale,
                          zoomAmt: .05,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ];
  }

  List<Widget> _buildFg(BuildContext context, Animation<double> anim) {
    /// Let the mangos scale up as the width of the screen grows
    final mangoScale = max(context.widthPx - 400, 0) / 1000;
    return [
      IllustrationPiece(
        fileName: 'foreground-right.png',
        alignment: Alignment.bottomRight,
        initialOffset: Offset(20, 40),
        initialScale: .85,
        heightFactor: .5 + .4 * mangoScale,
        fractionalOffset: Offset(.3, 0),
        zoomAmt: .25,
      ),
      IllustrationPiece(
        fileName: 'foreground-left.png',
        alignment: Alignment.bottomLeft,
        initialScale: .9,
        initialOffset: Offset(-40, 60),
        heightFactor: .6 + .3 * mangoScale,
        fractionalOffset: Offset(-.3, 0),
        zoomAmt: .25,
        dynamicHzOffset: 0,
      ),
    ];
  }
}
