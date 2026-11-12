import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_bloc.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_error_mapper.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_event.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_state.dart';
import 'package:pathfinder_albania/agent/services/trip_service.dart';

class _MockTripService extends Mock implements TripService {}

class _MockBuddyBloc extends Mock implements BuddyBloc {}

Trip _trip({String id = 't1'}) => Trip(
      id: id,
      title: 'Trip $id',
      summary: null,
      startDate: null,
      days: const [],
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      staticMapUrl: null,
      routes: const [],
    );

void main() {
  late _MockTripService service;
  late _MockBuddyBloc buddy;
  String? token = 'tok';

  TripsBloc build() => TripsBloc(
        service: service,
        tokenReader: () => token,
        buddyBlocProvider: () => buddy,
      );

  setUpAll(() {
    registerFallbackValue(const LoadAllRequested());
  });

  setUp(() {
    service = _MockTripService();
    buddy = _MockBuddyBloc();
    token = 'tok';
  });

  group('Pagination — LoadAllRequested', () {
    blocTest<TripsBloc, TripsState>(
      'first page with non-null nextCursor sets hasMore=true and stores cursor',
      build: () {
        when(() => service.listTrips(
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => TripsPage(
              items: [_trip(id: 'a'), _trip(id: 'b')],
              nextCursor: 'CURSOR_1',
            ));
        return build();
      },
      act: (b) => b.add(const LoadAllRequested()),
      expect: () => [
        const TripsState(isLoading: true),
        TripsState(
          trips: [_trip(id: 'a'), _trip(id: 'b')],
          nextCursor: 'CURSOR_1',
          hasMore: true,
        ),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'last page with null nextCursor flips hasMore=false',
      build: () {
        when(() => service.listTrips(
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async =>
                TripsPage(items: [_trip(id: 'a')], nextCursor: null));
        return build();
      },
      act: (b) => b.add(const LoadAllRequested()),
      expect: () => [
        const TripsState(isLoading: true),
        TripsState(trips: [_trip(id: 'a')], hasMore: false),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'error surfaces a TripsErrorKey constant (regression: was silently swallowed)',
      build: () {
        when(() => service.listTrips(
              bearerToken: any(named: 'bearerToken'),
            )).thenThrow(TripServiceException(500, 'boom'));
        return build();
      },
      act: (b) => b.add(const LoadAllRequested()),
      expect: () => [
        const TripsState(isLoading: true),
        const TripsState(lastError: TripsErrorKey.generic),
      ],
    );
  });

  group('Pagination — TripsLoadMoreRequested', () {
    blocTest<TripsBloc, TripsState>(
      'no-ops when hasMore is false',
      build: build,
      seed: () => TripsState(
        trips: [_trip(id: 'a')],
        hasMore: false,
      ),
      act: (b) => b.add(const TripsLoadMoreRequested()),
      expect: () => const <TripsState>[],
      verify: (_) {
        verifyNever(() => service.listTrips(
              bearerToken: any(named: 'bearerToken'),
              cursor: any(named: 'cursor'),
            ));
      },
    );

    blocTest<TripsBloc, TripsState>(
      'no-ops when isLoadingMore is true (re-entrancy guard)',
      build: build,
      seed: () => TripsState(
        trips: [_trip(id: 'a')],
        hasMore: true,
        isLoadingMore: true,
        nextCursor: 'CUR',
      ),
      act: (b) => b.add(const TripsLoadMoreRequested()),
      expect: () => const <TripsState>[],
      verify: (_) {
        verifyNever(() => service.listTrips(
              bearerToken: any(named: 'bearerToken'),
              cursor: any(named: 'cursor'),
            ));
      },
    );

    blocTest<TripsBloc, TripsState>(
      'happy path appends items, updates cursor, toggles isLoadingMore',
      build: () {
        when(() => service.listTrips(
              bearerToken: any(named: 'bearerToken'),
              cursor: 'CUR1',
            )).thenAnswer((_) async => TripsPage(
              items: [_trip(id: 'c'), _trip(id: 'd')],
              nextCursor: null,
            ));
        return build();
      },
      seed: () => TripsState(
        trips: [_trip(id: 'a'), _trip(id: 'b')],
        hasMore: true,
        nextCursor: 'CUR1',
      ),
      act: (b) => b.add(const TripsLoadMoreRequested()),
      expect: () => [
        TripsState(
          trips: [_trip(id: 'a'), _trip(id: 'b')],
          hasMore: true,
          isLoadingMore: true,
          nextCursor: 'CUR1',
        ),
        TripsState(
          trips: [
            _trip(id: 'a'),
            _trip(id: 'b'),
            _trip(id: 'c'),
            _trip(id: 'd'),
          ],
          hasMore: false,
          isLoadingMore: false,
          nextCursor: null,
        ),
      ],
    );
  });
}
