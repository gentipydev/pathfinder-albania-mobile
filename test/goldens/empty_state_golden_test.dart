import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathfinder_albania/ui/common/empty_state.dart';

import '../helpers/widget_test_harness.dart';

void main() {
  testWidgets('EmptyState renders icon + title + subtitle', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const EmptyState(
        icon: Icons.luggage_outlined,
        title: 'No saved trips yet',
        subtitle: 'Plan one with Buddy.',
      ),
      surfaceSize: const Size(400, 600),
    );
    await expectLater(
      find.byType(EmptyState),
      matchesGoldenFile('empty_state_default.png'),
    );
  });
}
