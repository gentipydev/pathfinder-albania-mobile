import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer(
    this.colors,
    this.stops, {
    super.key,
    this.height,
    this.begin,
    this.end,
    this.blendMode,
    this.borderRadius,
  });
  final List<Color> colors;
  final List<double> stops;
  final double? height;
  final Alignment? begin;
  final Alignment? end;
  final BlendMode? blendMode;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.centerLeft,
          end: end ?? Alignment.centerRight,
          colors: colors,
          stops: stops,
        ),
        backgroundBlendMode: blendMode,
        borderRadius: borderRadius,
      ),
    ),
  );
}

class HzGradient extends GradientContainer {
  const HzGradient(
    super.colors,
    super.stops, {
    super.key,
    super.height,
    super.blendMode,
    super.borderRadius,
  });
}

class VtGradient extends GradientContainer {
  const VtGradient(
    super.colors,
    super.stops, {
    super.key,
    super.height,
    super.blendMode,
    super.borderRadius,
  }) : super(begin: Alignment.topCenter, end: Alignment.bottomCenter);
}
