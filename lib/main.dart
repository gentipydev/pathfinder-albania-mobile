import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:pathfinder_albania/features/collectibles/bloc/collectibles_bloc.dart';
import 'package:pathfinder_albania/features/settings/bloc/settings_bloc.dart';
import 'package:pathfinder_albania/features/settings/bloc/settings_state.dart';
import 'package:pathfinder_albania/l10n/app_localizations.dart';
import 'package:pathfinder_albania/logic/locale_logic.dart';
import 'package:pathfinder_albania/logic/native_widget_service.dart';
import 'package:pathfinder_albania/logic/timeline_logic.dart';
import 'package:pathfinder_albania/logic/destination_photos_logic.dart';
import 'package:pathfinder_albania/logic/destinations_logic.dart';
import 'package:pathfinder_albania/ui/common/app_shortcuts.dart';
import 'package:pathfinder_albania/utils/dev_bloc_observer.dart';
import 'package:pathfinder_albania/utils/url_strategy_native.dart'
    if (dart.library.js_interop) 'package:pathfinder_albania/utils/url_strategy_web.dart';

void main() async {
  // Path URLs (no `/#/`) on web; no-op elsewhere. Must run before the router
  // reads the initial location.
  configureUrlStrategy();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash screen up until app is finished bootstrapping
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  // Log every Bloc transition during debug builds so a silent no-op emit
  // (e.g. a forgotten copyWith) is visible.
  if (kDebugMode) Bloc.observer = DevBlocObserver();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Wrap the entire bootstrap chain so a failure in dotenv/runApp/bootstrap
  // can never leave the native splash up forever. Always remove the splash;
  // rethrow so crash reporters still see the cause.
  //
  // Sentry wraps the appRunner so unhandled exceptions inside reach the SDK.
  // The DSN comes from `--dart-define=SENTRY_DSN=…`; when empty (the local-
  // dev default) the SDK accepts the empty string as "disabled" and the rest
  // of bootstrap runs unchanged.
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      options.tracesSampleRate = 0.1;
      options.environment = const String.fromEnvironment(
        'SENTRY_ENVIRONMENT',
        defaultValue: 'development',
      );
      // `sendDefaultPii` is false by default in SDK 8.x; pin it explicitly so
      // a future SDK default flip doesn't silently start leaking headers /
      // cookies / IP addresses.
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      try {
        // `.env` only carries the optional Mapbox token, so a missing or
        // empty file must not stop the app: isOptional swallows both.
        await dotenv.load(fileName: '.env', isOptional: true);

        // Start app
        registerSingletons();
        runApp(const DestinationsApp());
        await appLogic.bootstrap();
      } catch (e, st) {
        debugPrint('bootstrap failed: $e\n$st');
        rethrow;
      } finally {
        FlutterNativeSplash.remove();
      }
    },
  );
}

/// Creates an app using the [MaterialApp.router] constructor and the global `appRouter`, an instance of [GoRouter].
class DestinationsApp extends StatefulWidget {
  const DestinationsApp({super.key});

  @override
  State<DestinationsApp> createState() => _DestinationsAppState();
}

class _DestinationsAppState extends State<DestinationsApp> {
  bool _imagesCached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesCached && kIsWeb) {
      appLogic.precacheIcons(context);
      appLogic.precacheDestinationImages(context);
      _imagesCached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: GetIt.I<SettingsBloc>()),
        BlocProvider<ArtifactsBloc>.value(value: GetIt.I<ArtifactsBloc>()),
        BlocProvider<CollectiblesBloc>.value(
          value: GetIt.I<CollectiblesBloc>(),
        ),
      ],
      child: BlocSelector<SettingsBloc, SettingsState, String?>(
        selector: (s) => s.currentLocale,
        builder: (context, locale) => MaterialApp.router(
          routeInformationProvider: appRouter.routeInformationProvider,
          routeInformationParser: appRouter.routeInformationParser,
          locale: locale == null ? null : Locale(locale),
          debugShowCheckedModeBanner: false,
          routerDelegate: appRouter.routerDelegate,
          shortcuts: AppShortcuts.defaults,
          theme: ThemeData(fontFamily: $styles.text.body.fontFamily, useMaterial3: true),
          color: $styles.colors.black,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}

/// Create the app singletons (logic and services).
void registerSingletons() {
  // Top level app controller
  GetIt.I.registerLazySingleton<AppLogic>(() => AppLogic());
  // Destinations
  GetIt.I.registerLazySingleton<DestinationsLogic>(() => DestinationsLogic());
  // Timeline / Events
  GetIt.I.registerLazySingleton<TimelineLogic>(() => TimelineLogic());
  // Settings
  GetIt.I.registerLazySingleton<SettingsBloc>(() => SettingsBloc());
  // Destination photo gallery (bundled snapshot)
  GetIt.I.registerLazySingleton<DestinationPhotosLogic>(() => DestinationPhotosLogic());
  // Localizations
  GetIt.I.registerLazySingleton<LocaleLogic>(() => LocaleLogic());
  // Home Widget Service (must register before CollectiblesBloc, which resolves
  // it via GetIt in its constructor default).
  GetIt.I.registerLazySingleton<NativeWidgetService>(() => NativeWidgetService());
  // Artifacts (curated Albanian catalog, bundled snapshot)
  GetIt.I.registerLazySingleton<ArtifactsBloc>(() => ArtifactsBloc());
  // Collectibles (resolves NativeWidgetService and ArtifactsBloc lazily)
  GetIt.I.registerLazySingleton<CollectiblesBloc>(() => CollectiblesBloc());
}

/// Add syntax sugar for quickly accessing the main "logic" controllers in the app
/// We deliberately do not create shortcuts for services, to discourage their use directly in the view/widget layer.
AppLogic get appLogic => GetIt.I.get<AppLogic>();
DestinationsLogic get destinationsLogic => GetIt.I.get<DestinationsLogic>();
TimelineLogic get timelineLogic => GetIt.I.get<TimelineLogic>();
SettingsBloc get settingsBloc => GetIt.I.get<SettingsBloc>();
DestinationPhotosLogic get destinationPhotosLogic => GetIt.I.get<DestinationPhotosLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();
ArtifactsBloc get artifactsBloc => GetIt.I.get<ArtifactsBloc>();
CollectiblesBloc get collectiblesBloc => GetIt.I.get<CollectiblesBloc>();

/// Global helpers for readability
AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => DestinationsAppScaffold.style;
