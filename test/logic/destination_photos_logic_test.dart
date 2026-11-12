import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/assets.dart';
import 'package:pathfinder_albania/logic/common/bundled_content.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';
import 'package:pathfinder_albania/logic/destination_photos_logic.dart';

void main() {
  const type = DestinationType.butrint;
  late int reads;

  /// A logic whose manifest asset is [text]; `null` makes the read fail as a
  /// missing asset would.
  DestinationPhotosLogic build(String? text) {
    reads = 0;
    return DestinationPhotosLogic(
      loadAsset: (key) async {
        reads++;
        expect(key, BundledContent.photosManifest);
        if (text == null) throw StateError('Unable to load asset: $key');
        return text;
      },
    );
  }

  String manifest(Map<String, dynamic> json) => jsonEncode(json);

  test('bundled photos are the four photo-N.jpg assets of the destination', () {
    expect(type.bundledPhotos, [
      'assets/images/butrint/photo-1.jpg',
      'assets/images/butrint/photo-2.jpg',
      'assets/images/butrint/photo-3.jpg',
      'assets/images/butrint/photo-4.jpg',
    ]);
  });

  final bundled = [for (final p in type.bundledPhotos) (url: p, thumbUrl: p)];

  test('returns the snapshot photos with their small copies and reads the manifest once', () async {
    final logic = build(manifest({
      'butrint': {
        'photos': ['assets/s/a.jpg', 'assets/s/b.jpg'],
        'thumbs': ['assets/s/thumbs/a.jpg', 'assets/s/thumbs/b.jpg'],
      },
      'berat': {
        'photos': ['assets/s/c.jpg'],
        'thumbs': ['assets/s/thumbs/c.jpg'],
      },
    }));
    const expected = [
      (url: 'assets/s/a.jpg', thumbUrl: 'assets/s/thumbs/a.jpg'),
      (url: 'assets/s/b.jpg', thumbUrl: 'assets/s/thumbs/b.jpg'),
    ];
    expect(await logic.getPhotos(type), expected);
    expect(await logic.getPhotos(type), expected);
    expect(await logic.getPhotos(DestinationType.berat), [
      (url: 'assets/s/c.jpg', thumbUrl: 'assets/s/thumbs/c.jpg'),
    ]);
    expect(reads, 1);
  });

  test('missing or short thumbs list → the full-size path stands in', () async {
    final logic = build(manifest({
      'butrint': {
        'photos': ['assets/s/a.jpg', 'assets/s/b.jpg'],
        'thumbs': ['assets/s/thumbs/a.jpg'],
      },
    }));
    expect(await logic.getPhotos(type), [
      (url: 'assets/s/a.jpg', thumbUrl: 'assets/s/thumbs/a.jpg'),
      (url: 'assets/s/b.jpg', thumbUrl: 'assets/s/b.jpg'),
    ]);

    final noThumbs = build(manifest({
      'butrint': {
        'photos': ['assets/s/a.jpg'],
      },
    }));
    expect(await noThumbs.getPhotos(type), [(url: 'assets/s/a.jpg', thumbUrl: 'assets/s/a.jpg')]);
  });

  test('unreadable manifest → bundled photos, and the next call retries', () async {
    final logic = build(null);
    expect(await logic.getPhotos(type), bundled);
    expect(await logic.getPhotos(type), bundled);
    expect(reads, 2);
  });

  test('no entry for the destination → bundled photos', () async {
    final logic = build(manifest({
      'berat': {
        'photos': ['assets/s/c.jpg'],
      },
    }));
    expect(await logic.getPhotos(type), bundled);
  });

  test('an empty list → bundled photos', () async {
    final logic = build(manifest({
      'butrint': {'photos': <String>[]},
    }));
    expect(await logic.getPhotos(type), bundled);
  });

  test('unexpected manifest shape → bundled photos instead of an error', () async {
    expect(await build('[]').getPhotos(type), bundled);
    expect(await build('not json').getPhotos(type), bundled);
  });

  test('the shipped snapshot manifest lists 62 photos across 8 destinations and every file exists', () async {
    final logic = DestinationPhotosLogic(loadAsset: (key) => File(key).readAsString());
    var total = 0;
    for (final t in DestinationType.values) {
      final photos = await logic.getPhotos(t);
      expect(photos, isNotEmpty, reason: '${t.slug} fell back to the bundled photos');
      for (final p in photos) {
        expect(p.url, startsWith('${BundledContent.root}/place-photos/destinations/${t.slug}/'));
        expect(p.thumbUrl, isNot(p.url), reason: '${p.url} has no small copy');
        expect(File(p.url).existsSync(), isTrue, reason: '${p.url} missing');
        expect(File(p.thumbUrl).existsSync(), isTrue, reason: '${p.thumbUrl} missing');
      }
      total += photos.length;
    }
    expect(total, 62);
  });
}
