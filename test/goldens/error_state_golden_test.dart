import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/ui/common/error_state.dart';

import '../helpers/widget_test_harness.dart';

void main() {
  testWidgets('ErrorState with onRetry renders the action button', (tester) async {
    await pumpLocalizedWidget(
      tester,
      ErrorState(
        message: 'Failed to load.',
        onRetry: () {},
      ),
      surfaceSize: const Size(400, 600),
    );
    await expectLater(
      find.byType(ErrorState),
      matchesGoldenFile('error_state_with_retry.png'),
    );
  });

  testWidgets('ErrorState without onRetry omits the button', (tester) async {
    await pumpLocalizedWidget(
      tester,
      const ErrorState(message: 'Failed to load.'),
      surfaceSize: const Size(400, 600),
    );
    await expectLater(
      find.byType(ErrorState),
      matchesGoldenFile('error_state_no_retry.png'),
    );
  });
}
