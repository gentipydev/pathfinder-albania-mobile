// Simple class wrapping HapticFeedback to make testing a bit simpler.

import 'package:pathfinder_albania/common_libs.dart';

class AppHaptics {
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  static Future<void> selectionClick() => HapticFeedback.selectionClick();
}
