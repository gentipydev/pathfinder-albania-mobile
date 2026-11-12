import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pathfinder_albania/router.dart';

/// Full paths of every GoRoute in [routes], e.g. `/home/destination/:detailsType`.
List<String> _paths(List<RouteBase> routes, [String parent = '']) {
  final out = <String>[];
  for (final r in routes) {
    if (r is GoRoute) {
      final full = r.path.startsWith('/') ? r.path : '$parent/${r.path}';
      out.add(full);
      out.addAll(_paths(r.routes, full));
    } else {
      out.addAll(_paths(r.routes, parent));
    }
  }
  return out;
}

void main() {
  const showcasePaths = [
    '/',
    '/welcome',
    '/home',
    '/home/destination/:detailsType',
    '/home/destination/:detailsType/artifact/:artifactId',
    '/home/destination/:detailsType/video/:videoId',
    '/home/destination/:detailsType/maps/:mapsType',
    '/home/timeline',
    '/home/collection',
  ];

  // Pages of the removed agent side (sign-in, chat history, preferences,
  // trips). Kept as a regression guard: nothing should bring them back.
  const removedPaths = [
    '/auth',
    '/home/conversations',
    '/home/preferences',
    '/home/trip/:tripId',
  ];

  test('the route tree is the showcase and nothing else', () {
    final paths = _paths(buildAppRoutes());
    expect(paths, containsAll(showcasePaths));
    for (final p in removedPaths) {
      expect(paths, isNot(contains(p)), reason: '$p must not exist');
    }
  });
}
