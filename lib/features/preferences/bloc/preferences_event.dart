import 'package:equatable/equatable.dart';
import 'package:travel_buddy/logic/preferences/user_preferences.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the current user's preferences. Handler self-guards on missing
/// access token, so a cold-start dispatch before the session is restored
/// is a clean no-op rather than a 401-into-lastError.
class PreferencesLoadRequested extends PreferencesEvent {
  const PreferencesLoadRequested();
}

class PreferencesSaveRequested extends PreferencesEvent {
  const PreferencesSaveRequested(this.updated);

  final UserPreferences updated;

  @override
  List<Object?> get props => [updated];
}

class PreferencesGeneratePersonaRequested extends PreferencesEvent {
  const PreferencesGeneratePersonaRequested();
}

class PreferencesCleared extends PreferencesEvent {
  const PreferencesCleared();
}
