import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/ui/common/remote_photo.dart';

void main() {
  test('http(s) URLs load from the network through the disk cache', () {
    for (final url in ['https://cdn.test/a.jpg', 'http://127.0.0.1:8001/a.jpg']) {
      final provider = photoImageProvider(url);
      expect(provider, isA<CachedNetworkImageProvider>());
      expect((provider as CachedNetworkImageProvider).url, url);
    }
  });

  test('bundled asset paths load from the app bundle', () {
    final provider = photoImageProvider('assets/images/butrint/photo-1.jpg');
    expect(provider, isA<AssetImage>());
    expect((provider as AssetImage).assetName, 'assets/images/butrint/photo-1.jpg');
  });
}
