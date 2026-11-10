import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

/// Read the current Supabase session and subscribe to `onAuthStateChange`.
/// Idempotent — `app_logic.bootstrap()` dispatches this; calling again is a
/// no-op.
class AuthInitialized extends AuthEvent {
  const AuthInitialized();
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Internal: Supabase auth-state stream pushes session deltas into the bloc
/// via this event. Underscore-prefixed by convention; emitted from inside
/// the bloc, never from outside.
class AuthSessionChanged extends AuthEvent {
  const AuthSessionChanged(this.session);
  final Session? session;

  @override
  List<Object?> get props => [session];
}
