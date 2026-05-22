import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/ui/common/fade_color_transition.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/illustration_piece.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/paint_textures.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_illustration_builder.dart';
import 'package:travel_buddy/ui/destination_illustrations/common/destination_illustration_config.dart';

class KrujaIllustration extends StatelessWidget {
  KrujaIllustration({super.key, required this.config});
  final DestinationIllustrationConfig config;
  final String assetPath = DestinationType.kruja.assetPath;
  final fgColor = DestinationType.kruja.fgColor;
  final bgColor = DestinationType.kruja.bgColor;

  @override
  Widget build(BuildContext context) {
    return DestinationIllustrationBuilder(
      config: config,
      bgBuilder: _buildBg,
      mgBuilder: _buildMg,
      fgBuilder: _buildFg,
      destinationType: DestinationType.kruja,
    );
  }

  List<Widget> _buildBg(BuildContext context, Animation<double> anim) {
    return [
      FadeColorTransition(animation: anim, color: fgColor),
      Positioned.fill(
        child: IllustrationTexture(
          ImagePaths.roller1,
          color: DestinationType.kruja.bgColor,
          flipX: true,
          opacity: anim.drive(Tween(begin: 0, end: 1)),
          scale: config.shortMode ? 4 : 1.15,
        ),
      ),
      IllustrationPiece(
        fileName: 'moon.png',
        initialOffset: Offset(0, -150),
        heightFactor: .15,
        minHeight: 50,
        alignment: Alignment.topCenter,
        fractionalOffset: Offset(-.7, 0),
      ),
    ];
  }

  List<Widget> _buildMg(BuildContext context, Animation<double> anim) => [
    FractionallySizedBox(
      heightFactor: config.shortMode ? 1 : .8,
      alignment: Alignment.bottomCenter,
      child: IllustrationPiece(
        fileName: 'kruja.png',
        heightFactor: .65,
        minHeight: 500,
        zoomAmt: config.shortMode ? -0.1 : -1,
        enableHero: true,
        fractionalOffset: Offset(0, config.shortMode ? .025 : 0),
      ),
    ),
  ];

  List<Widget> _buildFg(BuildContext context, Animation<double> anim) {
    return [
      IllustrationPiece(
        fileName: 'foreground-left.png',
        alignment: Alignment.bottomCenter,
        initialOffset: Offset(-80, 0),
        heightFactor: 1,
        fractionalOffset: Offset(-.6, 0),
        zoomAmt: .03,
        dynamicHzOffset: -130,
        bottom: (_) {
          /// To cover everything behind this piece with a solid color, we scale up a container
          /// and then offset it in negative space
          const double scaleX = 5;
          return FractionalTranslation(
            translation: Offset(-1 - scaleX / 2, 0),
            child: Transform.scale(
              scaleX: 5,
              child: Container(color: DestinationType.kruja.fgColor.withValues(alpha: anim.value)),
            ),
          );
        },
      ),
      IllustrationPiece(
        fileName: 'foreground-right.png',
        alignment: Alignment.bottomCenter,
        initialOffset: Offset(80, 00),
        heightFactor: 1,
        fractionalOffset: Offset(.55, 0),
        zoomAmt: .12,
        dynamicHzOffset: 130,
        bottom: (_) {
          /// To cover everything behind this piece with a solid color, we scale up a container and then offset it in negative space
          const double scaleX = 5;
          return FractionalTranslation(
            translation: Offset(1 + scaleX / 2, 0),
            child: Transform.scale(
              scaleX: 5,
              child: Container(color: DestinationType.kruja.fgColor.withValues(alpha: anim.value)),
            ),
          );
        },
      ),
    ];
  }
}
