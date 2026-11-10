import 'package:flutter/material.dart';
import 'package:travel_buddy/assets.dart';

class TravelBuddyLogo extends StatelessWidget {
  const TravelBuddyLogo({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    ImagePaths.appLogoPlain,
    excludeFromSemantics: true,
    fit: BoxFit.cover,
    width: 100,
    filterQuality: FilterQuality.high,
  );
}
