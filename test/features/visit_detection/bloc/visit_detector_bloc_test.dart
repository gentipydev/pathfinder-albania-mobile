import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/domain/entities/trip_day.dart';
import 'package:travel_buddy/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/features/visit_detection/bloc/visit_detector_bloc.dart';
import 'package:travel_buddy/logic/auto_track_prefs.dart';
import 'package:travel_buddy/services/location_service.dart';

import '../../../helpers/mock_blocs.dart';

class _MockLocationService extends Mock implements LocationService {}

class _MockAutoTrackPrefs extends Mock implements AutoTrackPrefs {}

Trip _trip({String id = 't1'}) => Trip(
      id: id,
      title: 'Test',
      // No startDate → `_isInDateWindow` returns true permissively, so the
      // tests don't depend on the wall-clock running on a specific day.
      days: const [
        TripDay(id: 'd1', dayNumber: 1, stops: []),
      ],
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  setUpAll(() {
    registerTripsBlocFallbacks();
  });

  late MockTripsBloc trips;
  late _MockLocationService location;
  late _MockAutoTrackPrefs prefs;

  setUp(() {
    trips = MockTripsBloc();
    location = _MockLocationService();
    prefs = _MockAutoTrackPrefs();

    when(() => location.checkPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(() => location.isServiceEnabled()).thenAnswer((_) async => true);
    when(() => location.positions(
            distanceFilterMeters: any(named: 'distanceFilterMeters')))
        .thenAnswer((_) => const Stream<Position>.empty());
    when(() => prefs.decisionFor(any())).thenReturn(true);
  });

  VisitDetectorBloc buildDetector() => VisitDetectorBloc(
        tripsBloc: trips,
        locationService: location,
        autoTrackPrefs: prefs,
      );

  group('VisitDetectorBloc activation', () {
    test('happy path — trip already in TripsBloc state activates immediately',
        () async {
      whenListen(
        trips,
        const Stream<TripsState>.empty(),
        initialState: TripsState(trips: [_trip()]),
      );
      final bloc = buildDetector();
      addTearDown(bloc.close);

      bloc.add(const VisitDetectorActivated('t1'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const VisitDetectorState(lastAttemptedTripId: 't1'),
          const VisitDetectorState(isActive: true, lastAttemptedTripId: 't1'),
        ]),
      );
      verify(() => location.positions(
              distanceFilterMeters: any(named: 'distanceFilterMeters')))
          .called(1);
    });

    test(
        'cold-start race — activation parks when trip is missing, '
        'self-retries once the trip arrives in TripsBloc state', () async {
      final controller = StreamController<TripsState>.broadcast();
      addTearDown(controller.close);
      whenListen(
        trips,
        controller.stream,
        initialState: const TripsState(),
      );
      final bloc = buildDetector();
      addTearDown(bloc.close);

      bloc.add(const VisitDetectorActivated('t1'));
      // First pass parks: emits the lastAttemptedTripId-only state, no
      // position subscription.
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(lastAttemptedTripId: 't1')),
      );
      expect(bloc.state.isActive, isFalse);
      verifyNever(() => location.positions(
          distanceFilterMeters: any(named: 'distanceFilterMeters')));

      // Trip arrives. The watcher fires, self-dispatches another
      // VisitDetectorActivated, and the second pass completes activation.
      controller.add(TripsState(trips: [_trip()]));
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(
            isActive: true, lastAttemptedTripId: 't1')),
      );
      verify(() => location.positions(
              distanceFilterMeters: any(named: 'distanceFilterMeters')))
          .called(1);
    });

    test(
        'deactivate cancels the pending watcher — late trip arrival '
        'does not activate', () async {
      final controller = StreamController<TripsState>.broadcast();
      addTearDown(controller.close);
      whenListen(
        trips,
        controller.stream,
        initialState: const TripsState(),
      );
      final bloc = buildDetector();
      addTearDown(bloc.close);

      bloc.add(const VisitDetectorActivated('t1'));
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(lastAttemptedTripId: 't1')),
      );
      bloc.add(const VisitDetectorDeactivated());
      // Deactivate emits (isActive: false, lastAttemptedTripId: t1) — same
      // values, but the bloc re-emits because the in-flight handler runs
      // through emit() unconditionally. Just let the queue settle.
      await pumpEventQueue();

      controller.add(TripsState(trips: [_trip()]));
      await pumpEventQueue();

      expect(bloc.state.isActive, isFalse);
      verifyNever(() => location.positions(
          distanceFilterMeters: any(named: 'distanceFilterMeters')));
    });

    test('close cancels the pending watcher — emitting after close is a no-op',
        () async {
      final controller = StreamController<TripsState>.broadcast();
      addTearDown(controller.close);
      whenListen(
        trips,
        controller.stream,
        initialState: const TripsState(),
      );
      final bloc = buildDetector();

      bloc.add(const VisitDetectorActivated('t1'));
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(lastAttemptedTripId: 't1')),
      );

      await bloc.close();
      // Post-close emission must not crash and must not activate.
      controller.add(TripsState(trips: [_trip()]));
      await pumpEventQueue();

      verifyNever(() => location.positions(
          distanceFilterMeters: any(named: 'distanceFilterMeters')));
    });

    test(
        'prefs flipped off while waiting — late trip arrival re-enters '
        'and bails on the decisionFor guard', () async {
      final controller = StreamController<TripsState>.broadcast();
      addTearDown(controller.close);
      whenListen(
        trips,
        controller.stream,
        initialState: const TripsState(),
      );
      final bloc = buildDetector();
      addTearDown(bloc.close);

      bloc.add(const VisitDetectorActivated('t1'));
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(lastAttemptedTripId: 't1')),
      );

      // User toggles auto-tracking off via the menu before the trip loaded.
      when(() => prefs.decisionFor('t1')).thenReturn(false);

      controller.add(TripsState(trips: [_trip()]));
      await pumpEventQueue();

      expect(bloc.state.isActive, isFalse);
      verifyNever(() => location.positions(
          distanceFilterMeters: any(named: 'distanceFilterMeters')));
    });

    test(
        'superseded activation — a second activate cancels the first watcher; '
        'trip arrival activates exactly once', () async {
      final controller = StreamController<TripsState>.broadcast();
      addTearDown(controller.close);
      whenListen(
        trips,
        controller.stream,
        initialState: const TripsState(),
      );
      final bloc = buildDetector();
      addTearDown(bloc.close);

      bloc.add(const VisitDetectorActivated('t1'));
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(lastAttemptedTripId: 't1')),
      );
      // Second activate while still pending — supersedes the first watcher.
      bloc.add(const VisitDetectorActivated('t1'));
      await pumpEventQueue();

      controller.add(TripsState(trips: [_trip()]));
      await expectLater(
        bloc.stream,
        emits(const VisitDetectorState(
            isActive: true, lastAttemptedTripId: 't1')),
      );

      // Even though two activates were dispatched, the watcher fired once
      // (the first was cancelled), so the position stream was set up once.
      verify(() => location.positions(
              distanceFilterMeters: any(named: 'distanceFilterMeters')))
          .called(1);
    });
  });
}
