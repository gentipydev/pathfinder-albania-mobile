# Backend snapshot (temporary)

Content the showcase used to fetch from the old `travel-buddy-backend`, bundled with the app
while that backend is being rewritten. Once the new backend serves it again, this folder goes
away and the two loaders below switch back to a network source.

Taken on 2026-11-12 from the Supabase backup `~/Backups/travel-buddy-v1-2026-11-10/` (storage
objects, byte-identical) and from the old API's live responses (manifests).

## Layout

| Path | What | Mirrors |
|---|---|---|
| `manifests/artifacts.json` | `{ "<slug>": { "highlights": [...], "collectibles": [...] } }` | `GET /destinations/{slug}/artifacts` |
| `manifests/photos.json` | `{ "<slug>": { "photos": [...], "thumbs": [...] } }` | `GET /destinations/{slug}/photos` |
| `artifact-photos/<slug>/*.jpg`, `.../thumbs/*.jpg` | 37 artifact images + small copies | Supabase bucket `artifact-photos` |
| `place-photos/destinations/<slug>/*.jpg`, `.../thumbs/*.jpg` | 62 destination photos + small copies | Supabase bucket `place-photos` |
| `credits/` | Source and licence of every picture (**not bundled** — not listed in `pubspec.yaml`) | old repo `scripts/data/*.json` |

Every URL of the form `https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>`
became the asset path `assets/backend_snapshot/<bucket>/<path>`, so a future re-upload keeps
working with the same relative paths. The 8 slugs are the `DestinationType.slug` values.

Readers: `lib/features/artifacts/bloc/artifacts_bloc.dart` and
`lib/logic/destination_photos_logic.dart`, through `lib/logic/common/bundled_content.dart`.

## Licensing

The photos come from Wikimedia Commons under CC BY / CC BY-SA and need attribution wherever they
are shown. The per-picture credits are in `credits/artifacts.json` (`photo` blocks) and
`credits/destination_photos.json`. An in-app credits screen is still owed.
