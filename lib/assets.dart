import 'package:pathfinder_albania/common_libs.dart';

/// Loads bitmap assets into memory that may be required later
class AppBitmaps {
  /// Raw PNG bytes for the generic location pin. Mapbox annotations take the
  /// encoded image directly (`PointAnnotationOptions.image`) and scale it via
  /// `iconSize`, so no device-pixel-ratio baking is needed here.
  static late final Uint8List mapMarker;

  static Future<void> init() async {
    final data = await rootBundle.load('${ImagePaths.common}/location-pin.png');
    mapMarker = data.buffer.asUint8List();
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

  static String roller1 = '$textures/roller-1-white.gif';
  static String roller2 = '$textures/roller-2-white.gif';

}

/// Consolidates SCG image paths in their own class, hints to the UI to use an SvgPicture to render
class SvgPaths {
  static String compassFull = '${ImagePaths.common}/compass-full.svg';
  static String compassSimple = '${ImagePaths.common}/compass-simple.svg';
  static String appLogo = '${ImagePaths.common}/app-logo.svg';
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

  /// The four photos bundled with the app; the gallery falls back to these
  /// when the content snapshot lists none for the destination.
  List<String> get bundledPhotos => [photo1, photo2, photo3, photo4];
  String get flattened => '$assetPath/flattened.jpg';
}
