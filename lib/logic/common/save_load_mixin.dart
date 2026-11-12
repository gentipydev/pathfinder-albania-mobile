import 'package:flutter/foundation.dart';
import 'package:pathfinder_albania/logic/common/json_prefs_file.dart';
import 'package:pathfinder_albania/logic/common/throttler.dart';

mixin ThrottledSaveLoadMixin {
  late final _file = JsonPrefsFile(fileName);
  final _throttle = Throttler(const Duration(seconds: 2));

  Future<void> load() async {
    final results = await _file.load();
    try {
      copyFromJson(results);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> save() async {
    if (!kIsWeb) debugPrint('Saving...');
    try {
      await _file.save(toJson());
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> scheduleSave() async => _throttle.call(save);

  /// Force any pending throttled save to run, then write current in-memory
  /// state once more so the call site can await durability. Called from
  /// `AppLifecycleListener` (onHide/onPause) so a quick background-then-kill
  /// cycle can't lose the user's last toggle.
  Future<void> flushPendingSave() async {
    _throttle.flush();
    await save();
  }

  /// Serialization
  String get fileName;
  Map<String, dynamic> toJson();
  void copyFromJson(Map<String, dynamic> value);
}
