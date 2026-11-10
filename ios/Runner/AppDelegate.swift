import UIKit
import Flutter

// Mapbox needs no native key setup: the public access token is supplied from
// Dart via MapboxOptions.setAccessToken in lib/logic/app_logic.dart.
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}