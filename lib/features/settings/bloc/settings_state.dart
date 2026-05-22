import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.hasCompletedOnboarding = false,
    this.hasDismissedSearchMessage = false,
    this.isSearchPanelOpen = true,
    this.currentLocale,
    this.prevDestinationIndex,
  });

  final bool hasCompletedOnboarding;
  final bool hasDismissedSearchMessage;
  final bool isSearchPanelOpen;
  final String? currentLocale;
  final int? prevDestinationIndex;

  SettingsState copyWith({
    bool? hasCompletedOnboarding,
    bool? hasDismissedSearchMessage,
    bool? isSearchPanelOpen,
    Object? currentLocale = _sentinel,
    Object? prevDestinationIndex = _sentinel,
  }) {
    return SettingsState(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasDismissedSearchMessage:
          hasDismissedSearchMessage ?? this.hasDismissedSearchMessage,
      isSearchPanelOpen: isSearchPanelOpen ?? this.isSearchPanelOpen,
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
        hasDismissedSearchMessage,
        isSearchPanelOpen,
        currentLocale,
        prevDestinationIndex,
      ];
}

const _sentinel = Object();
