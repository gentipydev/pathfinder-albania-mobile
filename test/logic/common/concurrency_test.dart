import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/logic/common/concurrency.dart';

void main() {
  group('mapBounded', () {
    test('returns a result for every item', () async {
      final out = await mapBounded<int, int>(
        [1, 2, 3, 4, 5],
        (n) async => n * 10,
        concurrency: 2,
      );
      expect(out, {1: 10, 2: 20, 3: 30, 4: 40, 5: 50});
    });

    test('never exceeds the concurrency cap', () async {
      var inFlight = 0;
      var maxInFlight = 0;
      final completers = <Completer<void>>[];

      Future<int> task(int n) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        final c = Completer<void>();
        completers.add(c);
        // Release on the next microtask turn so several tasks can pile up
        // if the pool let them — the cap is what should hold them back.
        scheduleMicrotask(() => c.complete());
        await c.future;
        inFlight--;
        return n;
      }

      await mapBounded<int, int>(List.generate(20, (i) => i), task,
          concurrency: 4);

      expect(maxInFlight, lessThanOrEqualTo(4));
      expect(completers.length, 20); // every item ran exactly once
    });

    test('empty input yields an empty map and starts no work', () async {
      var ran = false;
      final out = await mapBounded<int, int>([], (n) async {
        ran = true;
        return n;
      });
      expect(out, isEmpty);
      expect(ran, isFalse);
    });

    test('clamps concurrency below 1 to a single worker', () async {
      var inFlight = 0;
      var maxInFlight = 0;
      Future<int> task(int n) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(Duration.zero);
        inFlight--;
        return n;
      }

      await mapBounded<int, int>([1, 2, 3], task, concurrency: 0);
      expect(maxInFlight, 1);
    });
  });
}
