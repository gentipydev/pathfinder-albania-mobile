# Maps setup

Everything map-shaped is **Mapbox**, on both sides. The app renders
interactive maps with `mapbox_maps_flutter`; the backend uses Mapbox's web
APIs for the data and imagery it generates server-side. The two setups are
independent — each has its own token — but there is no second vendor.

| Surface | Provider | Credential |
| --- | --- | --- |
| Interactive maps in the iOS / Android app | Mapbox Maps SDK | one public `pk.…` token in `.env` |
| Chat + My Trips thumbnails (`trip.staticMapUrl`) | Mapbox Static Images API | backend token |
| Stop coordinates + address | Mapbox Search Box (forward) | backend token |
| Routed polylines in `trip.routes` | Mapbox Directions API | backend token |
| Flutter web build | *none* | — (see [Web](#web)) |

Stop **photos and ratings** have no provider row: Mapbox returns neither.
They come only from the backend's own curated `places` table (photos live in
Supabase Storage), so most stops have none and the app renders
`PlacePhotoPlaceholder` instead.

---

## 1. Mobile: the Mapbox token

One token covers iOS and Android. There is no per-platform key, no manifest
placeholder, no `Info.plist` entry, and no native initialisation — the token
is handed to the SDK from Dart in `lib/logic/app_logic.dart`:

```dart
final mapboxToken = Env.mapboxAccessToken;
if (mapboxToken.isNotEmpty) MapboxOptions.setAccessToken(mapboxToken);
```

### Setup

1. Create a Mapbox account and open
   [Account → Tokens](https://console.mapbox.com/account/access-tokens/).
2. Create a new **public** token (starts with `pk.`) with exactly three
   scopes — `STYLES:TILES`, `STYLES:READ`, `FONTS:READ`. Uncheck
   `DATASETS:READ` (Datasets API, unused) and `VISION:READ` (Vision SDK,
   unused). Leave **every** Secret scope unchecked: ticking one produces an
   `sk.` token, which must never ship in a client binary.
3. Add it to your `.env` (gitignored; `.env.example` is the template):
   ```
   MAPBOX_ACCESS_TOKEN=pk.eyJ1...
   ```
4. `flutter run -d <device>`.

### Restricting the token

A public token is *designed* to ship inside a client binary — it cannot be
kept secret and Mapbox does not treat it as one. Protect it with the controls
that actually apply:

- **Minimise scopes** — the three above and nothing more. This is the only
  meaningful restriction available to a mobile token.
- Keep it a **public** token. Never put a secret (`sk.`) token in the app —
  those can create and delete resources on the account.
- Set **billing alerts** on the Mapbox account. Map loads are metered, and a
  buggy client loop is the realistic cost risk here.

**Do not set URL restrictions.** Mapbox enforces them via the HTTP `Referer`
header and explicitly does not support them for "requests from mobile
applications built with the Mapbox Maps or Navigation SDKs". They would give
this app no protection, and a request with a blank referer is answered with
`403: forbidden` — so the only thing they can do here is break the map. They
become relevant only if maps ever return to the web build.

If a token leaks in a way you care about, delete it in the Mapbox console and
issue a new one — there is nothing to update beyond `.env` and CI secrets.

### No secret download token needed

Mapbox's own docs describe an `sk.`-scoped *download* token for pulling the
native SDKs. `mapbox_maps_flutter` 2.29.0 does not need one:

- **Android** resolves `com.mapbox.maps:android-ndk27:11.29.0` from
  `https://api.mapbox.com/downloads/v2/releases/maven`, which is
  unauthenticated. (`SDK_REGISTRY_TOKEN` guards only the *snapshots* repo,
  which release builds never touch.)
- **iOS** resolves `MapboxMaps 11.29.0` from public CocoaPods. No `~/.netrc`
  entry required.

So there is nothing to configure in `gradle.properties`, `settings.gradle`,
or `~/.netrc`.

### Platform requirements

Already satisfied by this project; listed so a future bump doesn't surprise
anyone.

- iOS **14.0+** — `ios/Podfile` pins `platform :ios, '14.0'`.
- Android **SDK 21+** — `minSdk = flutter.minSdkVersion`.
- Flutter 3.22.3 / Dart 3.4.4 or newer.

---

## 2. Map styling

The base map is **Mapbox Standard** (`MapboxStyles.STANDARD`), with the
satellite toggle switching to **Standard Satellite**. Both are configured in
`lib/styles/map_style.dart` via `setStyleImportConfigProperties`, which turns
off POI, transit and road labels so the day-colored trip markers are the only
story on the map.

The land and water palette is Mapbox's, **not** AppColors. Mapbox Standard's
config properties can hide label categories but cannot recolour land or
water, so the warm Mediterranean basemap the app used to have is gone.
Matching the brand palette would mean authoring a custom style
in Mapbox Studio and referencing it by `styleUri` — a deliberate follow-up,
not an oversight.

### Known visual mismatch

`trip.staticMapUrl` thumbnails Hero-morph into this map, and the two still
look slightly different mid-flight. Both are Mapbox now, but the Static
Images API renders **classic styles only** — Mapbox Standard is GL-only and
cannot be requested from it. The backend therefore uses `light-v11`
(`travel-buddy-backend/app/integrations/mapbox_static.py`) while this screen
uses Standard. The gap is a Mapbox constraint, not an oversight; it is
documented at both ends (`lib/styles/map_style.dart` and
`itinerary_map_thumbnail.dart`). Don't restyle one side alone.

### Attribution

The Mapbox logo and the attribution ⓘ button are **required** by the Mapbox
terms of service and are enabled by default. Reposition them if they collide
with app chrome (`map.logo.updateSettings` / `map.attribution.updateSettings`),
but never hide them.

---

## 3. Backend: the Mapbox token

The backend has its own token, set as `MAPBOX_ACCESS_TOKEN` in
`travel-buddy-backend/.env` (or the host's environment). A public `pk.…`
token is what you want: it is **embedded in the static-map URL persisted on
every trip** and shipped to clients, so it is not a secret. Restrict it by
URL in the Mapbox account rather than trying to hide it.

Two kill switches exist for cost control — `MAPBOX_GEOCODING_ENABLED` and
`MAPBOX_DIRECTIONS_ENABLED`. Setting either to `false` (or leaving the token
empty) makes that service short-circuit; trips still save, just without
coordinates or road-following polylines.

> **Licensing:** Mapbox only permits *storing* geocoding results under
> `permanent=true`, which has to be enabled on the account. The backend
> caches results for 90 days and persists coordinates on `trip_stops`
> regardless, so set `MAPBOX_PERMANENT_GEOCODING=true` before any real
> launch.

> **Old Google keys:** the app used Google Maps before this migration, and
> three client keys reached this repo's git history —
> `AIzaSyDe…xbUFY4` (redacted), the value that lived in
> `web/index.html`, and anything left in a developer's
> `android/local.properties`. The Google Cloud project they belonged to no
> longer exists, which makes them inert — but they are still in history, so
> treat them as burned and never reuse them.

---

## 4. Web

`mapbox_maps_flutter` 2.x supports iOS and Android only (web support is in
the 3.0.0-alpha line). The Flutter web build therefore ships **no** map SDK:
`TripMapScreen`, `FullscreenMapsViewer` and the editorial map thumbnail all
check `kIsWeb || PlatformInfo.isDesktop` and render a fallback instead of a
platform view. The web build still compiles and deploys; it just has no maps.
The public web experience lives in the separate Next.js app.

---

## 5. Verification

Run the app on a device or simulator with a valid token. Save a trip in chat,
then tap the inline map thumbnail.

- **Tiles render, markers and the route line appear**: setup correct.
- **Map is blank / black**: `MAPBOX_ACCESS_TOKEN` is missing or invalid. The
  app is deliberately fail-soft here (`Env.mapboxAccessToken` is not checked
  in `Env.assertValid`), so nothing crashes — check the device log for a
  Mapbox `401`/`403`.
- **Markers appear but the route line never draws**: either the trip has no
  routes (see below), or the GeoJSON source lost `lineMetrics: true` —
  `line-trim-offset` is silently ignored without it.
- **Markers disappear when stops sit close together**: the annotation
  manager lost `setIconAllowOverlap(true)` / `setIconIgnorePlacement(true)`.
  Mapbox hides colliding symbols by default.
- **Markers and route vanish after toggling satellite**: content is being
  installed from `onMapCreated` instead of `onStyleLoadedListener`. Loading a
  new `styleUri` drops every custom source, layer and annotation, so all of
  it must be re-installed on each style load.
- **Everything is in the Indian Ocean**: a `Position(lng, lat)` was built
  latitude-first. `test/utils/polyline_decoder_test.dart` guards the decoder;
  check any hand-written `Position(...)` call.
- **The route line renders but no markers**: `trip.routes` is populated and
  the icons are not — check `_iconCache` keying in `trip_map_screen.dart`.

Provider-independent failures, worth checking before blaming the SDK:

- **Markers render but the route does not**: a leg is silently dropped when
  its `encoded_polyline` decodes to an empty list. Check the trip's
  `trip.routes` array — if empty, the backend planner didn't compute routes
  (older trip, walking-only days, or routing quota exhausted). The map still
  shows markers and straight-line fallbacks between them.
- **`flutter run` works but maps don't render after a `pod install`**: Xcode
  caches build settings aggressively. `flutter clean`, then rebuild.
