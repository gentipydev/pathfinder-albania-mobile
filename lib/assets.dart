import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/common/platform_info.dart';

/// Loads bitmap assets into memory that may be required later
class AppBitmaps {
  static late final BitmapDescriptor mapMarker;

  static Future<void> init() async {
    mapMarker = await BitmapDescriptor.asset(
      ImageConfiguration(devicePixelRatio: PlatformInfo.pixelRatio),
      '${ImagePaths.common}/location-pin.png',
    );
  }
}

/// Consolidates raster image paths used across the app
class ImagePaths {
  static String root = 'assets/images';
  static String common = 'assets/images/_common';
  static String cloud = '$common/cloud-white.png';

  static String collectibles = '$root/collectibles';
  static String particle = '$common/particle-21x23.png';
  static String ribbonEnd = '$common/ribbon-end.png';

  static String textures = '$common/texture';
  static String icons = '$common/icons';

  static String roller1 = '$textures/roller-1-white.gif';
  static String roller2 = '$textures/roller-2-white.gif';

  static String appLogo = '$common/app-logo.png';
  static String appLogoPlain = '$common/app-logo-plain.png';
}

/// Consolidates SCG image paths in their own class, hints to the UI to use an SvgPicture to render
class SvgPaths {
  static String compassFull = '${ImagePaths.common}/compass-full.svg';
  static String compassSimple = '${ImagePaths.common}/compass-simple.svg';
}

/// For destination specific assets, add an extension to [DestinationType] for easy lookup
extension DestinationAssetExtensions on DestinationType {
  String get assetPath {
    return switch (this) {
      DestinationType.albanianAlps => '${ImagePaths.root}/albanian_alps',
      DestinationType.apollonia => '${ImagePaths.root}/apollonia',
      DestinationType.kruja => '${ImagePaths.root}/kruja',
      DestinationType.gjirokaster => '${ImagePaths.root}/gjirokaster',
      DestinationType.butrint => '${ImagePaths.root}/butrint',
      DestinationType.theth => '${ImagePaths.root}/theth',
      DestinationType.korca => '${ImagePaths.root}/korca',
      DestinationType.berat => '${ImagePaths.root}/berat',
    };
  }

  String get homeBtn => '$assetPath/destination-button.png';
  String get photo1 => '$assetPath/photo-1.jpg';
  String get photo2 => '$assetPath/photo-2.jpg';
  String get photo3 => '$assetPath/photo-3.jpg';
  String get photo4 => '$assetPath/photo-4.jpg';
  String get flattened => '$assetPath/flattened.jpg';
}
