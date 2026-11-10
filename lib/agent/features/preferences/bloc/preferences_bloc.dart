import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/agent/features/preferences/bloc/preferences_event.dart';
import 'package:travel_buddy/agent/features/preferences/bloc/preferences_state.dart';
import 'package:travel_buddy/agent/logic/preferences/preferences_service.dart';

/// Reactive user-preferences state. Replaces the legacy `PreferencesLogic`.
///
/// Today the bloc is dispatched into from `app_logic.bootstrap()` (cold
/// start) and `AuthBloc` (login load + logout clear). A future buddy
/// payload composer will read `state.current` to seed chat context.
class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc({
    PreferencesService? service,
    String? Function()? tokenReader,
  })  : _service = service ?? GetIt.I<PreferencesService>(),
        _tokenReader = tokenReader ??
            (() => Supabase.instance.client.auth.currentSession?.accessToken),
        super(const PreferencesState()) {
    on<PreferencesLoadRequested>(_onLoad, transformer: droppable());
    on<PreferencesSaveRequested>(_onSave, transformer: droppable());
    on<PreferencesGeneratePersonaRequested>(
      _onGeneratePersona,
      transformer: droppable(),
    );
    on<PreferencesCleared>(_onCleared, transformer: droppable());
  }

  final PreferencesService _service;
  final String? Function() _tokenReader;

  Future<void> _onLoad(
    PreferencesLoadRequested e,
    Emitter<PreferencesState> emit,
  ) async {
    final token = _tokenReader();
    if (token == null || token.isEmpty) return;
    emit(state.copyWith(isLoading: true, lastError: null));
    try {
      final loaded = await _service.getMine(bearerToken: token);
      emit(state.copyWith(current: loaded, isLoading: false));
    } catch (err) {
      emit(state.copyWith(isLoading: false, lastError: '$err'));
    }
  }

  Future<void> _onSave(
    PreferencesSaveRequested e,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, lastError: null));
    try {
      await _service.save(e.updated, bearerToken: _tokenReader());
      emit(state.copyWith(current: e.updated, isSaving: false));
    } catch (err) {
      emit(state.copyWith(isSaving: false, lastError: '$err'));
    }
  }

  Future<void> _onGeneratePersona(
    PreferencesGeneratePersonaRequested e,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(isGeneratingPersona: true, lastError: null));
    try {
      final persona =
          await _service.generatePersona(bearerToken: _tokenReader());
      final c = state.current;
      if (c != null) {
        emit(state.copyWith(
          current: c.copyWith(travelPersona: persona),
          isGeneratingPersona: false,
        ));
      } else {
        emit(state.copyWith(isGeneratingPersona: false));
      }
    } catch (err) {
      emit(state.copyWith(isGeneratingPersona: false, lastError: '$err'));
    }
  }

  void _onCleared(
    PreferencesCleared e,
    Emitter<PreferencesState> emit,
  ) {
    emit(const PreferencesState());
  }
}
