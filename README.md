# Travel Buddy

Travel Buddy is an AI-powered guide to the eight destinations of Albania — Apollonia, Kruja, Gjirokastër, Butrint, Theth, Korça, Berat, and the Albanian Alps. Explore each site through history, photography, artifacts, and a built-in conversational travel assistant tailored to Albania.

The Flutter app is a rebrand and reimagining of an upstream open-source Flutter template (see [LICENSE](LICENSE)), reworked around Albanian destinations and paired with a custom `travel-buddy-backend`.

## Installation

If you're new to Flutter, follow the [Flutter setup instructions](https://flutter.dev/docs/get-started/install) first.

Once Flutter is set up, use the latest `stable` channel:

```
flutter channel stable
flutter upgrade
```

Then run the app on a device or simulator:

```
flutter run -d ios
flutter run -d android
```

### Web (WASM)

The app supports Flutter Web's WebAssembly target. To run it locally:

```
flutter run -d chrome --wasm
```

### Impeller Rendering

The app uses the [Impeller renderer](https://docs.flutter.dev/perf/impeller) by default on iOS for smoother animations.

## License

This application is released under the [MIT license](LICENSE), inherited from the upstream MIT-licensed Flutter template. The Travel Buddy rebrand is built on top of that codebase.

[![license](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Credits

- Built on an upstream open-source Flutter template (see [LICENSE](LICENSE)) that provides the original UI, animation, and architecture foundation.
- Albanian content, AI travel-assistant integration, and the `travel-buddy-backend` service are part of the Travel Buddy project.
