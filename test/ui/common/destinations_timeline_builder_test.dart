import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_buddy/logic/data/destination_type.dart';
import 'package:travel_buddy/logic/destinations_logic.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/ui/common/destinations_timeline_builder.dart';

void main() {
  setUpAll(() async {
    final getIt = GetIt.I;
    if (!getIt.isRegistered<LocaleLogic>()) {
      final locale = LocaleLogic();
      await locale.loadIfChanged(const Locale('en'));
      getIt.registerSingleton<LocaleLogic>(locale);
    }
    if (!getIt.isRegistered<DestinationsLogic>()) getIt.registerSingleton(DestinationsLogic()..init());
  });

  /// Pumps the builder and returns the order its entries are painted in, track by track.
  Future<List<DestinationType>> paintOrder(WidgetTester tester, List<DestinationType> selected) async {
    final order = <DestinationType>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 400,
            height: 100,
            child: DestinationsTimelineBuilder(
              crossAxisGap: 4,
              selectedDestinations: selected,
              timelineBuilder: (_, data, _) {
                order.add(data.type);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    return order;
  }

  testWidgets('longer ranges paint first, so shorter overlapping ones stay visible', (tester) async {
    expect(await paintOrder(tester, const []), const [
      // Track 1: Berat spans Apollonia and the Albanian Alps.
      DestinationType.berat, DestinationType.apollonia, DestinationType.albanianAlps,
      // Track 2: Theth starts inside Krujë's range.
      DestinationType.kruja, DestinationType.theth,
      // Track 3: Gjirokastër overlaps Butrint and spans Korçë.
      DestinationType.butrint, DestinationType.gjirokaster, DestinationType.korca,
    ]);
  });

  testWidgets('a selected destination paints last in its track', (tester) async {
    final order = await paintOrder(tester, const [DestinationType.berat]);
    expect(order.sublist(0, 3), const [DestinationType.apollonia, DestinationType.albanianAlps, DestinationType.berat]);
    expect(order.sublist(3), const [
      DestinationType.kruja,
      DestinationType.theth,
      DestinationType.butrint,
      DestinationType.gjirokaster,
      DestinationType.korca,
    ]);
  });
}
