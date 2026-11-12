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

  test('an empty .env (loaded as optional, like main.dart does) gives an empty token', () {
    dotenv.loadFromString(envString: '', isOptional: true);
    expect(Env.mapboxAccessToken, '');
  });

  test('reading before any .env was loaded gives an empty token instead of throwing', () {
    dotenv.clean();
    expect(Env.mapboxAccessToken, '');
  });
}
