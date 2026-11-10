import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.hasCompletedOnboarding = false,
    this.currentLocale,
    this.prevDestinationIndex,
  });

  final bool hasCompletedOnboarding;
  final String? currentLocale;
  final int? prevDestinationIndex;

  SettingsState copyWith({
    bool? hasCompletedOnboarding,
    Object? currentLocale = _sentinel,
    Object? prevDestinationIndex = _sentinel,
  }) {
    return SettingsState(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      currentLocale: identical(currentLocale, _sentinel)
          ? this.currentLocale
          : currentLocale as String?,
      prevDestinationIndex: identical(prevDestinationIndex, _sentinel)
          ? this.prevDestinationIndex
          : prevDestinationIndex as int?,
    );
  }

  @override
  List<Object?> get props => [
        hasCompletedOnboarding,
        currentLocale,
        prevDestinationIndex,
      ];
}

const _sentinel = Object();
