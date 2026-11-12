# Pathfinder Albania

Pathfinder Albania is a guide to the eight destinations of Albania — Apollonia, Kruja, Gjirokastër, Butrint, Theth, Korça, Berat, and the Albanian Alps. Explore each site through illustration, history, photography, artifacts, a hidden-collectibles hunt and the Albanian Story Timeline.

The Flutter app is a rebrand and reimagining of an upstream open-source Flutter template (see [LICENSE](LICENSE)), reworked around Albanian destinations.

## Installation

If you're new to Flutter, follow the [Flutter setup instructions](https://flutter.dev/docs/get-started/install) first.

Once Flutter is set up, use the latest `stable` channel:

```
flutter channel stable
flutter upgrade
```

Copy `.env.example` to `.env` (see [Configuration](#configuration)), then run the app on a device or simulator:

```
flutter run -d ios
flutter run -d android
```

### Configuration

`.env` is a bundled asset read at startup, so changing it needs a full `flutter run`, not a hot restart. It has a single key:

| Key | What |
|---|---|
| `MAPBOX_ACCESS_TOKEN` | Public `pk.…` token for the two destination maps. Optional: without it the maps render blank. Setup and scope advice in [docs/maps-setup.md](docs/maps-setup.md). |

There is no backend URL and no sign-in to configure.

### Bundled content

The artifact catalog (highlights and collectibles) and the destination photo galleries ship inside the app, under `assets/backend_snapshot/`. That folder is a temporary snapshot of the content the previous backend served; [its README](assets/backend_snapshot/README.md) documents the layout, the manifests the app reads, and where the photo credits live. The loaders are `lib/features/artifacts/bloc/artifacts_bloc.dart` and `lib/logic/destination_photos_logic.dart`.

### Web (WASM)

The app supports Flutter Web's WebAssembly target. To run it locally:

```
flutter run -d chrome --wasm
```

Maps are iOS/Android only; the web build renders a fallback in their place.

### Impeller Rendering

The app uses the [Impeller renderer](https://docs.flutter.dev/perf/impeller) by default on iOS for smoother animations.

## License

This application is released under the [MIT license](LICENSE), inherited from the upstream MIT-licensed Flutter template. The Pathfinder Albania rebrand is built on top of that codebase.

[![license](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Credits

- Built on an upstream open-source Flutter template (see [LICENSE](LICENSE)) that provides the original UI, animation, and architecture foundation.
- The Albanian content, illustrations and curation are part of the Pathfinder Albania project.
- Destination and artifact photographs come from Wikimedia Commons under CC BY / CC BY-SA; per-picture credits are kept in `assets/backend_snapshot/credits/`.
