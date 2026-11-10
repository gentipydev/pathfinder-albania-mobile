import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/features/settings/bloc/settings_bloc.dart';
import 'package:travel_buddy/features/settings/bloc/settings_event.dart';
import 'package:travel_buddy/features/settings/bloc/settings_state.dart';
import 'package:travel_buddy/logic/destinations_logic.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/logic/timeline_logic.dart';

class _MockLocaleLogic extends Mock implements LocaleLogic {}

class _MockDestinationsLogic extends Mock implements DestinationsLogic {}

class _MockTimelineLogic extends Mock implements TimelineLogic {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
  });

  late _MockLocaleLogic localeLogic;
  late _MockDestinationsLogic destinationsLogic;
  late _MockTimelineLogic timelineLogic;
  late List<String> calls;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    localeLogic = _MockLocaleLogic();
    destinationsLogic = _MockDestinationsLogic();
    timelineLogic = _MockTimelineLogic();
    calls = <String>[];

    when(() => localeLogic.loadIfChanged(any())).thenAnswer((_) async {
      calls.add('locale.loadIfChanged');
    });
    when(() => destinationsLogic.init()).thenAnswer((_) {
      calls.add('destinations.init');
    });
    when(() => timelineLogic.init()).thenAnswer((_) {
      calls.add('timeline.init');
    });
  });

  SettingsBloc build() => SettingsBloc(
        localeLogicProvider: () => localeLogic,
        destinationsLogicProvider: () => destinationsLogic,
        timelineLogicProvider: () => timelineLogic,
      );

  test('initial state defaults', () {
    final bloc = build();
    expect(bloc.state, const SettingsState());
    expect(bloc.state.hasCompletedOnboarding, isFalse);
    expect(bloc.state.currentLocale, isNull);
    expect(bloc.state.prevDestinationIndex, isNull);
  });

  test('load with empty JSON keeps the defaults', () async {
    SharedPreferences.setMockInitialValues({'settings.dat': '{}'});
    final bloc = build();
    await bloc.loadFromPersistence();
    expect(bloc.state, const SettingsState());
  });

  test(
      'load with populated JSON honors legacy lastDestinationIndex key and '
      'ignores retired search keys', () async {
    SharedPreferences.setMockInitialValues({
      'settings.dat': jsonEncode({
        'hasCompletedOnboarding': true,
        // Retired keys written by older builds; loading must ignore them.
        'hasDismissedSearchMessage': true,
        'isSearchPanelOpen': true,
        'currentLocale': 'sq',
        'lastDestinationIndex': 3,
      }),
    });
    final bloc = build();
    await bloc.loadFromPersistence();
    expect(
      bloc.state,
      const SettingsState(
        hasCompletedOnboarding: true,
        currentLocale: 'sq',
        prevDestinationIndex: 3,
      ),
    );
  });

  test('load with malformed types falls back to defaults', () async {
    SharedPreferences.setMockInitialValues({
      'settings.dat': jsonEncode({
        'hasCompletedOnboarding': 'oops',
        'currentLocale': 42,
        'lastDestinationIndex': 'three',
      }),
    });
    final bloc = build();
    await bloc.loadFromPersistence();
    expect(bloc.state.hasCompletedOnboarding, isFalse);
    expect(bloc.state.currentLocale, isNull);
    expect(bloc.state.prevDestinationIndex, isNull);
  });

  blocTest<SettingsBloc, SettingsState>(
    'SettingsOnboardingCompletedToggled emits',
    build: build,
    act: (b) => b.add(const SettingsOnboardingCompletedToggled(true)),
    expect: () => [
      const SettingsState(hasCompletedOnboarding: true),
    ],
  );

  test('SettingsLocaleChangeRequested cascades in order, then emits', () async {
    final bloc = build();
    final emitted = <String?>[];
    final sub = bloc.stream.listen((s) => emitted.add(s.currentLocale));

    bloc.add(const SettingsLocaleChangeRequested(Locale('sq')));
    await bloc.stream.firstWhere((s) => s.currentLocale == 'sq');
    await sub.cancel();

    expect(
      calls,
      ['locale.loadIfChanged', 'destinations.init', 'timeline.init'],
    );
    expect(emitted, ['sq']);
    verify(() => localeLogic.loadIfChanged(const Locale('sq'))).called(1);
  });

  blocTest<SettingsBloc, SettingsState>(
    'SettingsLocaleChangeRequested aborts on loadIfChanged failure '
    '(no emit, no cascade past step 1)',
    setUp: () {
      when(() => localeLogic.loadIfChanged(any()))
          .thenAnswer((_) async => throw Exception('boom'));
    },
    build: build,
    act: (b) => b.add(const SettingsLocaleChangeRequested(Locale('sq'))),
    errors: () => [isA<Exception>()],
    expect: () => const <SettingsState>[],
    verify: (_) {
      verifyNever(() => destinationsLogic.init());
      verifyNever(() => timelineLogic.init());
    },
  );

  test('SettingsLocaleHydrated emits without cascade', () async {
    final bloc = build();
    bloc.add(const SettingsLocaleHydrated('sq'));
    await bloc.stream.firstWhere((s) => s.currentLocale == 'sq');

    verifyNever(() => localeLogic.loadIfChanged(any()));
    verifyNever(() => destinationsLogic.init());
    verifyNever(() => timelineLogic.init());
  });

  test('SettingsLocaleHydrated dedupes when code unchanged', () async {
    SharedPreferences.setMockInitialValues({
      'settings.dat': jsonEncode({'currentLocale': 'en'}),
    });
    final bloc = build();
    await bloc.loadFromPersistence();
    final emitted = <SettingsState>[];
    final sub = bloc.stream.listen(emitted.add);

    bloc.add(const SettingsLocaleHydrated('en'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(emitted, isEmpty);
  });

  blocTest<SettingsBloc, SettingsState>(
    'SettingsPrevDestinationIndexChanged emits set + clear',
    build: build,
    act: (b) async {
      b.add(const SettingsPrevDestinationIndexChanged(5));
      await b.stream.firstWhere((s) => s.prevDestinationIndex == 5);
      b.add(const SettingsPrevDestinationIndexChanged(null));
    },
    expect: () => [
      const SettingsState(prevDestinationIndex: 5),
      const SettingsState(),
    ],
  );

  test('SettingsFlushPendingSaveRequested completes the Completer', () async {
    final bloc = build();
    final c = Completer<void>();
    bloc.add(SettingsFlushPendingSaveRequested(completer: c));
    await c.future.timeout(const Duration(seconds: 2));
    expect(c.isCompleted, isTrue);
  });

  test(
      'JSON round-trip preserves legacy lastDestinationIndex key on disk',
      () async {
    final bloc = build();
    bloc.add(const SettingsOnboardingCompletedToggled(true));
    bloc.add(const SettingsPrevDestinationIndexChanged(7));
    bloc.add(const SettingsLocaleHydrated('sq'));
    await bloc.stream.firstWhere(
      (s) =>
          s.hasCompletedOnboarding && s.prevDestinationIndex == 7 &&
          s.currentLocale == 'sq',
    );
    final c = Completer<void>();
    bloc.add(SettingsFlushPendingSaveRequested(completer: c));
    await c.future;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('settings.dat');
    expect(raw, isNotNull);
    final parsed = jsonDecode(raw!) as Map<String, dynamic>;
    expect(parsed['hasCompletedOnboarding'], isTrue);
    expect(parsed['lastDestinationIndex'], 7);
    expect(parsed['currentLocale'], 'sq');
    expect(parsed.containsKey('prevDestinationIndex'), isFalse,
        reason: 'must not introduce a new key');
    expect(parsed.containsKey('hasDismissedSearchMessage'), isFalse);
    expect(parsed.containsKey('isSearchPanelOpen'), isFalse);
  });

  testWidgets(
    'BlocSelector over MaterialApp.router rebuilds with new locale on cascade',
    (tester) async {
      // Run the whole test under tester.runAsync so the bloc's
      // `ThrottledSaveLoadMixin` timer (2 s) lives in the real-clock zone
      // and doesn't trip the fake-async invariant check at teardown.
      // The cascade order is verified by the earlier unit test; here we
      // verify the BlocSelector → MaterialApp.locale rebuild path.
      await tester.runAsync(() async {
        final bloc = build();
        final locales = <Locale?>[];
        await tester.pumpWidget(
          BlocProvider<SettingsBloc>.value(
            value: bloc,
            child: BlocSelector<SettingsBloc, SettingsState, String?>(
              selector: (s) => s.currentLocale,
              builder: (context, locale) {
                final picked = locale == null ? null : Locale(locale);
                locales.add(picked);
                return MaterialApp(
                  locale: picked,
                  home: const SizedBox.shrink(),
                );
              },
            ),
          ),
        );

        expect(locales.last, isNull);

        bloc.add(const SettingsLocaleHydrated('sq'));
        await bloc.stream.firstWhere((s) => s.currentLocale == 'sq');
        await tester.pump();

        expect(locales.last, const Locale('sq'));

        // Drain the throttler's real-clock timer so the test framework's
        // invariant check at teardown sees no pending timers.
        await bloc.flushPendingSave();
        await bloc.close();
      });
    },
  );
}
