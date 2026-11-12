import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pathfinder_albania/logic/data/timeline_data.dart';
import 'package:pathfinder_albania/logic/destinations_logic.dart';
import 'package:pathfinder_albania/logic/locale_logic.dart';
import 'package:pathfinder_albania/logic/timeline_logic.dart';

void main() {
  for (final lang in const ['en', 'sq']) {
    test('$lang: one card per year, with every event and "story begins" marker', () async {
      final getIt = GetIt.I;
      if (!getIt.isRegistered<LocaleLogic>()) getIt.registerSingleton(LocaleLogic());
      if (!getIt.isRegistered<DestinationsLogic>()) getIt.registerSingleton(DestinationsLogic());
      await getIt<LocaleLogic>().loadIfChanged(Locale(lang));
      final destinations = getIt<DestinationsLogic>()..init();
      final timeline = TimelineLogic()..init();

      final years = [for (final e in timeline.events) e.year];
      expect(years.toSet(), hasLength(years.length), reason: 'two cards share a year');
      expect(years.every((y) => y >= destinations.timelineStartYear && y <= destinations.timelineEndYear), isTrue);

      final texts = [for (final e in timeline.events) ...e.description.split('\n\n')];
      expect(texts, everyElement(isNotEmpty));
      expect(texts, hasLength(GlobalEventsData().globalEvents.length + destinations.all.length));
    });
  }

  test('every timeline event has an Albanian translation', () {
    Map<String, dynamic> read(String lang) =>
        jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;
    final en = read('en'), sq = read('sq');
    final keys = en.keys.where((k) => k.startsWith('timelineEvent')).toList();
    expect(keys, hasLength(100));
    for (final key in keys) {
      expect(sq[key], isA<String>().having((s) => s.trim(), 'text', isNotEmpty), reason: key);
    }
  });
}
