# Google Maps setup

This app uses Google Maps in three places:

- **Backend** uses the Maps Static API (PR 1) to render thumbnail PNGs that
  appear inline in chat after a trip is saved. It also uses Places API and
  Directions API to enrich saved stops with photos/ratings/coords and to
  compute encoded polylines for turn-by-turn paths.
- **Android** mobile uses the Maps SDK for Android to render the interactive
  full-screen map (PR 3) when a user taps a saved trip's thumbnail.
- **iOS** mobile uses the Maps SDK for iOS for the same screen.

We provision **three** API keys with different restrictions, plus one URL
signing secret. Never share a single key across surfaces — Android and iOS
keys must be locked to their respective bundles, and the server key must be
locked to the deploy IP (or quota-restricted) so a leaked client key can't
be turned into a server-side cost-attack.

---

## 1. Google Cloud Console

In the project's Cloud Console (`console.cloud.google.com`):

1. Create or select the project; enable billing (free tier covers MVP usage).
2. Enable APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps Static API
   - Places API
   - Directions API
3. Create three keys (next section).
4. Set quota alerts at 50/80/100% of expected daily request count for
   Places, Directions, and Static Maps. Cost runaway from a buggy client
   loop is a real risk; alerts are cheap insurance.
5. Set a billing budget alert (e.g. $50/day) so a sudden spike notifies the
   team before it becomes expensive.

---

## 2. The three keys

### Android key (used by the mobile app on Android)

- **Application restrictions**: Android apps. Add the package name
  (`com.travelbuddy.app`) and the SHA-1 fingerprint of the signing key —
  add **both** debug and release fingerprints.
- **API restrictions**: Maps SDK for Android only.

Get the debug SHA-1 with:

```bash
keytool -list -v -keystore "$HOME/.android/debug.keystore" \
        -alias androiddebugkey -storepass android -keypass android
```

The release SHA-1 comes from your release keystore. Production uses a
separate fingerprint that must also be added to the Android key.

### iOS key (used by the mobile app on iOS)

- **Application restrictions**: iOS apps. Add the bundle id
  (`com.travelbuddy.app`).
- **API restrictions**: Maps SDK for iOS only.

### Server key (used by the backend)

- **Application restrictions**: IP addresses (the deploy IP) — or none with
  tight per-API quotas if the deploy IP is dynamic.
- **API restrictions**: Places API, Directions API, Maps Static API.

The server key is provisioned by the backend repo (PR 1); confirm it's
present in the deploy environment and that `GOOGLE_MAPS_URL_SIGNING_SECRET`
is also set (the static-map URL signature is computed in the backend).

---

## 3. Android dev setup

The Maps key is supplied to the build via `android/local.properties` —
which is gitignored — and substituted into `AndroidManifest.xml` through
`manifestPlaceholders`. To set up:

1. Open `android/local.properties` and add a line:
   ```
   MAPS_API_KEY=AIzaSy...your_android_key...
   ```
2. Build and run: `flutter run -d <android-device>`.

Flow under the hood: `local.properties` → `build.gradle.kts` reads it via
a `Properties()` block → `manifestPlaceholders["MAPS_API_KEY"]` →
`${MAPS_API_KEY}` placeholder in `AndroidManifest.xml`. No source file ever
contains the key string.

For CI: pass the key on the gradle CLI instead of editing
`local.properties`:

```
./gradlew assembleRelease -PMAPS_API_KEY=$ANDROID_MAPS_KEY
```

`build.gradle.kts` falls through to `project.findProperty("MAPS_API_KEY")`
when `local.properties` doesn't carry the key.

---

## 4. iOS dev setup

The Maps key is supplied via a separate `Maps.xcconfig` file that is
optionally included by the existing `Debug.xcconfig` and `Release.xcconfig`.
`Maps.xcconfig` is gitignored; a committed `Maps.xcconfig.example` is the
template. To set up:

1. Copy the template:
   ```
   cp ios/Flutter/Maps.xcconfig.example ios/Flutter/Maps.xcconfig
   ```
2. Edit `ios/Flutter/Maps.xcconfig` and paste the iOS key:
   ```
   MAPS_API_KEY=AIzaSy...your_ios_key...
   ```
3. From `ios/`, run `pod install` if you haven't already.
4. Build and run: `flutter run -d <iphone>`.

Flow under the hood: `Maps.xcconfig` → `Debug.xcconfig` /
`Release.xcconfig` (via `#include? "Maps.xcconfig"`) → Xcode build setting
`MAPS_API_KEY` → `$(MAPS_API_KEY)` substitution in `Info.plist`'s
`GMSApiKey` entry → `Bundle.main.object(forInfoDictionaryKey: "GMSApiKey")`
in `AppDelegate.swift` calls `GMSServices.provideAPIKey(...)`.

The `#include?` (note the `?`) is an optional include. If `Maps.xcconfig`
is missing, the build still succeeds; the Maps SDK then logs an error and
the map renders blank. The rest of the app remains functional.

For CI: write the key into `ios/Flutter/Maps.xcconfig` in a pre-build step,
e.g. `echo "MAPS_API_KEY=$IOS_MAPS_KEY" > ios/Flutter/Maps.xcconfig`.

---

## 5. Verification

Run the app on a real device or simulator with a valid key. Save a trip in
chat, then tap the inline map thumbnail.

- **Tiles render, markers and polylines appear**: setup correct.
- **Android grey overlay reading "for development purposes only"**: the key
  is missing or doesn't allow the Maps SDK for Android, the package name,
  or the SHA-1 fingerprint. Re-check the key restrictions.
- **iOS blank/grey map**: the `GMSApiKey` Info.plist entry is missing, or
  `Maps.xcconfig` isn't being included. Run `flutter clean`, then a fresh
  build. Look in the Xcode console for a Google Maps SDK error line.
- **The app crashes on launch**: shouldn't happen — `AppDelegate.swift`
  wraps `GMSServices.provideAPIKey(...)` in an `if let` so a missing key
  is non-fatal. If you see a crash, the failure is elsewhere.

To confirm no key string leaks into logs:

```
flutter run --verbose | grep -i 'AIza'
```

Expected: no matches. The keys live only in gitignored files
(`local.properties`, `Maps.xcconfig`) and the substituted manifest /
plist; nothing prints them.

---

## 6. Key rotation

If a key is ever committed to source by accident (it has happened), rotate
it immediately:

1. In the Cloud Console, **delete** the leaked key.
2. Create a new restricted key (same restrictions as the deleted one).
3. Update `local.properties` (Android) or `Maps.xcconfig` (iOS) on every
   developer's machine and in CI secrets.
4. Re-deploy.

The **previous PR introduced a hardcoded key in source**
(`AIzaSyDectGpXKc04T6U5MyccC7L5DVl0xbUFY4`). PR 3 migrated to the
placeholder pattern but the key remains in git history. Rotate it as part
of merging PR 3.

---

## 7. Troubleshooting

- **"Flutter run" works but maps don't render after a `pod install`**:
  Xcode caches build settings aggressively. Run "Product → Clean Build
  Folder" in Xcode (or `flutter clean` from the terminal), then build
  again.

- **Markers render but polylines do not**: a polyline can be silently
  dropped if its `encoded_polyline` decodes to an empty list. Check the
  trip's `trip.routes` array — if empty, the backend planner didn't
  compute routes (older trip, walking-only days, or routing quota
  exhausted). The map still shows markers; just not the lines.

- **Map shows but is grey on Android with the watermark**: see
  Verification above — almost always a key restriction issue.

- **Map crashes on first marker tap**: rare; usually means the
  `BitmapDescriptor` produced by `buildNumberedMarkerBitmap` was malformed.
  Hot-restart the app; if it persists, file a bug.
