import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip_stop.dart';

/// Covers the `photos` field added in migration 014. The field is the wire
/// format the backend now sends; `effectivePhotos` is the UI-facing getter
/// the stop sheet (`_StopPhotoStack`) reads — it falls back to `photoUrl`
/// for old un-enriched trips so they keep rendering one image.
void main() {
  group('TripStop.fromJson photos', () {
    test('parses a multi-photo list', () {
      final stop = TripStop.fromJson({
        'id': 's1',
        'sort_order': 0,
        'name': 'Bunk\'Art 1',
        'kind': 'sight',
        'photo_url': 'https://example.com/p1.jpg',
        'photos': [
          'https://example.com/p1.jpg',
          'https://example.com/p2.jpg',
          'https://example.com/p3.jpg',
        ],
      });

      expect(stop.photos, hasLength(3));
      expect(stop.photos.first, 'https://example.com/p1.jpg');
    });

    test('defaults to empty list when `photos` key is absent', () {
      // Pre-014 backend payloads (or stops not yet re-enriched) omit `photos`.
      // The model must tolerate this without throwing — the legacy `photo_url`
      // is the fallback path.
      final stop = TripStop.fromJson({
        'id': 's1',
        'sort_order': 0,
        'name': 'X',
        'kind': 'sight',
        'photo_url': 'https://example.com/legacy.jpg',
      });

      expect(stop.photos, isEmpty);
      expect(stop.photoUrl, 'https://example.com/legacy.jpg');
    });

    test('drops non-string entries silently', () {
      // Defensive: backend ships strings, but we don't want a malformed
      // payload (e.g. a stray null or number from a bad migration) to crash
      // the whole sheet.
      final stop = TripStop.fromJson({
        'id': 's1',
        'sort_order': 0,
        'name': 'X',
        'kind': 'sight',
        'photos': ['https://ok.jpg', 42, null, 'https://also-ok.jpg'],
      });

      expect(stop.photos, [
        'https://ok.jpg',
        'https://also-ok.jpg',
      ]);
    });
  });

  group('TripStop.effectivePhotos', () {
    TripStop build({String? photoUrl, List<String> photos = const []}) {
      return TripStop(
        id: 's1',
        sortOrder: 0,
        name: 'Test',
        kind: StopKind.sight,
        photoUrl: photoUrl,
        photos: photos,
      );
    }

    test('returns photos when present', () {
      final stop = build(
        photoUrl: 'legacy.jpg',
        photos: ['a.jpg', 'b.jpg', 'c.jpg'],
      );
      expect(stop.effectivePhotos, ['a.jpg', 'b.jpg', 'c.jpg']);
    });

    test('caps to first 3 when backend over-shipped', () {
      // Defensive cap. The backend already trims to 3 in `_apply_to_stop`,
      // but the UI shouldn't trust that — extra photos would crash the
      // hero-index modular arithmetic for a 4+ length list rendered in a
      // 3-slot layout.
      final stop = build(photos: ['a', 'b', 'c', 'd', 'e']);
      expect(stop.effectivePhotos, ['a', 'b', 'c']);
    });

    test('falls back to [photoUrl] when photos is empty', () {
      final stop = build(photoUrl: 'only.jpg');
      expect(stop.effectivePhotos, ['only.jpg']);
    });

    test('returns empty list when both photos and photoUrl are absent', () {
      expect(build().effectivePhotos, isEmpty);
    });

    test('treats empty photoUrl string as absent', () {
      // The backend sends null when there's no photo, but historical rows
      // can have empty strings. Either should produce an empty result so
      // the UI shows the placeholder.
      final stop = build(photoUrl: '');
      expect(stop.effectivePhotos, isEmpty);
    });
  });
}
