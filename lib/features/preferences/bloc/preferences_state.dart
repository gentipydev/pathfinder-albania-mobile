import 'package:equatable/equatable.dart';
import 'package:travel_buddy/logic/preferences/user_preferences.dart';

class PreferencesState extends Equatable {
  const PreferencesState({
    this.current,
    this.isLoading = false,
    this.isSaving = false,
    this.isGeneratingPersona = false,
    this.lastError,
  });

  final UserPreferences? current;
  final bool isLoading;
  final bool isSaving;
  final bool isGeneratingPersona;
  final String? lastError;

  PreferencesState copyWith({
    Object? current = _sentinel,
    bool? isLoading,
    bool? isSaving,
    bool? isGeneratingPersona,
    Object? lastError = _sentinel,
  }) {
    return PreferencesState(
      current: identical(current, _sentinel)
          ? this.current
          : current as UserPreferences?,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isGeneratingPersona: isGeneratingPersona ?? this.isGeneratingPersona,
      lastError: identical(lastError, _sentinel)
          ? this.lastError
          : lastError as String?,
    );
  }

  @override
  List<Object?> get props =>
      [current, isLoading, isSaving, isGeneratingPersona, lastError];
}

const _sentinel = Object();
