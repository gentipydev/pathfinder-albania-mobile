import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pathfinder_albania/router.dart';

/// Full paths of every GoRoute in [routes], e.g. `/home/trip/:tripId`.
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
  const agentPaths = [
    '/auth',
    '/home/conversations',
    '/home/preferences',
    '/home/trip/:tripId',
  ];
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

  test('showcase mode registers only the showcase routes', () {
    final paths = _paths(buildAppRoutes(agentEnabled: false));
    expect(paths, containsAll(showcasePaths));
    for (final p in agentPaths) {
      expect(paths, isNot(contains(p)), reason: '$p must not exist in showcase mode');
    }
  });

  test('full mode registers showcase and agent routes', () {
    final paths = _paths(buildAppRoutes(agentEnabled: true));
    expect(paths, containsAll([...showcasePaths, ...agentPaths]));
  });
}
