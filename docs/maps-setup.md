# Maps setup

The app has two map surfaces, both rendered with `mapbox_maps_flutter` on iOS and Android:
the small map thumbnail on each destination's editorial page (Mapbox Standard) and the fullscreen
destination map behind it (Mapbox Standard Satellite), each with a single pin. There is no other
map vendor and no server-side map work.

| Surface | Provider | Credential |
| --- | --- | --- |
| Editorial thumbnail + fullscreen destination map (iOS / Android) | Mapbox Maps SDK | one public `pk.…` token in `.env` |
| Flutter web build | *none* | — (see [Web](#web)) |

---

## 1. The Mapbox token

One token covers iOS and Android. There is no per-platform key, no manifest placeholder, no
`Info.plist` entry, and no native initialisation — the token is handed to the SDK from Dart in
`lib/logic/app_logic.dart`:

```dart
final mapboxToken = Env.mapboxAccessToken;
if (mapboxToken.isNotEmpty) MapboxOptions.setAccessToken(mapboxToken);
```

### Setup

1. Create a Mapbox account and open
   [Account → Tokens](https://console.mapbox.com/account/access-tokens/).
2. Create a new **public** token (starts with `pk.`) with exactly three scopes — `STYLES:TILES`,
   `STYLES:READ`, `FONTS:READ`. Uncheck `DATASETS:READ` and `VISION:READ` (unused). Leave **every**
   Secret scope unchecked: ticking one produces an `sk.` token, which must never ship in a client
   binary.
3. Add it to your `.env` (gitignored; `.env.example` is the template):
   ```
   MAPBOX_ACCESS_TOKEN=pk.eyJ1...
   ```
4. `flutter run -d <device>` (a full run, not a hot restart: `.env` is a bundled asset).

### Restricting the token

A public token is *designed* to ship inside a client binary — it cannot be kept secret and Mapbox
does not treat it as one. Protect it with the controls that actually apply:

- **Minimise scopes** — the three above and nothing more. This is the only meaningful
  restriction available to a mobile token.
- Keep it a **public** token. Never put a secret (`sk.`) token in the app — those can create and
  delete resources on the account.
- Set **billing alerts** on the Mapbox account. Map loads are metered, and a buggy client loop is
  the realistic cost risk here.

**Do not set URL restrictions.** Mapbox enforces them via the HTTP `Referer` header and explicitly
does not support them for requests from the Mapbox Maps SDKs. A request with a blank referer is
answered with `403: forbidden`, so the only thing they can do here is break the map.

If a token leaks in a way you care about, delete it in the Mapbox console and issue a new one —
there is nothing to update beyond `.env` and CI secrets.

### No secret download token needed

`mapbox_maps_flutter` 2.29.0 does not need an `sk.` download token: Android resolves the SDK from
Mapbox's unauthenticated release Maven repository and iOS from public CocoaPods. There is nothing to
configure in `gradle.properties`, `settings.gradle`, or `~/.netrc`.

### Platform requirements

- iOS **15.0+** — `ios/Podfile` pins `platform :ios, '15.0'`.
- Android **SDK 21+** — `minSdk = flutter.minSdkVersion`.

---

## 2. Map styling

The styles are the two constants in `lib/styles/map_style.dart`: **Mapbox Standard** for the
editorial thumbnail and **Standard Satellite** for the fullscreen viewer. The pin is the bundled
`location-pin.png`, installed through `buildPinAnnotationOptions` in `lib/ui/common/map_marker.dart`
once the style has loaded (annotations can only be created against a loaded style).

The land and water palette is Mapbox's, **not** AppColors. Matching the brand palette would mean
authoring a custom style in Mapbox Studio and referencing it by `styleUri` — a deliberate
follow-up, not an oversight.

### Attribution

The Mapbox logo and the attribution ⓘ button are **required** by the Mapbox terms of service and are
enabled by default. Reposition them if they collide with app chrome
(`map.logo.updateSettings` / `map.attribution.updateSettings`), but never hide them.

---

## 3. Web

`mapbox_maps_flutter` 2.x supports iOS and Android only. The Flutter web build therefore ships
**no** map SDK: `FullscreenMapsViewer` and the editorial map thumbnail check
`kIsWeb || PlatformInfo.isDesktop` and render a fallback instead of a platform view. The web build
still compiles and deploys; it just has no maps.

---

## 4. Verification

Run the app on a device or simulator with a valid token, open any destination, scroll the editorial
page to the map thumbnail and tap it.

- **Tiles render and the pin appears**: setup correct.
- **Map is blank / black**: `MAPBOX_ACCESS_TOKEN` is missing or invalid. The app is deliberately
  fail-soft here, so nothing crashes — check the device log for a Mapbox `401`/`403`.
- **Tiles render but no pin**: the pin is being installed from `onMapCreated` instead of
  `onStyleLoadedListener`; loading a style drops every annotation, so it must be created after the
  style loads.
- **The pin is in the Indian Ocean**: a `Position(lng, lat)` was built latitude-first. Check the
  destination's `lat`/`lng` in `lib/logic/data/destinations_data/`.
- **`flutter run` works but maps don't render after a `pod install`**: Xcode caches build settings
  aggressively. `flutter clean`, then rebuild.
