import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_buddy/l10n/app_localizations.dart';
import 'package:travel_buddy/logic/locale_logic.dart';

/// Pumps [child] inside a `MaterialApp` configured with the app's
/// localization delegates so screens that call `$strings.<key>` resolve.
/// Also registers a `LocaleLogic` populated with the English `AppLocalizations`
/// — necessary because production reads `$strings.foo` synchronously via
/// `GetIt.I<LocaleLogic>().strings` from non-context code (e.g. EmptyState).
///
/// Wrap [child] in a `BlocProvider`/`MultiBlocProvider` yourself when the
/// widget under test reads from a bloc.
Future<void> pumpLocalizedWidget(
  WidgetTester tester,
  Widget child, {
  Size? surfaceSize,
}) async {
  await _ensureLocaleLogicRegistered();
  if (surfaceSize != null) {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

Future<void> _ensureLocaleLogicRegistered() async {
  if (GetIt.I.isRegistered<LocaleLogic>()) return;
  final logic = LocaleLogic();
  // Populate `_strings` so production code paths that go through
  // `$strings.<key>` synchronously (e.g. `ErrorState`'s retry label, the
  // trips_error_mapper resolver) find a real `AppLocalizations` instance.
  await logic.loadIfChanged(const Locale('en'));
  GetIt.I.registerSingleton<LocaleLogic>(logic);
}
