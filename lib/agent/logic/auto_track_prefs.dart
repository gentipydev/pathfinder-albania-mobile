import 'package:pathfinder_albania/logic/common/save_load_mixin.dart';

/// Per-trip "auto-track my visits" opt-in. Stored as a `{tripId: bool}`
/// map in SharedPreferences via [ThrottledSaveLoadMixin] (2-second
/// debounce, lifecycle-flushed on app pause). A missing entry means
/// "no decision yet" — the trip-detail screen shows the consent sheet
/// on first open during the trip's date window. An explicit `false`
/// suppresses the sheet for that trip.
class AutoTrackPrefs with ThrottledSaveLoadMixin {
  @override
  String get fileName => 'auto_track_prefs';

  final Map<String, bool> _enabled = <String, bool>{};

  /// Active subscription target for [VisitDetectorBloc].
  bool isEnabled(String tripId) => _enabled[tripId] ?? false;

  /// Distinguishes "no decision" (null → show consent sheet) from an
  /// explicit user choice (true/false → respect it).
  bool? decisionFor(String tripId) => _enabled[tripId];

  Future<void> setEnabled(String tripId, bool enabled) {
    _enabled[tripId] = enabled;
    return scheduleSave();
  }

  /// Wipe on account deletion / sign-out (called from AuthBloc reset).
  Future<void> clear() {
    _enabled.clear();
    return scheduleSave();
  }

  @override
  Map<String, dynamic> toJson() => {'enabled': Map<String, bool>.from(_enabled)};

  @override
  void copyFromJson(Map<String, dynamic> value) {
    final raw = value['enabled'];
    if (raw is! Map) return;
    _enabled.clear();
    raw.forEach((k, v) {
      if (k is String && v is bool) _enabled[k] = v;
    });
  }
}
