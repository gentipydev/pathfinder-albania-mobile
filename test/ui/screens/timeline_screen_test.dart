import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pathfinder_albania/logic/destinations_logic.dart';
import 'package:pathfinder_albania/logic/locale_logic.dart';
import 'package:pathfinder_albania/logic/timeline_logic.dart';
import 'package:pathfinder_albania/ui/common/destinations_timeline_builder.dart';
import 'package:pathfinder_albania/ui/screens/timeline/timeline_screen.dart';

import '../../helpers/widget_test_harness.dart';

const _phone = Size(440, 956);

/// The scrubber's white "visible area" box.
final _scrubberBox = find.byWidgetPredicate((w) {
  final decoration = w is DecoratedBox ? w.decoration : null;
  return decoration is BoxDecoration &&
      decoration.border is Border &&
      (decoration.border as Border).top.color == Colors.white;
});

Future<void> _registerTimelineLogic() async {
  final getIt = GetIt.I;
  if (!getIt.isRegistered<LocaleLogic>()) {
    final locale = LocaleLogic();
    await locale.loadIfChanged(const Locale('en'));
    getIt.registerSingleton<LocaleLogic>(locale);
  }
  if (!getIt.isRegistered<DestinationsLogic>()) getIt.registerSingleton(DestinationsLogic()..init());
  if (!getIt.isRegistered<TimelineLogic>()) getIt.registerSingleton(TimelineLogic()..init());
}

Future<void> _pumpTimeline(WidgetTester tester) async {
  await _registerTimelineLogic();
  // No destination: the entry point used by the Home timeline button.
  await pumpLocalizedWidget(tester, const TimelineScreen(type: null), surfaceSize: _phone);
  await tester.pump(const Duration(seconds: 1));
}

/// A new era label starts its fade-in with a zero-length timer; one more frame lets it fire before teardown.
Future<void> _flushEraAnimation(WidgetTester tester) => tester.pump(const Duration(seconds: 1));

void main() {
  testWidgets('era label follows the scroll when opened without a destination', (tester) async {
    await _pumpTimeline(tester);
    // The timeline opens at 1500 BCE.
    expect(find.text('Prehistory'), findsOneWidget);
    // From the first frame the box shows only the visible span, not the whole mini timeline.
    final panelWidth = tester.getSize(find.byType(DestinationsTimelineBuilder).last).width;
    expect(tester.getSize(_scrubberBox).width, lessThan(panelWidth / 2));

    // Scroll the main timeline into antiquity.
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -1500));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Prehistory'), findsNothing);
    expect(find.text('Antiquity'), findsOneWidget);
    await _flushEraAnimation(tester);
  });

  testWidgets('tapping the scrubber glides the timeline to the tapped year', (tester) async {
    await _pumpTimeline(tester);

    // The scrubber's mini timeline is the second DestinationsTimelineBuilder; its right edge is 2100.
    final miniTimeline = tester.getRect(find.byType(DestinationsTimelineBuilder).last);
    await tester.tapAt(Offset(miniTimeline.right - 1, miniTimeline.center.dy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Modern Era'), findsOneWidget);
    await _flushEraAnimation(tester);
  });
}
