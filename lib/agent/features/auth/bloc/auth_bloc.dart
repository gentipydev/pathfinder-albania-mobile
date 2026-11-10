import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:supabase_flutter/supabase_flutter.dart' as sb show AuthState;
import 'package:travel_buddy/agent/features/auth/bloc/auth_event.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_state.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/agent/features/preferences/bloc/preferences_bloc.dart';
import 'package:travel_buddy/agent/features/preferences/bloc/preferences_event.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/agent/services/user_service.dart';
import 'package:travel_buddy/utils/dlog.dart';

/// Reactive auth state for the app. Replaces the legacy `AuthLogic`.
///
/// Sign-in / sign-out are explicit events; `refreshAccessToken` stays as a
/// method (deviating from "events only") because callers — notably
/// `BuddyLogic` mid-SSE — need the awaited token back, not a state stream
/// notification.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    SupabaseClient? supabaseClient,
    UserService Function()? userServiceProvider,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _userServiceProvider = userServiceProvider ??
           (() => GetIt.I<UserService>()),
       super(const AuthState()) {
    on<AuthInitialized>(_onInitialized, transformer: droppable());
    on<AuthSignInRequested>(_onSignIn, transformer: droppable());
    on<AuthSignOutRequested>(_onSignOut, transformer: droppable());
    on<AuthSessionChanged>(_onSessionChanged, transformer: sequential());
  }

  final SupabaseClient _supabase;
  final UserService Function() _userServiceProvider;

  StreamSubscription<sb.AuthState>? _sub;
  bool _initialized = false;

  Future<void> _onInitialized(
    AuthInitialized e,
    Emitter<AuthState> emit,
  ) async {
    if (_initialized) return;
    _initialized = true;
    final current = _supabase.auth.currentSession;
    emit(state.copyWith(
      session: current,
      isAuthenticated: current != null,
    ));
    if (current != null) {
      unawaited(_ensureSyncedAndLoad());
    }
    _sub = _supabase.auth.onAuthStateChange.listen((event) {
      add(AuthSessionChanged(event.session));
    });
  }

  Future<void> _onSignIn(
    AuthSignInRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSigningIn: true, lastError: null));
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: e.email,
        password: e.password,
      );
      // Sync state synchronously — the router redirect on the next frame
      // reads `state.isAuthenticated` and must see the authed value before
      // the auth stream's async tick lands.
      emit(state.copyWith(
        session: res.session,
        isAuthenticated: res.session != null,
        isSigningIn: false,
      ));
      if (res.session != null) {
        unawaited(_ensureSyncedAndLoad());
      }
    } on AuthException catch (err) {
      emit(state.copyWith(isSigningIn: false, lastError: err.message));
    } catch (err) {
      emit(state.copyWith(isSigningIn: false, lastError: '$err'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSigningOut: true));
    try {
      await _supabase.auth.signOut();
      emit(state.copyWith(
        session: null,
        isAuthenticated: false,
        isSigningOut: false,
      ));
      _onLoggedOut();
    } catch (err) {
      emit(state.copyWith(isSigningOut: false, lastError: '$err'));
    }
  }

  void _onSessionChanged(
    AuthSessionChanged e,
    Emitter<AuthState> emit,
  ) {
    final hadSession = state.session != null;
    final hasSession = e.session != null;
    emit(state.copyWith(
      session: e.session,
      isAuthenticated: hasSession,
    ));
    if (hasSession && !hadSession) {
      unawaited(_ensureSyncedAndLoad());
    } else if (!hasSession && hadSession) {
      _onLoggedOut();
    }
  }

  // ---- side effects ----

  Future<void> _ensureSyncedAndLoad() async {
    try {
      await _userServiceProvider().sync(bearerToken: accessToken);
    } catch (e, st) {
      dlog(
        'users/me/sync failed',
        error: e,
        stackTrace: st,
        name: 'auth.sync',
      );
    }
    if (GetIt.I.isRegistered<TripsBloc>()) {
      GetIt.I<TripsBloc>().add(const LoadAllRequested());
    }
    if (GetIt.I.isRegistered<PreferencesBloc>()) {
      GetIt.I<PreferencesBloc>().add(const PreferencesLoadRequested());
    }
  }

  void _onLoggedOut() {
    if (GetIt.I.isRegistered<BuddyBloc>()) {
      GetIt.I<BuddyBloc>().add(const BuddyConversationCleared());
    }
    if (GetIt.I.isRegistered<TripsBloc>()) {
      GetIt.I<TripsBloc>().add(const TripCleared());
    }
    if (GetIt.I.isRegistered<PreferencesBloc>()) {
      GetIt.I<PreferencesBloc>().add(const PreferencesCleared());
    }
  }

  // ---- methods (deliberate exception to events-only) ----

  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  User? get currentUser => _supabase.auth.currentUser;

  /// Refresh the Supabase access token. Returns whatever access token the
  /// Supabase client holds *after* the refresh attempt — which recovers the
  /// case where our explicit `refreshSession()` raced Supabase's own
  /// internal auto-refresh (the SDK's refresh lock can return an
  /// `AuthResponse(session: null)` or throw on the loser of the race even
  /// though a fresh session has already landed on `currentSession`).
  ///
  /// Returns null only when there is no usable session at all (refresh
  /// genuinely failed and `currentSession` is empty). Used by `BuddyLogic`
  /// to retry an SSE stream after a 401, and by `AuthRefreshInterceptor`
  /// for the equivalent retry on plain HTTP calls.
  Future<String?> refreshAccessToken() async {
    try {
      await _supabase.auth.refreshSession();
    } on AuthException {
      // Lost the race to a concurrent refresh, or the refresh truly failed —
      // either way fall through to `currentSession`, which carries the
      // freshest token the client knows about (possibly null on real failure).
    }
    return _supabase.auth.currentSession?.accessToken;
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
