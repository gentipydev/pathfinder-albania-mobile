import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Bootstraps fonts before golden tests run so snapshots use the real
/// Raleway/Cinzel families instead of Ahem fallback. Applies to every test
/// in this directory (flutter_test auto-discovers this file).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  await testMain();
}
