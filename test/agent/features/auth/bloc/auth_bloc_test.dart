import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:supabase_flutter/supabase_flutter.dart' as sb show AuthState;
import 'package:pathfinder_albania/agent/features/auth/bloc/auth_bloc.dart';
import 'package:pathfinder_albania/agent/features/auth/bloc/auth_event.dart';
import 'package:pathfinder_albania/agent/features/auth/bloc/auth_state.dart';
import 'package:pathfinder_albania/agent/services/user_service.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUserService extends Mock implements UserService {}

class _FakeSession extends Fake implements Session {
  _FakeSession({required this.token});

  @override
  String get accessToken => token;
  final String token;

  @override
  String? get refreshToken => null;
}

class _FakeAuthResponse extends Fake implements AuthResponse {
  _FakeAuthResponse({this.session});

  @override
  final Session? session;

  @override
  User? get user => session?.user;
}

void main() {
  late _MockSupabaseClient client;
  late _MockGoTrueClient auth;
  late _MockUserService userService;
  late StreamController<sb.AuthState> authStream;

  AuthBloc build() => AuthBloc(
        supabaseClient: client,
        userServiceProvider: () => userService,
      );

  setUp(() {
    client = _MockSupabaseClient();
    auth = _MockGoTrueClient();
    userService = _MockUserService();
    authStream = StreamController<sb.AuthState>.broadcast();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.onAuthStateChange).thenAnswer((_) => authStream.stream);
    when(() => auth.currentSession).thenReturn(null);
    when(() => userService.sync(bearerToken: any(named: 'bearerToken')))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await authStream.close();
  });

  group('AuthInitialized', () {
    blocTest<AuthBloc, AuthState>(
      'with no current session emits unauthed and subscribes to stream',
      build: build,
      act: (b) => b.add(const AuthInitialized()),
      expect: () => const [AuthState()],
      verify: (_) => verify(() => auth.onAuthStateChange).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'with current session emits authed',
      build: () {
        final session = _FakeSession(token: 'tok');
        when(() => auth.currentSession).thenReturn(session);
        return build();
      },
      act: (b) => b.add(const AuthInitialized()),
      verify: (b) {
        expect(b.state.isAuthenticated, isTrue);
        expect(b.state.session?.accessToken, 'tok');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'is idempotent — second AuthInitialized is a no-op',
      build: build,
      act: (b) async {
        b.add(const AuthInitialized());
        b.add(const AuthInitialized());
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      verify: (_) => verify(() => auth.onAuthStateChange).called(1),
    );
  });

  group('AuthSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'success emits isSigningIn true then false with session set',
      build: () {
        when(() => auth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer(
                (_) async => _FakeAuthResponse(session: _FakeSession(token: 't')));
        return build();
      },
      act: (b) => b.add(const AuthSignInRequested(
        email: 'a@b.co',
        password: 'pw',
      )),
      verify: (b) {
        expect(b.state.isSigningIn, isFalse);
        expect(b.state.isAuthenticated, isTrue);
        expect(b.state.lastError, isNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'AuthException sets lastError and clears isSigningIn',
      build: () {
        when(() => auth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const AuthException('bad creds'));
        return build();
      },
      act: (b) => b.add(const AuthSignInRequested(
        email: 'x',
        password: 'y',
      )),
      verify: (b) {
        expect(b.state.isSigningIn, isFalse);
        expect(b.state.isAuthenticated, isFalse);
        expect(b.state.lastError, 'bad creds');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'is droppable — concurrent sign-in attempts coalesce',
      build: () {
        final completer = Completer<AuthResponse>();
        when(() => auth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) => completer.future);
        return build();
      },
      act: (b) async {
        b.add(const AuthSignInRequested(email: 'a', password: 'p'));
        b.add(const AuthSignInRequested(email: 'a', password: 'p'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      verify: (_) => verify(() => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).called(1),
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits isSigningOut transitions and clears session',
      build: () {
        when(() => auth.signOut()).thenAnswer((_) async {});
        return build();
      },
      seed: () => AuthState(
        session: _FakeSession(token: 'tok'),
        isAuthenticated: true,
      ),
      act: (b) => b.add(const AuthSignOutRequested()),
      verify: (b) {
        expect(b.state.isAuthenticated, isFalse);
        expect(b.state.session, isNull);
        expect(b.state.isSigningOut, isFalse);
      },
    );
  });

  group('refreshAccessToken (method)', () {
    test('returns the new token on success', () async {
      final fresh = _FakeSession(token: 'new');
      // Real Supabase updates `currentSession` before `refreshSession()`
      // resolves; the mock mirrors that so the assertion exercises the
      // post-refresh `currentSession` read.
      when(() => auth.refreshSession()).thenAnswer((_) async {
        when(() => auth.currentSession).thenReturn(fresh);
        return _FakeAuthResponse(session: fresh);
      });
      final bloc = build();
      expect(await bloc.refreshAccessToken(), 'new');
      await bloc.close();
    });

    test('returns null when refresh fails and no session is left', () async {
      when(() => auth.refreshSession())
          .thenThrow(const AuthException('expired'));
      // `currentSession` stays null (set by the outer setUp) — refresh truly
      // failed and there is no fallback session to return.
      final bloc = build();
      expect(await bloc.refreshAccessToken(), isNull);
      await bloc.close();
    });

    test(
      'recovers the fresh token when refresh raced Supabase auto-refresh '
      '(refreshSession returns null-session but currentSession is fresh)',
      () async {
        // Models the boot-time race: Supabase's internal auto-refresh is
        // already in flight when the interceptor calls refreshSession; the
        // SDK resolves our explicit call with an empty AuthResponse while
        // simultaneously landing the fresh session on `currentSession`. The
        // previous implementation read `res.session?.accessToken` and
        // returned null here, leaving the 401-retry path dead.
        when(() => auth.refreshSession()).thenAnswer((_) async {
          when(() => auth.currentSession)
              .thenReturn(_FakeSession(token: 'fresh-from-autorefresh'));
          return _FakeAuthResponse(session: null);
        });
        final bloc = build();
        expect(await bloc.refreshAccessToken(), 'fresh-from-autorefresh');
        await bloc.close();
      },
    );

    test(
      'recovers fresh token even when refreshSession throws if a concurrent '
      'refresh has already populated currentSession',
      () async {
        when(() => auth.refreshSession()).thenAnswer((_) async {
          when(() => auth.currentSession)
              .thenReturn(_FakeSession(token: 'fresh-after-race-loss'));
          throw const AuthException('another refresh in flight');
        });
        final bloc = build();
        expect(await bloc.refreshAccessToken(), 'fresh-after-race-loss');
        await bloc.close();
      },
    );
  });
}
