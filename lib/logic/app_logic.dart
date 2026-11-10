import 'dart:async';
import 'dart:ui';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MapboxOptions;
import 'package:travel_buddy/agent/agent_module.dart';
import 'package:travel_buddy/config/env.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/settings/bloc/settings_event.dart';
import 'package:travel_buddy/logic/common/dio_client.dart';
import 'package:travel_buddy/logic/common/platform_info.dart';
import 'package:travel_buddy/ui/common/modals/fullscreen_video_viewer.dart';
import 'package:travel_buddy/ui/common/utils/page_routes.dart';

class AppLogic {
  Size _appSize = Size.zero;

  /// Set by `startWarmup`. `bootstrap` awaits it before kicking off
  /// `artifactsBloc.preloadAll()` so the eight catalog requests don't
  /// race the backend's scale-from-zero cold-start.
  Future<void>? _warmupFuture;

  /// Held for the lifetime of the app to flush throttled saves on
  /// background/hide, so a backgrounded-then-killed app doesn't lose a
  /// just-made toggle that was still inside the 2 s throttle window.
  AppLifecycleListener? _lifecycleListener;

  /// Indicates to the rest of the app that bootstrap has not completed.
  /// The router will use this to prevent redirects while bootstrapping.
  bool isBootstrapComplete = false;

  /// Indicates which orientations the app will allow be default. Affects Android/iOS devices only.
  /// Defaults to both landscape (hz) and portrait (vt)
  List<Axis> supportedOrientations = [Axis.vertical, Axis.horizontal];

  /// Allow a view to override the currently supported orientations. For example, [FullscreenVideoViewer] always wants to enable both landscape and portrait.
  /// If a view sets this override, they are responsible for setting it back to null when finished.
  List<Axis>? _supportedOrientationsOverride;
  set supportedOrientationsOverride(List<Axis>? value) {
    if (_supportedOrientationsOverride != value) {
      _supportedOrientationsOverride = value;
      _updateSystemOrientation();
    }
  }

  /// Initialize the app and all main actors.
  /// Loads settings, sets up services etc.
  Future<void> bootstrap() async {
    debugPrint('bootstrap start...');
    // Set min-sizes for desktop apps
    if (!kIsWeb && (PlatformInfo.isWindows || PlatformInfo.isMacOS)) {
      await DesktopWindow.setMinWindowSize($styles.sizes.minAppSize);
    }

    if (kIsWeb) {
      debugPrint('Thanks for checking out Travel Buddy on the web!');
      // Required on web to automatically enable accessibility features
      WidgetsFlutterBinding.ensureInitialized().ensureSemantics();
    }

    // Load any bitmaps the views might need
    await AppBitmaps.init();

    // Mapbox needs its public access token before any MapWidget is built.
    // Guarded so a missing token leaves maps blank instead of throwing on
    // launch — the same fail-soft posture the app takes elsewhere.
    final mapboxToken = Env.mapboxAccessToken;
    if (mapboxToken.isNotEmpty) MapboxOptions.setAccessToken(mapboxToken);

    // Set preferred refresh rate to the max possible (the OS may ignore this)
    if (!kIsWeb && PlatformInfo.isAndroid) {
      await FlutterDisplayMode.setHighRefreshRate();
    }

    // Settings
    await settingsBloc.loadFromPersistence();

    // Agent side: restore the auth session and load preferences.
    if (Env.agentEnabled) AgentModule.onBootstrap();

    // Localizations: LocaleLogic resolves from persisted/system locale and
    // returns the code; SettingsBloc adopts it without re-running the
    // destinations/timeline cascade (we call those next, in order).
    final resolvedLocaleCode = await localeLogic.load();
    settingsBloc.add(SettingsLocaleHydrated(resolvedLocaleCode));

    // Destinations Data
    destinationsLogic.init();

    // Events
    timelineLogic.init();

    // Collectibles (CollectiblesBloc constructor fires NativeWidgetService.init
    // internally; loadFromPersistence dispatches the load event and awaits
    // the emit so SharedPreferences hydration is complete before the user
    // can interact with the collection screen).
    await collectiblesBloc.loadFromPersistence();

    // Persist throttled state when the app is hidden or paused. Both
    // settingsBloc and collectiblesBloc write through a 2 s throttler;
    // without this, a quick background-then-kill cycle drops the last toggle.
    _lifecycleListener ??= AppLifecycleListener(
      onHide: _flushPendingSaves,
      onPause: _flushPendingSaves,
    );

    // Warm the artifact catalog cache for all destinations in the
    // background. Best-effort — screens still re-fetch on mount if this
    // fails. Sequenced after the backend warmup ping (if started) so the
    // eight requests hit a hot backend.
    unawaited(_warmupThenPreload());

    // Wait at least 1 frame to give GoRouter time to catch the initial deeplink
    await Future.delayed(1.milliseconds);

    // Flag bootStrap as complete
    isBootstrapComplete = true;

    // Load initial view (replace empty initial view which is covered by a native splash screen)
    final showIntro = settingsBloc.state.hasCompletedOnboarding == false;
    if (showIntro) {
      appRouter.go(ScreenPaths.intro);
    } else if (needsLogin) {
      appRouter.go(ScreenPaths.auth);
    } else {
      appRouter.go(initialDeeplink ?? ScreenPaths.home);
    }
  }

  /// Fires a fire-and-forget GET `/` against the backend so an idled
  /// instance wakes up while the rest of bootstrap runs. Stores the
  /// future so `_warmupThenPreload` can wait on it. Safe to call multiple
  /// times — subsequent calls are no-ops.
  ///
  /// The backend has no `GET /` route, so this 404s by design — the point
  /// is the round trip, not the response.
  void startWarmup() {
    if (_warmupFuture != null || !Env.hasApiBaseUrl) return;
    _warmupFuture = appDio
        .get<dynamic>(
          '/',
          options: Options(
            receiveTimeout: const Duration(seconds: 90),
            validateStatus: (_) => true,
          ),
        )
        .then((_) {}, onError: (_) {});
  }

  Future<void> _warmupThenPreload() async {
    final warmup = _warmupFuture;
    if (warmup != null) await warmup;
    await artifactsBloc.preloadAll();
  }

  /// Fire-and-forget: kick the throttled save chain so any pending toggle
  /// makes it to disk before the OS suspends us. Sync caller is the
  /// `AppLifecycleListener`; the OS gives us a brief grace period in which
  /// the SharedPreferences write (~ms) almost always lands.
  void _flushPendingSaves() {
    unawaited(settingsBloc.flushPendingSaveAwaitable());
    unawaited(collectiblesBloc.flushPendingSaveAwaitable());
  }

  Future<T?> showFullscreenDialogRoute<T>(BuildContext context, Widget child) async {
    return await Navigator.of(context).push<T>(
      PageRoutes.dialog<T>(child, duration: $styles.times.pageTransition),
    );
  }

  /// Called from the UI layer once a MediaQuery has been obtained
  void handleAppSizeChanged(Size appSize) {
    /// Disable landscape layout on smaller form factors
    bool isSmall = display.size.shortestSide / display.devicePixelRatio < 600;
    supportedOrientations = isSmall ? [Axis.vertical] : [Axis.vertical, Axis.horizontal];
    _updateSystemOrientation();
    _appSize = appSize;
  }

  Display get display => PlatformDispatcher.instance.displays.first;

  bool shouldUseNavRail() => _appSize.width > _appSize.height && _appSize.height > 250;

  void _updateSystemOrientation() {
    final axisList = _supportedOrientationsOverride ?? supportedOrientations;
    //debugPrint('updateDeviceOrientation, supportedAxis: $axisList');
    final orientations = <DeviceOrientation>[];
    if (axisList.contains(Axis.vertical)) {
      orientations.addAll([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    if (axisList.contains(Axis.horizontal)) {
      orientations.addAll([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    SystemChrome.setPreferredOrientations(orientations);
  }

  void precacheUrl(String url, BuildContext context) async {
    await precacheImage(
      AssetImage(url),
      context,
      onError: (error, stackTrace) {
        debugPrint('Loading $url failed - ${error.toString()}');
      },
    );
  }

  void precacheIcons(BuildContext context) {
    // Precache the active and idle icons for the navigation bar.
    List<String> urls = [];
    for (var i = 0; i < 2; i++) {
      urls.add('${ImagePaths.common}/tab-editorial${i == 0 ? '-active' : ''}.png');
      urls.add('${ImagePaths.common}/tab-photos${i == 0 ? '-active' : ''}.png');
      urls.add('${ImagePaths.common}/tab-artifacts${i == 0 ? '-active' : ''}.png');
      urls.add('${ImagePaths.common}/tab-timeline${i == 0 ? '-active' : ''}.png');
    }
    for (var url in urls) {
      precacheUrl(url, context);
    }
  }

  void precacheDestinationImages(BuildContext context) {
    List<String> urls = [
      '${ImagePaths.root}/butrint/butrint.png',
      '${ImagePaths.root}/butrint/foreground-left.png',
      '${ImagePaths.root}/butrint/foreground-right.png',
      '${ImagePaths.root}/butrint/top-left.png',
      '${ImagePaths.root}/butrint/top-right.png',
      '${ImagePaths.root}/butrint/sun.png',
      '${ImagePaths.root}/berat/berat.png',
      '${ImagePaths.root}/berat/foreground-left.png',
      '${ImagePaths.root}/berat/foreground-right.png',
      '${ImagePaths.root}/berat/sun.png',
      '${ImagePaths.root}/gjirokaster/gjirokaster.png',
      '${ImagePaths.root}/gjirokaster/foreground-left.png',
      '${ImagePaths.root}/gjirokaster/foreground-right.png',
      '${ImagePaths.root}/gjirokaster/sun.png',
      '${ImagePaths.root}/apollonia/apollonia.png',
      '${ImagePaths.root}/apollonia/foreground-left.png',
      '${ImagePaths.root}/apollonia/foreground-right.png',
      '${ImagePaths.root}/apollonia/sun.png',
      '${ImagePaths.root}/theth/theth.png',
      '${ImagePaths.root}/theth/foreground-back.png',
      '${ImagePaths.root}/theth/foreground-front.png',
      '${ImagePaths.root}/theth/sun.png',
      '${ImagePaths.root}/kruja/kruja.png',
      '${ImagePaths.root}/kruja/foreground-left.png',
      '${ImagePaths.root}/kruja/foreground-right.png',
      '${ImagePaths.root}/kruja/moon.png',
      '${ImagePaths.root}/albanian_alps/albanian_alps.png',
      '${ImagePaths.root}/albanian_alps/foreground-back.png',
      '${ImagePaths.root}/albanian_alps/foreground-front.png',
      '${ImagePaths.root}/albanian_alps/moon.png',
      '${ImagePaths.root}/korca/korca.png',
      '${ImagePaths.root}/korca/foreground-left.png',
      '${ImagePaths.root}/korca/foreground-right.png',
      '${ImagePaths.root}/korca/sun.png',
      '${ImagePaths.root}/korca/pool.png',
    ];
    List<String> folderNames = [
      'butrint',
      'berat',
      'gjirokaster',
      'apollonia',
      'theth',
      'kruja',
      'albanian_alps',
      'korca',
    ];

    // Universals.
    for (var name in folderNames) {
      urls.add('${ImagePaths.root}/$name/flattened.jpg');
      urls.add('${ImagePaths.root}/$name/destination-button.png');
      urls.add('${ImagePaths.root}/$name/photo-1.jpg');
      urls.add('${ImagePaths.root}/$name/photo-2.jpg');
      urls.add('${ImagePaths.root}/$name/photo-3.jpg');
      urls.add('${ImagePaths.root}/$name/photo-4.jpg');
    }

    for (var url in urls) {
      precacheUrl(url, context);
    }
  }
}
