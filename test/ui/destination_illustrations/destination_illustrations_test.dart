import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/berat_data.dart';
import 'package:pathfinder_albania/logic/data/destinations_data/gjirokaster_data.dart';
import 'package:pathfinder_albania/logic/locale_logic.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/animated_clouds.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_illustration_config.dart';
import 'package:pathfinder_albania/ui/destination_illustrations/common/destination_title_text.dart';

/// Phone-sized surface (393x852), so `context.heightPx`-based offsets match a real device.
Widget _phone(Widget child) => MediaQuery(
  data: const MediaQueryData(size: Size(393, 852), devicePixelRatio: 3),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

/// The details-page header illustration (bg layer, short mode), as `_TopIllustration` builds it.
Widget _headerBg(DestinationType type, {Key? key}) => _phone(
  Align(
    alignment: Alignment.topCenter,
    child: SizedBox(
      key: key,
      width: 393,
      height: 280,
      child: DestinationIllustration(
        type,
        config: DestinationIllustrationConfig.bg(enableAnims: false, shortMode: true),
      ),
    ),
  ),
);

void main() {
  setUpAll(() async {
    if (!GetIt.I.isRegistered<LocaleLogic>()) {
      final locale = LocaleLogic();
      await locale.loadIfChanged(const Locale('en'));
      GetIt.I.registerSingleton<LocaleLogic>(locale);
    }
  });

  testWidgets('an illustration piece seen before lays out at its real aspect ratio on its first frame', (
    tester,
  ) async {
    // Butrint's sun is tall (145x251) and offset by a fraction of its width, so a placeholder
    // aspect ratio of 1 visibly misplaces it and re-keys its Hero once the decode lands.
    final sunHero = find.byWidgetPredicate((w) => w is Hero && w.tag == '${DestinationType.butrint}-sun.png');

    // First appearance (e.g. Home): let the async decode finish so the shared cache is warm.
    await tester.runAsync(() async {
      await tester.pumpWidget(_headerBg(DestinationType.butrint, key: const ValueKey('first')));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(tester.getSize(sunHero).aspectRatio, closeTo(145 / 251, .01));

    // A fresh instance (e.g. the details page) must use the real ratio right away...
    await tester.pumpWidget(_headerBg(DestinationType.butrint, key: const ValueKey('second')));
    expect(tester.getSize(sunHero).aspectRatio, closeTo(145 / 251, .01));
    final heroElement = tester.element(sunHero);

    // ...and keep the same Hero element afterwards (a remount mid-flight cuts Hero flights short).
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.element(sunHero), same(heroElement));
  });

  testWidgets('outgoing clouds alternate sides, like incoming ones', (tester) async {
    Widget clouds(DestinationType type) => _phone(
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 393,
          height: 426,
          child: AnimatedClouds(destinationType: type, opacity: 1),
        ),
      ),
    );
    List<double> cloudLefts() => tester
        .widgetList<Positioned>(find.descendant(of: find.byType(AnimatedClouds), matching: find.byType(Positioned)))
        .map((p) => p.left!)
        .toList();

    await tester.pumpWidget(clouds(DestinationType.apollonia));
    await tester.pump(const Duration(seconds: 2));

    // Switch destination: the first 3 Positioned are the outgoing clouds, the next 3 the incoming ones.
    await tester.pumpWidget(clouds(DestinationType.kruja));
    final start = cloudLefts();
    await tester.pump(const Duration(milliseconds: 300));
    final later = cloudLefts();

    expect(start, hasLength(6));
    expect(later[0], greaterThan(start[0]), reason: 'outgoing cloud 0 should drift right');
    expect(later[1], lessThan(start[1]), reason: 'outgoing cloud 1 should drift left');
    expect(later[2], greaterThan(start[2]), reason: 'outgoing cloud 2 should drift right');
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('only titles too wide for a phone use the smaller title size', (tester) async {
    double titleSize() {
      final rich = tester.widget<RichText>(find.byType(RichText));
      return (rich.text as TextSpan).children!.first.style!.fontSize!;
    }

    await tester.pumpWidget(_phone(DestinationTitleText(BeratData(), enableHero: false)));
    expect(titleSize(), 64);

    await tester.pumpWidget(_phone(DestinationTitleText(GjirokasterData(), enableHero: false)));
    expect(titleSize(), 56);
  });
}
