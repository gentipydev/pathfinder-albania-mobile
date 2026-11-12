import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/ui/common/modals//fullscreen_video_viewer.dart';
import 'package:pathfinder_albania/ui/common/modals/fullscreen_maps_viewer.dart';
import 'package:pathfinder_albania/ui/screens/artifact/artifact_details/artifact_details_screen.dart';
import 'package:pathfinder_albania/ui/screens/collection/collection_screen.dart';
import 'package:pathfinder_albania/ui/screens/home/destinations_home_screen.dart';
import 'package:pathfinder_albania/ui/screens/intro/intro_screen.dart';
import 'package:pathfinder_albania/ui/screens/page_not_found/page_not_found.dart';
import 'package:pathfinder_albania/ui/screens/timeline/timeline_screen.dart';
import 'package:pathfinder_albania/ui/screens/destination_details/destinations_details_screen.dart';
import 'package:pathfinder_albania/utils/dlog.dart';
import 'package:pathfinder_albania/utils/route_logger.dart';

/// Shared paths / urls used across the app
class ScreenPaths {
  static String splash = '/';
  static String intro = '/welcome';
  static String home = '/home';

  static String destinationDetails(DestinationType type, {required int tabIndex}) => '$home/destination/${type.name}?t=$tabIndex';

  /// Dynamically nested pages, always added on to the existing path
  static String video(String id) => _appendToCurrentPath('/video/$id');
  static String maps(DestinationType type) => _appendToCurrentPath('/maps/${type.name}');
  static String timeline(DestinationType? type) => _appendToCurrentPath('/timeline?type=${type?.name ?? ''}');
  static String artifact(String id) => _appendToCurrentPath('/artifact/$id');
  static String collection(String id) => _appendToCurrentPath('/collection${id.isEmpty ? '' : '?id=$id'}');

  static String _appendToCurrentPath(String newPath) {
    final newPathUri = Uri.parse(newPath);
    final currentUri = appRouter.routeInformationProvider.value.uri;
    Map<String, dynamic> params = Map.of(currentUri.queryParameters);
    params.addAll(newPathUri.queryParameters);
    Uri? loc = Uri(
      path: '${currentUri.path}/${newPathUri.path}'.replaceAll('//', '/'),
      queryParameters: params,
    );
    return loc.toString();
  }
}

// Routes that are used multiple times
AppRoute get _artifactRoute => AppRoute(
  'artifact/:artifactId',
  (s) => ArtifactDetailsScreen(artifactId: s.pathParameters['artifactId']!),
);

AppRoute get _timelineRoute => AppRoute(
  'timeline',
  (s) => TimelineScreen(type: _tryParseDestinationType(s.uri.queryParameters['type'] ?? '')),
);

AppRoute get _collectionRoute => AppRoute(
  'collection',
  (s) => CollectionScreen(fromId: s.uri.queryParameters['id'] ?? ''),
  routes: [_artifactRoute],
);

/// Routing table, matches string paths to UI Screens, optionally parses params from the paths
final appRouter = GoRouter(
  redirect: _handleRedirect,
  observers: [if (kDebugMode) LoggingNavigatorObserver()],
  errorPageBuilder: (context, state) => MaterialPage(child: PageNotFound(state.uri.toString())),
  routes: buildAppRoutes(),
);

/// The route tree: `/home` is the destinations carousel, and the timeline,
/// collection and destination pages hang off it.
List<RouteBase> buildAppRoutes() => [
    ShellRoute(
      builder: (context, router, navigator) {
        return DestinationsAppScaffold(child: navigator);
      },
      routes: [
        AppRoute(
          ScreenPaths.splash,
          (_) => Container(color: $styles.colors.greyStrong),
        ), // This will be hidden
        AppRoute(ScreenPaths.intro, (_) => IntroScreen()),
        AppRoute(
          ScreenPaths.home,
          (_) => HomeScreen(),
          routes: [
            _timelineRoute,
            _collectionRoute,
            AppRoute(
              'destination/:detailsType',
              (s) {
                int tab = int.tryParse(s.uri.queryParameters['t'] ?? '') ?? 0;
                return DestinationDetailsScreen(
                  type: _parseDestinationType(s.pathParameters['detailsType']),
                  tabIndex: tab,
                );
              },
              useFade: true,
              // Destination sub-routes
              routes: [
                _timelineRoute,
                _collectionRoute,
                _artifactRoute,
                // Youtube Video
                AppRoute('video/:videoId', (s) {
                  return FullscreenVideoViewer(id: s.pathParameters['videoId']!);
                }, useFade: true),

                // Maps
                AppRoute(
                  'maps/:mapsType',
                  (s) => FullscreenMapsViewer(
                    type: _parseDestinationType(s.pathParameters['mapsType']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

/// Custom GoRoute sub-class to make the router declaration easier to read
class AppRoute extends GoRoute {
  AppRoute(
    String path,
    Widget Function(GoRouterState s) builder, {
    List<GoRoute> routes = const [],
    this.useFade = false,
  }) : super(
         path: path,
         routes: routes,
         pageBuilder: (context, state) {
           final pageContent = Scaffold(
             body: builder(state),
             resizeToAvoidBottomInset: false,
           );
           if (useFade || $styles.disableAnimations) {
             return CustomTransitionPage(
               key: state.pageKey,
               child: pageContent,
               transitionsBuilder: (context, animation, secondaryAnimation, child) {
                 return FadeTransition(opacity: animation, child: child);
               },
             );
           }
           return CupertinoPage(child: pageContent);
         },
       );
  final bool useFade;
}

String? get initialDeeplink => _initialDeeplink;
String? _initialDeeplink;

String? _handleRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;

  // Prevent anyone from navigating away from `/` if app is starting up.
  if (!appLogic.isBootstrapComplete && path != ScreenPaths.splash) {
    dlog('redirect $path → ${ScreenPaths.splash} (bootstrap incomplete)',
        name: 'nav', level: LogLevel.info);
    _initialDeeplink ??= state.uri.toString();
    return ScreenPaths.splash;
  }
  if (!appLogic.isBootstrapComplete) return null;

  // Onboarding gate: a fresh install sees the intro first.
  final onboarded = settingsBloc.state.hasCompletedOnboarding;
  if (!onboarded && path != ScreenPaths.intro) return ScreenPaths.intro;

  if (!kIsWeb) dlog('navigate to ${state.uri}', name: 'nav');
  return null;
}

DestinationType _parseDestinationType(String? value) {
  const fallback = DestinationType.butrint;
  if (value == null) return fallback;
  return _tryParseDestinationType(value) ?? fallback;
}

DestinationType? _tryParseDestinationType(String value) => DestinationType.values.asNameMap()[value];
