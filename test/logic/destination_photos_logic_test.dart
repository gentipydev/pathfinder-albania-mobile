import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/assets.dart';
import 'package:pathfinder_albania/logic/common/http_client.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';
import 'package:pathfinder_albania/logic/destination_photos_logic.dart';

void main() {
  const type = DestinationType.butrint;
  late int calls;

  DestinationPhotosLogic build(HttpResponse Function() respond, {String base = 'https://api.test'}) {
    calls = 0;
    return DestinationPhotosLogic(
      baseUrl: () => base,
      httpGet: (url, {headers}) async {
        calls++;
        expect(url, 'https://api.test/destinations/butrint/photos');
        return respond();
      },
    );
  }

  test('bundled photos are the four photo-N.jpg assets of the destination', () {
    expect(type.bundledPhotos, [
      'assets/images/butrint/photo-1.jpg',
      'assets/images/butrint/photo-2.jpg',
      'assets/images/butrint/photo-3.jpg',
      'assets/images/butrint/photo-4.jpg',
    ]);
  });

  final bundled = [for (final p in type.bundledPhotos) (url: p, thumbUrl: p)];

  test('returns the backend photos with their small copies and caches them', () async {
    final logic = build(
      () => HttpResponse(
        statusCode: 200,
        body:
            '{"photos":["https://cdn/a.jpg","https://cdn/b.jpg"],'
            '"thumbs":["https://cdn/thumbs/a.jpg","https://cdn/thumbs/b.jpg"]}',
      ),
    );
    const expected = [
      (url: 'https://cdn/a.jpg', thumbUrl: 'https://cdn/thumbs/a.jpg'),
      (url: 'https://cdn/b.jpg', thumbUrl: 'https://cdn/thumbs/b.jpg'),
    ];
    expect(await logic.getPhotos(type), expected);
    expect(await logic.getPhotos(type), expected);
    expect(calls, 1);
  });

  test('missing or short thumbs list → the full-size URL stands in', () async {
    final logic = build(
      () => HttpResponse(
        statusCode: 200,
        body: '{"photos":["https://cdn/a.jpg","https://cdn/b.jpg"],"thumbs":["https://cdn/thumbs/a.jpg"]}',
      ),
    );
    expect(await logic.getPhotos(type), [
      (url: 'https://cdn/a.jpg', thumbUrl: 'https://cdn/thumbs/a.jpg'),
      (url: 'https://cdn/b.jpg', thumbUrl: 'https://cdn/b.jpg'),
    ]);

    final oldBackend = build(() => HttpResponse(statusCode: 200, body: '{"photos":["https://cdn/a.jpg"]}'));
    expect(await oldBackend.getPhotos(type), [(url: 'https://cdn/a.jpg', thumbUrl: 'https://cdn/a.jpg')]);
  });

  test('backend unreachable → bundled photos, and the next call retries', () async {
    final logic = build(() => HttpResponse.error(NetErrorType.disconnected));
    expect(await logic.getPhotos(type), bundled);
    expect(await logic.getPhotos(type), bundled);
    expect(calls, 2);
  });

  test('backend has no photos for the destination → bundled photos', () async {
    final logic = build(() => HttpResponse(statusCode: 200, body: '{"photos":[]}'));
    expect(await logic.getPhotos(type), bundled);
  });

  test('unexpected response body → bundled photos instead of an error', () async {
    final logic = build(() => HttpResponse(statusCode: 200, body: '[]'));
    expect(await logic.getPhotos(type), bundled);
  });

  test('no backend configured → bundled photos without a request', () async {
    final logic = build(() => fail('must not request'), base: '');
    expect(await logic.getPhotos(type), bundled);
    expect(calls, 0);
  });
}
