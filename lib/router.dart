import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pathfinder_albania/agent/agent_module.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/config/env.dart';
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
  static String auth = '/auth';
  static String home = '/home';
  static String conversations = '$home/conversations';
  static String preferences = '$home/preferences';
  static String trip(String id) => '$home/trip/$id';

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
  routes: buildAppRoutes(agentEnabled: Env.agentEnabled),
);

/// The route tree for the current [AppMode]. In showcase mode `/home` is the
/// destinations carousel itself; in full mode it is the agent's bottom-nav
/// shell (whose first tab is that same carousel) and the sign-in, chat
/// history, preferences and trip pages are added.
List<RouteBase> buildAppRoutes({required bool agentEnabled}) => [
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
        if (agentEnabled) AgentModule.authRoute,
        AppRoute(
          ScreenPaths.home,
          (_) => agentEnabled ? AgentModule.shell() : HomeScreen(),
          routes: [
            if (agentEnabled) ...AgentModule.homeRoutes,
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

/// True when the user must sign in before reaching `/home`. Never in
/// showcase mode; in full mode, unless already signed in or the temporary
/// BYPASS_LOGIN dev flag is on. Shared by the router redirect, the bootstrap
/// start screen and the end of the intro.
bool get needsLogin => Env.agentEnabled && !AgentModule.isAuthenticated && !Env.bypassLogin;

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

  final onboarded = settingsBloc.state.hasCompletedOnboarding;

  // Onboarding gate — must come before auth so a fresh install sees intro first.
  if (!onboarded && path != ScreenPaths.intro) return ScreenPaths.intro;

  // Auth gate — only after onboarding is complete, and only in full mode.
  if (onboarded && needsLogin && path != ScreenPaths.auth) {
    return ScreenPaths.auth;
  }

  // Bounce signed-in users off splash/auth.
  final authed = Env.agentEnabled && AgentModule.isAuthenticated;
  if (authed && (path == ScreenPaths.splash || path == ScreenPaths.auth)) {
    return initialDeeplink ?? ScreenPaths.home;
  }

  if (!kIsWeb) dlog('navigate to ${state.uri}', name: 'nav');
  return null;
}

DestinationType _parseDestinationType(String? value) {
  const fallback = DestinationType.butrint;
  if (value == null) return fallback;
  return _tryParseDestinationType(value) ?? fallback;
}

DestinationType? _tryParseDestinationType(String value) => DestinationType.values.asNameMap()[value];
