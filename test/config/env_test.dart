import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/config/env.dart';

void main() {
  test('mapboxAccessToken reads MAPBOX_ACCESS_TOKEN from .env', () {
    dotenv.loadFromString(envString: 'MAPBOX_ACCESS_TOKEN=pk.test-token');
    expect(Env.mapboxAccessToken, 'pk.test-token');
  });

  test('a missing token is an empty string, so the maps stay blank instead of crashing', () {
    dotenv.loadFromString(envString: 'OTHER=1');
    expect(Env.mapboxAccessToken, '');
  });
}
