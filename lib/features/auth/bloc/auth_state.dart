import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState extends Equatable {
  const AuthState({
    this.session,
    this.isAuthenticated = false,
    this.isSigningIn = false,
    this.isSigningOut = false,
    this.lastError,
  });

  final Session? session;
  final bool isAuthenticated;
  final bool isSigningIn;
  final bool isSigningOut;
  final String? lastError;

  User? get currentUser => session?.user;

  AuthState copyWith({
    Object? session = _sentinel,
    bool? isAuthenticated,
    bool? isSigningIn,
    bool? isSigningOut,
    Object? lastError = _sentinel,
  }) {
    return AuthState(
      session: identical(session, _sentinel)
          ? this.session
          : session as Session?,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSigningIn: isSigningIn ?? this.isSigningIn,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      lastError: identical(lastError, _sentinel)
          ? this.lastError
          : lastError as String?,
    );
  }

  @override
  List<Object?> get props =>
      [session, isAuthenticated, isSigningIn, isSigningOut, lastError];
}

const _sentinel = Object();
