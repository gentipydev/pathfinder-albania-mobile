import 'package:flutter/material.dart';
import 'package:travel_buddy/assets.dart';

class TravelBuddyLogo extends StatelessWidget {
  const TravelBuddyLogo({super.key, this.width = 100});

  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    ImagePaths.appLogoPlain,
    excludeFromSemantics: true,
    fit: BoxFit.cover,
    width: width,
    filterQuality: FilterQuality.high,
  );
}
