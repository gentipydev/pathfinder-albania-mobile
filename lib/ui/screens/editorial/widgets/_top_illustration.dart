part of '../editorial_screen.dart';

class _TopIllustration extends StatelessWidget {
  const _TopIllustration(this.type, {this.fgOffset = Offset.zero});
  final DestinationType type;
  final Offset fgOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DestinationIllustration(
          type,
          config: DestinationIllustrationConfig.bg(enableAnims: false, shortMode: true),
        ),
        Transform.translate(
          // Small bump down to make sure we cover the edge between the editorial page and the sky.
          offset: fgOffset + Offset(0, 10),
          child: DestinationIllustration(
            type,
            config: DestinationIllustrationConfig.mg(enableAnims: false, shortMode: true),
          ),
        ),
      ],
    );
  }
}
