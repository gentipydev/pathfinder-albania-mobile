import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_bloc.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_error_mapper.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_event.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_state.dart';
import 'package:pathfinder_albania/ui/common/empty_state.dart';
import 'package:pathfinder_albania/ui/common/error_state.dart';
import 'package:pathfinder_albania/agent/ui/screens/my_trips/my_trips_screen.dart';

import '../../helpers/mock_blocs.dart';
import '../../../helpers/widget_test_harness.dart';

Trip _trip({
  String id = 't1',
  String title = '3 Days in Tirana',
  String? staticMapUrl,
}) =>
    Trip(
      id: id,
      title: title,
      days: const [],
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      staticMapUrl: staticMapUrl,
    );

void main() {
  setUpAll(registerTripsBlocFallbacks);

  group('MyTripsScreen body branches', () {
    testWidgets('empty + no error renders EmptyState', (tester) async {
      final bloc = MockTripsBloc();
      whenListen(
        bloc,
        Stream<TripsState>.empty(),
        initialState: const TripsState(),
      );
      await pumpLocalizedWidget(
        tester,
        BlocProvider<TripsBloc>.value(
          value: bloc,
          child: const MyTripsScreen(),
        ),
      );
      // initState dispatches LoadAllRequested via a postFrameCallback.
      await tester.pump();
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
    });

    testWidgets('empty + lastError renders ErrorState + retry dispatches LoadAllRequested',
        (tester) async {
      final bloc = MockTripsBloc();
      whenListen(
        bloc,
        Stream<TripsState>.empty(),
        initialState: const TripsState(lastError: TripsErrorKey.generic),
      );
      await pumpLocalizedWidget(
        tester,
        BlocProvider<TripsBloc>.value(
          value: bloc,
          child: const MyTripsScreen(),
        ),
      );
      await tester.pump();
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);

      // Tap the retry text-button — verify the bloc receives LoadAllRequested.
      final retry = find.byType(TextButton);
      expect(retry, findsOneWidget);
      await tester.tap(retry);
      await tester.pump();
      verify(() => bloc.add(any(that: isA<LoadAllRequested>()))).called(
        greaterThanOrEqualTo(1),
      );
    });
  });

  group('MyTripsScreen header counter', () {
    testWidgets('renders "N / 3" for the current trips length', (tester) async {
      final bloc = MockTripsBloc();
      whenListen(
        bloc,
        Stream<TripsState>.empty(),
        initialState: TripsState(
          trips: [_trip(id: 'a'), _trip(id: 'b')],
        ),
      );
      await pumpLocalizedWidget(
        tester,
        BlocProvider<TripsBloc>.value(
          value: bloc,
          child: const MyTripsScreen(),
        ),
      );
      await tester.pump();
      // Counter is rendered as plain text. AppLocalizations resolves
      // `myTripsCounter(count, max)` to "{count} / {max}".
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('renders "0 / 3" even on empty list', (tester) async {
      final bloc = MockTripsBloc();
      whenListen(
        bloc,
        Stream<TripsState>.empty(),
        initialState: const TripsState(),
      );
      await pumpLocalizedWidget(
        tester,
        BlocProvider<TripsBloc>.value(
          value: bloc,
          child: const MyTripsScreen(),
        ),
      );
      await tester.pump();
      expect(find.text('0 / 3'), findsOneWidget);
    });
  });

  group('MyTripsScreen trip row layout', () {
    // NOTE: a widget test that mounts a trip WITH staticMapUrl is omitted
    // intentionally. `CachedNetworkImage` initializes `flutter_cache_manager`
    // synchronously, which calls `path_provider` and sqflite via platform
    // channels — none of which are stubbed in the widget-test harness here.
    // Stubbing both channels just to mount one widget would add far more
    // coupling than the test buys us. The banner branch is covered by:
    //   - the compact-row fallback test below (proves the `if (url == null)`
    //     branch on the other side of the conditional),
    //   - manual visual verification on `flutter run`.

    testWidgets('trip without staticMapUrl falls back to compact icon row',
        (tester) async {
      final bloc = MockTripsBloc();
      whenListen(
        bloc,
        Stream<TripsState>.empty(),
        initialState: TripsState(
          trips: [_trip(id: 'compact', title: 'Compact Trip')],
        ),
      );
      await pumpLocalizedWidget(
        tester,
        BlocProvider<TripsBloc>.value(
          value: bloc,
          child: const MyTripsScreen(),
        ),
      );
      await tester.pump();
      // Fallback row shows the legacy map_outlined icon inside the rounded
      // square — the banner branch would instead render an AspectRatio.
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byType(AspectRatio), findsNothing);
      expect(find.text('Compact Trip'), findsOneWidget);
    });
  });

  group('displayTripTitle', () {
    test('strips "N Days in " prefix from LLM-baked titles', () {
      expect(displayTripTitle('3 Days in Tirana'), 'Tirana');
      expect(displayTripTitle('1 day in Berat'), 'Berat');
      expect(displayTripTitle('10 Days in Albanian Riviera'), 'Albanian Riviera');
    });

    test('strips "N-Day " hyphenated prefix', () {
      expect(displayTripTitle('5-Day Albanian Riviera'), 'Albanian Riviera');
      expect(displayTripTitle('3-day Tirana plan'), 'Tirana plan');
    });

    test('leaves destination-only titles untouched', () {
      expect(displayTripTitle('Albanian Riviera Escape'), 'Albanian Riviera Escape');
      expect(displayTripTitle('Tirana'), 'Tirana');
      expect(displayTripTitle('Discovering Tirana'), 'Discovering Tirana');
    });

    test('returns raw value when stripping would yield empty', () {
      // Defensive: never collapse a card line to "". If somebody saved a
      // pathological title like "3 days in" with no destination, fall
      // back to the original so the user still sees something.
      expect(displayTripTitle(''), '');
      expect(displayTripTitle('3 days in '), '3 days in ');
      expect(displayTripTitle('3 days in'), '3 days in');
    });
  });
}
