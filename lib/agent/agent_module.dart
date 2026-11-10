import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/config/env.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_event.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/agent/features/preferences/bloc/preferences_bloc.dart';
import 'package:travel_buddy/agent/features/preferences/bloc/preferences_event.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/agent/features/tts/bloc/tts_bloc.dart';
import 'package:travel_buddy/agent/features/voice/bloc/voice_bloc.dart';
import 'package:travel_buddy/agent/logic/auto_track_prefs.dart';
import 'package:travel_buddy/agent/logic/buddy/attachment_service.dart';
import 'package:travel_buddy/agent/logic/buddy/chat_service.dart';
import 'package:travel_buddy/agent/logic/buddy/conversations_service.dart';
import 'package:travel_buddy/logic/common/dio_client.dart';
import 'package:travel_buddy/agent/logic/preferences/preferences_service.dart';
import 'package:travel_buddy/agent/services/location_service.dart';
import 'package:travel_buddy/agent/services/trip_service.dart';
import 'package:travel_buddy/agent/services/user_service.dart';
import 'package:travel_buddy/agent/ui/app_shell.dart';
import 'package:travel_buddy/agent/ui/screens/auth/auth_screen.dart';
import 'package:travel_buddy/agent/ui/screens/conversations/conversations_screen.dart';
import 'package:travel_buddy/agent/ui/screens/my_trips/trip_detail_screen.dart';
import 'package:travel_buddy/agent/ui/screens/preferences/preferences_screen.dart';

/// Everything the agent side (Buddy chat, My Trips, Profile, sign-in) plugs
/// into the app. The composition root (`main.dart`, `router.dart`,
/// `app_logic.dart`) calls into this only when `APP_MODE=full`; in showcase
/// mode none of it runs and Supabase is never initialized.
class AgentModule {
  AgentModule._();

  /// Supabase backs auth, trips and chat attachments. Must run before
  /// [registerSingletons] because `AuthBloc` reads the client on creation.
  static Future<void> initServices() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }

  static void registerSingletons() {
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
    // Visit detection (foreground-only auto-completion of itinerary stops),
    // used by TripDetailScreen.
    GetIt.I.registerLazySingleton<LocationService>(() => LocationService());
    GetIt.I.registerLazySingleton<AutoTrackPrefs>(() => AutoTrackPrefs());

    // Lets the shared HTTP client recover from an expired access token.
    accessTokenRefresher = () => GetIt.I<AuthBloc>().refreshAccessToken();
  }

  static List<BlocProvider> blocProviders() => [
    BlocProvider<AuthBloc>.value(value: GetIt.I<AuthBloc>()),
    BlocProvider<TripsBloc>.value(value: GetIt.I<TripsBloc>()),
    BlocProvider<TtsBloc>.value(value: GetIt.I<TtsBloc>()),
    BlocProvider<VoiceBloc>.value(value: GetIt.I<VoiceBloc>()),
    BlocProvider<BuddyBloc>.value(value: GetIt.I<BuddyBloc>()),
    BlocProvider<PreferencesBloc>.value(value: GetIt.I<PreferencesBloc>()),
  ];

  /// Runs during `AppLogic.bootstrap`, after settings are loaded.
  static void onBootstrap() {
    // Auth (must run after Supabase.initialize in initServices)
    authBloc.add(const AuthInitialized());

    // Preferences: fire-and-forget. Handler self-guards on missing access
    // token so a cold-start dispatch before the session is restored is a
    // no-op; AuthBloc dispatches a follow-up load in `_ensureSyncedAndLoad`
    // for the freshly-signed-in case.
    GetIt.I<PreferencesBloc>().add(const PreferencesLoadRequested());
  }

  static bool get isAuthenticated => authBloc.state.isAuthenticated;

  /// The `/home` page in full mode: the Explore / Buddy / My Trips / Profile
  /// bottom nav, with the showcase home as its first tab.
  static Widget shell() => const AppShell();

  static AppRoute get authRoute => AppRoute(ScreenPaths.auth, (_) => const AuthScreen());

  /// Agent pages pushed on top of `/home`.
  static List<AppRoute> get homeRoutes => [
    AppRoute('conversations', (_) => const ConversationsScreen()),
    AppRoute('preferences', (_) => PreferencesScreen()),
    AppRoute(
      'trip/:tripId',
      (s) => TripDetailScreen(tripId: s.pathParameters['tripId']!),
    ),
  ];
}

AuthBloc get authBloc => GetIt.I.get<AuthBloc>();
