import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/config/env.dart';
import 'package:travel_buddy/features/artifacts/bloc/artifacts_bloc.dart';
import 'package:travel_buddy/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/features/collectibles/bloc/collectibles_bloc.dart';
import 'package:travel_buddy/features/preferences/bloc/preferences_bloc.dart';
import 'package:travel_buddy/features/settings/bloc/settings_bloc.dart';
import 'package:travel_buddy/features/settings/bloc/settings_state.dart';
import 'package:travel_buddy/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/features/tts/bloc/tts_bloc.dart';
import 'package:travel_buddy/features/voice/bloc/voice_bloc.dart';
import 'package:travel_buddy/l10n/app_localizations.dart';
import 'package:travel_buddy/logic/buddy/attachment_service.dart';
import 'package:travel_buddy/logic/buddy/chat_service.dart';
import 'package:travel_buddy/logic/buddy/conversations_service.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/logic/native_widget_service.dart';
import 'package:travel_buddy/logic/preferences/preferences_service.dart';
import 'package:travel_buddy/logic/timeline_logic.dart';
import 'package:travel_buddy/logic/destination_photos_logic.dart';
import 'package:travel_buddy/logic/destinations_logic.dart';
import 'package:travel_buddy/logic/auto_track_prefs.dart';
import 'package:travel_buddy/services/location_service.dart';
import 'package:travel_buddy/services/trip_service.dart';
import 'package:travel_buddy/services/user_service.dart';
import 'package:travel_buddy/ui/common/app_shortcuts.dart';
import 'package:travel_buddy/utils/dev_bloc_observer.dart';
import 'package:travel_buddy/utils/sentry_scrubber.dart';
import 'package:travel_buddy/utils/url_strategy_native.dart'
    if (dart.library.js_interop) 'package:travel_buddy/utils/url_strategy_web.dart';

void main() async {
  // Path URLs (no `/#/`) on web; no-op elsewhere. Must run before the router
  // reads the initial location.
  configureUrlStrategy();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash screen up until app is finished bootstrapping
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  // Phase 3 risk mitigation: log every Bloc transition during debug builds so
  // a silent no-op emit (e.g. forgotten copyWith on ChatMessage) is visible.
  if (kDebugMode) Bloc.observer = DevBlocObserver();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Wrap the entire bootstrap chain so a failure in dotenv/Env/Supabase/
  // warmup/runApp/bootstrap can never leave the native splash up forever.
  // Always remove the splash; rethrow so crash reporters still see the cause.
  //
  // Sentry wraps the appRunner so unhandled exceptions inside reach the SDK.
  // The DSN comes from `--dart-define=SENTRY_DSN=…`; when empty (the local-
  // dev default) the SDK accepts the empty string as "disabled" and the rest
  // of bootstrap runs unchanged. `beforeSend` redacts user-generated content
  // via `scrubSentryEvent` so chat / persona / emails never leave the device.
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
      options.beforeSend = (event, hint) async => scrubSentryEvent(event);
    },
    appRunner: () async {
      try {
        await dotenv.load(fileName: '.env');
        Env.assertValid();
        await Supabase.initialize(
          url: Env.supabaseUrl,
          anonKey: Env.supabaseAnonKey,
        );

        // Start app
        registerSingletons();

        // Wake the Render free-tier backend in parallel with the rest of
        // bootstrap so the first chat send doesn't pay the 30-60s cold-start
        // cost. Stored on AppLogic so bootstrap can sequence preloadAll behind it.
        appLogic.startWarmup();

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
        BlocProvider<AuthBloc>.value(value: GetIt.I<AuthBloc>()),
        BlocProvider<TripsBloc>.value(value: GetIt.I<TripsBloc>()),
        BlocProvider<TtsBloc>.value(value: GetIt.I<TtsBloc>()),
        BlocProvider<VoiceBloc>.value(value: GetIt.I<VoiceBloc>()),
        BlocProvider<BuddyBloc>.value(value: GetIt.I<BuddyBloc>()),
        BlocProvider<ArtifactsBloc>.value(value: GetIt.I<ArtifactsBloc>()),
        BlocProvider<CollectiblesBloc>.value(
          value: GetIt.I<CollectiblesBloc>(),
        ),
        BlocProvider<PreferencesBloc>.value(
          value: GetIt.I<PreferencesBloc>(),
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

/// Create singletons (logic and services) that can be shared across the app.
void registerSingletons() {
  // Top level app controller
  GetIt.I.registerLazySingleton<AppLogic>(() => AppLogic());
  // Destinations
  GetIt.I.registerLazySingleton<DestinationsLogic>(() => DestinationsLogic());
  // Timeline / Events
  GetIt.I.registerLazySingleton<TimelineLogic>(() => TimelineLogic());
  // Settings
  GetIt.I.registerLazySingleton<SettingsBloc>(() => SettingsBloc());
  // Destination photo gallery manifest (Supabase via backend)
  GetIt.I.registerLazySingleton<DestinationPhotosLogic>(() => DestinationPhotosLogic());
  // Localizations
  GetIt.I.registerLazySingleton<LocaleLogic>(() => LocaleLogic());
  // Home Widget Service (must register before CollectiblesBloc, which resolves
  // it via GetIt in its constructor default).
  GetIt.I.registerLazySingleton<NativeWidgetService>(() => NativeWidgetService());
  // Artifacts (curated Albanian catalog served by the backend)
  GetIt.I.registerLazySingleton<ArtifactsBloc>(() => ArtifactsBloc());
  // Collectibles (resolves NativeWidgetService and ArtifactsBloc lazily)
  GetIt.I.registerLazySingleton<CollectiblesBloc>(() => CollectiblesBloc());
  // Auth
  GetIt.I.registerLazySingleton<AuthBloc>(() => AuthBloc());
  // Buddy chat
  GetIt.I.registerLazySingleton<ChatService>(() => ChatService());
  GetIt.I.registerLazySingleton<ConversationsService>(
    () => ConversationsService(),
  );
  GetIt.I.registerLazySingleton<AttachmentService>(() => AttachmentService());
  GetIt.I.registerLazySingleton<BuddyBloc>(
    () => BuddyBloc(service: GetIt.I<ChatService>()),
  );
  GetIt.I.registerLazySingleton<VoiceBloc>(() => VoiceBloc());
  GetIt.I.registerLazySingleton<TtsBloc>(() => TtsBloc());
  // Preferences
  GetIt.I.registerLazySingleton<PreferencesService>(() => PreferencesService());
  GetIt.I.registerLazySingleton<PreferencesBloc>(
    () => PreferencesBloc(service: GetIt.I<PreferencesService>()),
  );
  // Users (sync hook into AuthLogic creates the local users row idempotently)
  GetIt.I.registerLazySingleton<UserService>(() => UserService());
  // Trips
  GetIt.I.registerLazySingleton<TripService>(() => TripService());
  GetIt.I.registerLazySingleton<TripsBloc>(
    () => TripsBloc(
      service: GetIt.I<TripService>(),
      tokenReader: () =>
          Supabase.instance.client.auth.currentSession?.accessToken,
      buddyBlocProvider: () => GetIt.I<BuddyBloc>(),
    ),
  );
  // Visit detection (foreground-only auto-completion of itinerary stops).
  // Eagerly registered so the consent sheet on TripDetailScreen can read
  // the persisted decision before the first frame.
  GetIt.I.registerLazySingleton<LocationService>(() => LocationService());
  GetIt.I.registerLazySingleton<AutoTrackPrefs>(() => AutoTrackPrefs());
}

/// Add syntax sugar for quickly accessing the main "logic" controllers in the app
/// We deliberately do not create shortcuts for services, to discourage their use directly in the view/widget layer.
AppLogic get appLogic => GetIt.I.get<AppLogic>();
DestinationsLogic get destinationsLogic => GetIt.I.get<DestinationsLogic>();
TimelineLogic get timelineLogic => GetIt.I.get<TimelineLogic>();
SettingsBloc get settingsBloc => GetIt.I.get<SettingsBloc>();
DestinationPhotosLogic get destinationPhotosLogic => GetIt.I.get<DestinationPhotosLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();
AuthBloc get authBloc => GetIt.I.get<AuthBloc>();
BuddyBloc get buddyBloc => GetIt.I.get<BuddyBloc>();
TripsBloc get tripsBloc => GetIt.I.get<TripsBloc>();
ArtifactsBloc get artifactsBloc => GetIt.I.get<ArtifactsBloc>();
CollectiblesBloc get collectiblesBloc => GetIt.I.get<CollectiblesBloc>();

/// Global helpers for readability
AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => DestinationsAppScaffold.style;
