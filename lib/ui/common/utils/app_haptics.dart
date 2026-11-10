// Simple class wrapping HapticFeedback to make testing a bit simpler.

import 'package:travel_buddy/common_libs.dart';

class AppHaptics {
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  static Future<void> selectionClick() => HapticFeedback.selectionClick();
}
