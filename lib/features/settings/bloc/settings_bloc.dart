import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_buddy/features/settings/bloc/settings_event.dart';
import 'package:travel_buddy/features/settings/bloc/settings_state.dart';
import 'package:travel_buddy/logic/common/save_load_mixin.dart';
import 'package:travel_buddy/logic/destinations_logic.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/logic/timeline_logic.dart';

/// Persistent app-settings state — onboarding flag, locale, last-viewed
/// destination index, and a couple of legacy persisted flags. Replaces the
/// legacy `SettingsLogic`.
///
/// Persists to SharedPreferences via `ThrottledSaveLoadMixin`
/// (2-second debounce). The `'settings.dat'` filename and JSON keys
/// (including the legacy `'lastDestinationIndex'`) are preserved verbatim
/// so existing user data continues to load.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState>
    with ThrottledSaveLoadMixin {
  SettingsBloc({
    LocaleLogic Function()? localeLogicProvider,
    DestinationsLogic Function()? destinationsLogicProvider,
    TimelineLogic Function()? timelineLogicProvider,
  })  : _localeLogicProvider =
            localeLogicProvider ?? (() => GetIt.I<LocaleLogic>()),
        _destinationsLogicProvider =
            destinationsLogicProvider ?? (() => GetIt.I<DestinationsLogic>()),
        _timelineLogicProvider =
            timelineLogicProvider ?? (() => GetIt.I<TimelineLogic>()),
        super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad, transformer: droppable());
    on<SettingsOnboardingCompletedToggled>(
      _onOnboardingToggled,
      transformer: sequential(),
    );
    on<SettingsSearchMessageDismissed>(
      _onSearchMessageDismissed,
      transformer: sequential(),
    );
    on<SettingsSearchPanelToggled>(
      _onSearchPanelToggled,
      transformer: sequential(),
    );
    on<SettingsLocaleChangeRequested>(
      _onLocaleChange,
      transformer: sequential(),
    );
    on<SettingsLocaleHydrated>(
      _onLocaleHydrated,
      transformer: sequential(),
    );
    on<SettingsPrevDestinationIndexChanged>(
      _onPrevDestinationIndexChanged,
      transformer: sequential(),
    );
    on<SettingsFlushPendingSaveRequested>(
      _onFlush,
      transformer: sequential(),
    );
  }

  final LocaleLogic Function() _localeLogicProvider;
  final DestinationsLogic Function() _destinationsLogicProvider;
  final TimelineLogic Function() _timelineLogicProvider;

  // Stash from `copyFromJson` (called synchronously from the mixin's
  // `load()`); consumed inside `_onLoad` to feed the emit.
  Map<String, dynamic>? _pendingLoad;

  // ---- ThrottledSaveLoadMixin overrides ----

  @override
  String get fileName => 'settings.dat';

  @override
  Map<String, dynamic> toJson() => {
        'hasCompletedOnboarding': state.hasCompletedOnboarding,
        'hasDismissedSearchMessage': state.hasDismissedSearchMessage,
        'currentLocale': state.currentLocale,
        'isSearchPanelOpen': state.isSearchPanelOpen,
        // Legacy JSON key — do NOT rename. Existing user data uses this.
        'lastDestinationIndex': state.prevDestinationIndex,
      };

  @override
  void copyFromJson(Map<String, dynamic> value) {
    _pendingLoad = value;
  }

  // ---- public convenience methods ----

  /// Bootstrap convenience: dispatches the load event and awaits it via a
  /// `Completer`. Mirrors `CollectiblesBloc.loadFromPersistence`.
  Future<void> loadFromPersistence() {
    final c = Completer<void>();
    add(SettingsLoadRequested(completer: c));
    return c.future;
  }

  /// Lifecycle convenience: matches the call site in `app_logic.dart`'s
  /// `_flushPendingSaves` so a backgrounded-then-killed app doesn't drop
  /// the user's last toggle.
  Future<void> flushPendingSaveAwaitable() {
    final c = Completer<void>();
    add(SettingsFlushPendingSaveRequested(completer: c));
    return c.future;
  }

  // ---- handlers ----

  Future<void> _onLoad(
    SettingsLoadRequested e,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await load();
      final loaded = _pendingLoad ?? const <String, dynamic>{};
      _pendingLoad = null;
      emit(
        state.copyWith(
          hasCompletedOnboarding: loaded['hasCompletedOnboarding'] is bool
              ? loaded['hasCompletedOnboarding'] as bool
              : false,
          hasDismissedSearchMessage:
              loaded['hasDismissedSearchMessage'] is bool
                  ? loaded['hasDismissedSearchMessage'] as bool
                  : false,
          // Legacy quirk preserved: `SettingsLogic.copyFromJson` defaults
          // missing-key to FALSE even though the field initializer is TRUE,
          // so existing user data hydrates identically.
          isSearchPanelOpen: loaded['isSearchPanelOpen'] is bool
              ? loaded['isSearchPanelOpen'] as bool
              : false,
          currentLocale: loaded['currentLocale'] is String
              ? loaded['currentLocale'] as String
              : null,
          prevDestinationIndex: loaded['lastDestinationIndex'] is int
              ? loaded['lastDestinationIndex'] as int
              : null,
        ),
      );
    } finally {
      e.completer?.complete();
    }
  }

  Future<void> _onOnboardingToggled(
    SettingsOnboardingCompletedToggled e,
    Emitter<SettingsState> emit,
  ) async {
    if (state.hasCompletedOnboarding == e.value) return;
    emit(state.copyWith(hasCompletedOnboarding: e.value));
    await scheduleSave();
  }

  Future<void> _onSearchMessageDismissed(
    SettingsSearchMessageDismissed e,
    Emitter<SettingsState> emit,
  ) async {
    if (state.hasDismissedSearchMessage) return;
    emit(state.copyWith(hasDismissedSearchMessage: true));
    await scheduleSave();
  }

  Future<void> _onSearchPanelToggled(
    SettingsSearchPanelToggled e,
    Emitter<SettingsState> emit,
  ) async {
    if (state.isSearchPanelOpen == e.value) return;
    emit(state.copyWith(isSearchPanelOpen: e.value));
    await scheduleSave();
  }

  /// Cascade-then-emit. Order is load-bearing: emitting first would let the
  /// `MaterialApp.router` `BlocSelector` rebuild with the new locale code
  /// while `$strings` (cached in `LocaleLogic`) is still old.
  Future<void> _onLocaleChange(
    SettingsLocaleChangeRequested e,
    Emitter<SettingsState> emit,
  ) async {
    await _localeLogicProvider().loadIfChanged(e.locale);
    _destinationsLogicProvider().init();
    _timelineLogicProvider().init();
    emit(state.copyWith(currentLocale: e.locale.languageCode));
    await scheduleSave();
  }

  Future<void> _onLocaleHydrated(
    SettingsLocaleHydrated e,
    Emitter<SettingsState> emit,
  ) async {
    if (state.currentLocale == e.code) return;
    emit(state.copyWith(currentLocale: e.code));
    await scheduleSave();
  }

  Future<void> _onPrevDestinationIndexChanged(
    SettingsPrevDestinationIndexChanged e,
    Emitter<SettingsState> emit,
  ) async {
    if (state.prevDestinationIndex == e.index) return;
    emit(state.copyWith(prevDestinationIndex: e.index));
    await scheduleSave();
  }

  Future<void> _onFlush(
    SettingsFlushPendingSaveRequested e,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await flushPendingSave();
    } finally {
      e.completer?.complete();
    }
  }
}
