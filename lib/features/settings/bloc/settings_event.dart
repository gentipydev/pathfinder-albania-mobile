import 'dart:async';
import 'dart:ui' show Locale;

import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => const [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested({this.completer});

  final Completer<void>? completer;

  @override
  List<Object?> get props => [completer];
}

class SettingsOnboardingCompletedToggled extends SettingsEvent {
  const SettingsOnboardingCompletedToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

/// User-triggered locale change. Cascades, in order:
///   1. localeLogic.loadIfChanged(locale)         — re-loads `$strings`
///   2. destinationsLogic.init()                  — rebuilds destination data
///   3. timelineLogic.init()                      — rebuilds timeline events
///   4. emit(state.copyWith(currentLocale: code)) — drives MaterialApp.router
///      rebuild via the BlocSelector at the root.
///
/// Cascade-then-emit avoids the brief frame where MaterialApp would rebuild with a new locale
/// code while `$strings` is still old.
class SettingsLocaleChangeRequested extends SettingsEvent {
  const SettingsLocaleChangeRequested(this.locale);

  final Locale locale;

  @override
  List<Object?> get props => [locale];
}

/// Bootstrap-only writeback dispatched by `app_logic.bootstrap()` after
/// `localeLogic.load()` resolves the persisted locale (else English). NO cascade —
/// `bootstrap` calls `destinationsLogic.init()` and `timelineLogic.init()`
/// directly afterwards.
class SettingsLocaleHydrated extends SettingsEvent {
  const SettingsLocaleHydrated(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class SettingsPrevDestinationIndexChanged extends SettingsEvent {
  const SettingsPrevDestinationIndexChanged(this.index);

  final int? index;

  @override
  List<Object?> get props => [index];
}

class SettingsFlushPendingSaveRequested extends SettingsEvent {
  const SettingsFlushPendingSaveRequested({this.completer});

  final Completer<void>? completer;

  @override
  List<Object?> get props => [completer];
}
