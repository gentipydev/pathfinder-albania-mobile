import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_buddy/agent/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';
import 'package:travel_buddy/agent/domain/entities/trip_day.dart';
import 'package:travel_buddy/agent/domain/entities/trip_stop.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_error_mapper.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/agent/services/trip_service.dart';

class _MockTripService extends Mock implements TripService {}

class _MockBuddyBloc extends Mock implements BuddyBloc {}

class _FakeBuddyEvent extends Fake implements BuddyEvent {}

Trip _trip({
  String id = 't1',
  String title = 'Albania',
  String? summary,
  DateTime? startDate,
  List<TripDay> days = const [],
}) {
  return Trip(
    id: id,
    title: title,
    summary: summary,
    startDate: startDate,
    days: days,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

TripDay _day({
  String id = 'd1',
  int dayNumber = 1,
  String? title,
  String? baseCity,
  List<TripStop> stops = const [],
}) {
  return TripDay(
    id: id,
    dayNumber: dayNumber,
    title: title,
    baseCity: baseCity,
    stops: stops,
  );
}

TripStop _stop({
  String id = 's1',
  int sortOrder = 0,
  String name = 'Berat castle',
  StopKind kind = StopKind.sight,
  String? arrivalTime,
  String? endTime,
  int? durationMinutes,
}) {
  return TripStop(
    id: id,
    sortOrder: sortOrder,
    name: name,
    kind: kind,
    arrivalTime: arrivalTime,
    endTime: endTime,
    durationMinutes: durationMinutes,
  );
}

const _token = 'tok-1';

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);
    registerFallbackValue(_FakeBuddyEvent());
  });

  late _MockTripService service;
  late _MockBuddyBloc buddy;
  TripsBloc build() => TripsBloc(
        service: service,
        tokenReader: () => _token,
        buddyBlocProvider: () => buddy,
      );
  TripsBloc buildNoToken() => TripsBloc(
        service: service,
        tokenReader: () => null,
        buddyBlocProvider: () => buddy,
      );

  // Outer-scope capture map for the StopMoveToDayRequested tests below —
  // populated by the `when(...).thenAnswer((inv) => ...)` stub when the
  // bloc invokes `moveStop`. Cleared on each setUp so neighbouring tests
  // don't share state.
  final moveCallArgs = <String, Object?>{};

  setUp(() {
    service = _MockTripService();
    buddy = _MockBuddyBloc();
    when(() => buddy.add(any())).thenReturn(null);
    moveCallArgs.clear();
  });

  group('LoadAllRequested', () {
    blocTest<TripsBloc, TripsState>(
      'fetches and emits the list, toggling isLoading',
      build: () {
        when(() => service.listTrips(bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async =>
                TripsPage(items: [_trip()], nextCursor: null));
        return build();
      },
      act: (b) => b.add(const LoadAllRequested()),
      expect: () => [
        const TripsState(isLoading: true),
        TripsState(trips: [_trip()], hasMore: false),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'on error keeps last list, clears isLoading, and surfaces an error key',
      build: () {
        when(() => service.listTrips(bearerToken: any(named: 'bearerToken')))
            .thenThrow(TripServiceException(500, 'oops'));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 'old')]),
      act: (b) => b.add(const LoadAllRequested()),
      expect: () => [
        TripsState(trips: [_trip(id: 'old')], isLoading: true),
        TripsState(
          trips: [_trip(id: 'old')],
          isLoading: false,
          lastError: TripsErrorKey.generic,
        ),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'with no token, clears trips and does not call service',
      build: buildNoToken,
      seed: () => TripsState(trips: [_trip()]),
      act: (b) => b.add(const LoadAllRequested()),
      expect: () => [const TripsState()],
      verify: (_) {
        verifyNever(
            () => service.listTrips(bearerToken: any(named: 'bearerToken')));
      },
    );
  });

  group('TripCleared / TripMerged', () {
    blocTest<TripsBloc, TripsState>(
      'TripCleared empties trips and lastError',
      build: build,
      seed: () => TripsState(trips: [_trip()], lastError: 'x'),
      act: (b) => b.add(const TripCleared()),
      expect: () => const [TripsState()],
    );

    blocTest<TripsBloc, TripsState>(
      'TripMerged appends a new trip',
      build: build,
      act: (b) => b.add(TripMerged(_trip(id: 'fresh'))),
      expect: () => [
        TripsState(trips: [_trip(id: 'fresh')]),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'TripMerged replaces an existing trip by id',
      build: build,
      seed: () => TripsState(trips: [_trip(id: 't1', title: 'old')]),
      act: (b) => b.add(TripMerged(_trip(id: 't1', title: 'new'))),
      expect: () => [
        TripsState(trips: [_trip(id: 't1', title: 'new')]),
      ],
    );
  });

  group('ItinerarySaveRequested', () {
    final draft = ItineraryDraft(
      title: 'My Trip',
      startDate: DateTime(2026, 5, 1),
      days: const [],
    );

    blocTest<TripsBloc, TripsState>(
      'prepends saved trip and completes the completer',
      build: () {
        when(() => service.createTrip(any(),
                bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async => _trip(id: 'fresh', title: 'My Trip'));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1')]),
      act: (b) {
        final c = Completer<Trip>();
        b.add(ItinerarySaveRequested(
          draft,
          assistantMessageId: 'asst-1',
          completer: c,
        ));
        return c.future;
      },
      expect: () => [
        TripsState(trips: [_trip(id: 'fresh', title: 'My Trip'), _trip(id: 't1')]),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'dispatches BuddySavedTripLinked to BuddyBloc with the trip id',
      build: () {
        when(() => service.createTrip(any(),
                bearerToken: any(named: 'bearerToken')))
            .thenAnswer((_) async => _trip(id: 'fresh'));
        return build();
      },
      act: (b) {
        final c = Completer<Trip>();
        b.add(ItinerarySaveRequested(
          draft,
          assistantMessageId: 'asst-7',
          completer: c,
        ));
        return c.future;
      },
      verify: (_) {
        final captured = verify(() => buddy.add(captureAny())).captured;
        expect(captured.length, 1);
        final evt = captured.single as BuddySavedTripLinked;
        expect(evt.assistantMessageId, 'asst-7');
        expect(evt.savedTripId, 'fresh');
      },
    );

    blocTest<TripsBloc, TripsState>(
      'on error completes the completer with the error and does not link',
      build: () {
        when(() => service.createTrip(any(),
                bearerToken: any(named: 'bearerToken')))
            .thenThrow(TripServiceException(500, 'no'));
        return build();
      },
      act: (b) async {
        final c = Completer<Trip>();
        b.add(ItinerarySaveRequested(
          draft,
          assistantMessageId: 'asst-1',
          completer: c,
        ));
        try {
          await c.future;
        } catch (_) {}
      },
      errors: () => [isA<TripServiceException>()],
      verify: (_) {
        verifyNever(() => buddy.add(any(that: isA<BuddySavedTripLinked>())));
      },
    );

    blocTest<TripsBloc, TripsState>(
      'guard: rejects save when already at maxSavedTrips and never calls service',
      build: () {
        // Service mock is deliberately NOT set up — the guard should fire
        // before any network call. If the guard misses, the mock-not-set
        // expectation surfaces a clear failure (vs. a passing test).
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 'a'),
        _trip(id: 'b'),
        _trip(id: 'c'),
      ]),
      act: (b) async {
        final c = Completer<Trip>();
        b.add(ItinerarySaveRequested(
          draft,
          assistantMessageId: 'asst-cap',
          completer: c,
        ));
        try {
          await c.future;
        } catch (_) {}
      },
      expect: () => [
        TripsState(
          trips: [_trip(id: 'a'), _trip(id: 'b'), _trip(id: 'c')],
          lastError: TripsErrorKey.tripLimitReached,
        ),
      ],
      verify: (_) {
        verifyNever(() => service.createTrip(any(),
            bearerToken: any(named: 'bearerToken')));
        verifyNever(() => buddy.add(any(that: isA<BuddySavedTripLinked>())));
      },
    );

    blocTest<TripsBloc, TripsState>(
      'server-race: 409 trip_limit_reached body surfaces tripLimitReached key',
      build: () {
        // Two trips locally → guard passes → service is called → server
        // returns 409 because a different device already saved trip #3 in
        // the meantime. The bloc must still surface the same lastError key
        // so the UI can render its inline "Limit reached" branch.
        when(() => service.createTrip(any(),
                bearerToken: any(named: 'bearerToken')))
            .thenThrow(
          TripServiceException(409, '{"detail":"trip_limit_reached"}'),
        );
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 'a'), _trip(id: 'b')]),
      act: (b) async {
        final c = Completer<Trip>();
        b.add(ItinerarySaveRequested(
          draft,
          assistantMessageId: 'asst-race',
          completer: c,
        ));
        try {
          await c.future;
        } catch (_) {}
      },
      expect: () => [
        TripsState(
          trips: [_trip(id: 'a'), _trip(id: 'b')],
          lastError: TripsErrorKey.tripLimitReached,
        ),
      ],
      errors: () => [isA<TripServiceException>()],
    );
  });

  group('TripRenameRequested', () {
    blocTest<TripsBloc, TripsState>(
      'optimistic rename then server confirm',
      build: () {
        when(() => service.patchTrip(
              't1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1', title: 'Server Title'));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1', title: 'Old')]),
      act: (b) => b.add(const TripRenameRequested('t1', 'Optimistic')),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't1', title: 'Optimistic')],
          pendingTripIds: const {'t1'},
        ),
        TripsState(trips: [_trip(id: 't1', title: 'Server Title')]),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'reverts and surfaces banner on failure',
      build: () {
        when(() => service.patchTrip(
              't1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenThrow(TripServiceException(401, 'auth'));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1', title: 'Old')]),
      act: (b) => b.add(const TripRenameRequested('t1', 'Optimistic')),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't1', title: 'Optimistic')],
          pendingTripIds: const {'t1'},
        ),
        TripsState(
          trips: [_trip(id: 't1', title: 'Old')],
          lastError: TripsErrorKey.signIn,
        ),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'no-op for empty title',
      build: build,
      seed: () => TripsState(trips: [_trip(id: 't1', title: 'Old')]),
      act: (b) => b.add(const TripRenameRequested('t1', '   ')),
      expect: () => const <TripsState>[],
    );
  });

  group('TripSummaryUpdateRequested', () {
    blocTest<TripsBloc, TripsState>(
      'optimistic clear then server confirm',
      build: () {
        when(() => service.patchTrip(
              't1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1'));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1', summary: 'old')]),
      act: (b) => b.add(const TripSummaryUpdateRequested('t1', null)),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't1')],
          pendingTripIds: const {'t1'},
        ),
        TripsState(trips: [_trip(id: 't1')]),
      ],
    );
  });

  group('TripStartDateUpdateRequested', () {
    blocTest<TripsBloc, TripsState>(
      'set start date',
      build: () {
        when(() => service.patchTrip(
              't1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer(
                (_) async => _trip(id: 't1', startDate: DateTime(2026, 6, 1)));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1')]),
      act: (b) => b.add(TripStartDateUpdateRequested(
        't1',
        startDate: DateTime(2026, 6, 1),
      )),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't1', startDate: DateTime(2026, 6, 1))],
          pendingTripIds: const {'t1'},
        ),
        TripsState(
          trips: [_trip(id: 't1', startDate: DateTime(2026, 6, 1))],
        ),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'clear start date',
      build: () {
        when(() => service.patchTrip(
              't1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1'));
        return build();
      },
      seed: () => TripsState(
        trips: [_trip(id: 't1', startDate: DateTime(2026, 1, 1))],
      ),
      act: (b) =>
          b.add(const TripStartDateUpdateRequested('t1', clear: true)),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't1')],
          pendingTripIds: const {'t1'},
        ),
        TripsState(trips: [_trip(id: 't1')]),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'no-op when neither startDate nor clear given',
      build: build,
      seed: () => TripsState(trips: [_trip(id: 't1')]),
      act: (b) => b.add(const TripStartDateUpdateRequested('t1')),
      expect: () => const <TripsState>[],
    );
  });

  group('TripDeleteRequested', () {
    blocTest<TripsBloc, TripsState>(
      'optimistic remove then server ok',
      build: () {
        when(() => service.deleteTrip('t1',
            bearerToken: any(named: 'bearerToken'))).thenAnswer((_) async {});
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1'), _trip(id: 't2')]),
      act: (b) => b.add(const TripDeleteRequested('t1')),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't2')],
          pendingTripIds: const {'t1'},
        ),
        TripsState(trips: [_trip(id: 't2')]),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'restores previous list on error',
      build: () {
        when(() => service.deleteTrip('t1',
                bearerToken: any(named: 'bearerToken')))
            .thenThrow(TripServiceException(500, 'no'));
        return build();
      },
      seed: () => TripsState(trips: [_trip(id: 't1'), _trip(id: 't2')]),
      act: (b) => b.add(const TripDeleteRequested('t1')),
      expect: () => [
        TripsState(
          trips: [_trip(id: 't2')],
          pendingTripIds: const {'t1'},
        ),
        TripsState(
          trips: [_trip(id: 't1'), _trip(id: 't2')],
          lastError: TripsErrorKey.generic,
        ),
      ],
    );
  });

  group('StopEditRequested', () {
    blocTest<TripsBloc, TripsState>(
      'patches name optimistically then accepts server response',
      build: () {
        when(() => service.patchStop(
              't1',
              's1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(
              id: 't1',
              days: [
                _day(id: 'd1', stops: [_stop(id: 's1', name: 'Server')])
              ],
            ));
        return build();
      },
      seed: () => TripsState(
        trips: [
          _trip(id: 't1', days: [
            _day(id: 'd1', stops: [_stop(id: 's1', name: 'Old')])
          ]),
        ],
      ),
      act: (b) => b.add(const StopEditRequested(
        't1',
        'd1',
        's1',
        {'name': 'Optimistic'},
      )),
      expect: () => [
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.name,
          'optimistic name',
          'Optimistic',
        ).having((s) => s.pendingStopIds, 'pending', {'s1'}),
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.name,
          'server name',
          'Server',
        ).having((s) => s.pendingStopIds, 'pending cleared', isEmpty),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'empty patch is a no-op',
      build: build,
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1', name: 'X')]),
        ])
      ]),
      act: (b) => b.add(const StopEditRequested('t1', 'd1', 's1', {})),
      expect: () => const <TripsState>[],
    );
  });

  group('StopVisitMarkRequested', () {
    final visitedAt = DateTime.utc(2026, 5, 21, 14, 30);

    blocTest<TripsBloc, TripsState>(
      'optimistic visit then accepts server completed_at',
      build: () {
        when(() => service.patchStop(
              't1',
              's1',
              any(that: containsPair('completed_at', visitedAt.toIso8601String())),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(
              id: 't1',
              days: [
                _day(id: 'd1', stops: [
                  _stop(id: 's1', name: 'X').copyWith(completedAt: visitedAt),
                ])
              ],
            ));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1', name: 'X')]),
        ])
      ]),
      act: (b) => b.add(StopVisitMarkRequested(
        tripId: 't1', dayId: 'd1', stopId: 's1',
        visitedAt: visitedAt, source: 'manual',
      )),
      expect: () => [
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.completedAt,
          'optimistic completedAt',
          visitedAt,
        ).having((s) => s.pendingStopIds, 'pending', {'s1'}),
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.completedAt,
          'server completedAt',
          visitedAt,
        ).having((s) => s.pendingStopIds, 'pending cleared', isEmpty),
      ],
    );

    blocTest<TripsBloc, TripsState>(
      'reverts on patch failure',
      build: () {
        when(() => service.patchStop(
              't1', 's1', any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenThrow(TripServiceException(500, 'boom'));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1', name: 'X')]),
        ])
      ]),
      act: (b) => b.add(StopVisitMarkRequested(
        tripId: 't1', dayId: 'd1', stopId: 's1',
        visitedAt: visitedAt, source: 'auto',
      )),
      expect: () => [
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.completedAt,
          'optimistic completedAt',
          visitedAt,
        ),
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.completedAt,
          'reverted to null',
          isNull,
        ).having((s) => s.pendingStopIds, 'pending cleared', isEmpty)
         .having((s) => s.lastError, 'error surfaced', isNotNull),
      ],
    );
  });

  group('StopVisitResetRequested', () {
    final visitedAt = DateTime.utc(2026, 5, 21, 14, 30);

    blocTest<TripsBloc, TripsState>(
      'optimistic null then accepts server null',
      build: () {
        when(() => service.patchStop(
              't1', 's1',
              any(that: containsPair('completed_at', null)),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(
              id: 't1',
              days: [
                _day(id: 'd1', stops: [_stop(id: 's1', name: 'X')]),
              ],
            ));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [
            _stop(id: 's1', name: 'X').copyWith(completedAt: visitedAt),
          ]),
        ])
      ]),
      act: (b) => b.add(const StopVisitResetRequested(
        tripId: 't1', dayId: 'd1', stopId: 's1',
      )),
      expect: () => [
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.completedAt,
          'optimistic null',
          isNull,
        ),
        isA<TripsState>().having(
          (s) => s.trips.first.days.first.stops.first.completedAt,
          'server null',
          isNull,
        ).having((s) => s.pendingStopIds, 'pending cleared', isEmpty),
      ],
    );
  });

  group('StopAddRequested', () {
    blocTest<TripsBloc, TripsState>(
      'appends optimistic stop then accepts server',
      build: () {
        when(() => service.addStop(
              't1',
              'd1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(
              id: 't1',
              days: [
                _day(id: 'd1', stops: [
                  _stop(id: 's1'),
                  _stop(id: 's2', sortOrder: 1, name: 'New'),
                ])
              ],
            ));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1')]),
        ]),
      ]),
      act: (b) => b.add(const StopAddRequested('t1', 'd1', {
        'name': 'New',
        'kind': 'sight',
      })),
      verify: (b) {
        // Final emitted state should contain the server-confirmed stop set.
        expect(b.state.trips.first.days.first.stops.length, 2);
        expect(b.state.trips.first.days.first.stops.last.id, 's2');
        expect(b.state.pendingDayIds, isEmpty);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'reverts trip on server error',
      build: () {
        when(() => service.addStop(
              't1',
              'd1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenThrow(TripServiceException(500, 'x'));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1')]),
        ]),
      ]),
      act: (b) => b.add(const StopAddRequested('t1', 'd1', {
        'name': 'New',
        'kind': 'sight',
      })),
      verify: (b) {
        expect(b.state.trips.first.days.first.stops.length, 1);
        expect(b.state.lastError, isNotNull);
      },
    );
  });

  group('StopDeleteRequested', () {
    blocTest<TripsBloc, TripsState>(
      'removes optimistically and accepts server',
      build: () {
        when(() => service.deleteStop(
              't1',
              's1',
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [_day(id: 'd1')]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1')]),
        ]),
      ]),
      act: (b) => b.add(const StopDeleteRequested('t1', 'd1', 's1')),
      verify: (b) =>
          expect(b.state.trips.first.days.first.stops, isEmpty),
    );

    blocTest<TripsBloc, TripsState>(
      'records an UndoStopRecord for the 5s window after server confirm',
      build: () {
        when(() => service.deleteStop(
              't1',
              's1',
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [_day(id: 'd1')]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [
            _stop(id: 's1', name: 'Skanderbeg Square'),
          ]),
        ]),
      ]),
      act: (b) => b.add(const StopDeleteRequested('t1', 'd1', 's1')),
      verify: (b) {
        // The undo record survives until the 5s timer fires; we don't
        // wait that long here — just check the snapshot was recorded.
        final r = b.state.pendingUndoStops['s1'];
        expect(r, isNotNull);
        expect(r!.stopName, 'Skanderbeg Square');
        expect(r.dayId, 'd1');
        expect(r.originalSortOrder, 0);
        // Body strips id/sort_order; carries name + kind (Pydantic Literal
        // requires kind so the recreate POST validates).
        expect(r.body['name'], 'Skanderbeg Square');
        expect(r.body['kind'], 'sight');
        expect(r.body.containsKey('id'), false);
        expect(r.body.containsKey('sort_order'), false);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'drops the undo record when the server delete fails',
      build: () {
        when(() => service.deleteStop(
              't1',
              's1',
              bearerToken: any(named: 'bearerToken'),
            )).thenThrow(TripServiceException(500, 'boom'));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1')]),
        ]),
      ]),
      act: (b) => b.add(const StopDeleteRequested('t1', 'd1', 's1')),
      verify: (b) {
        // Optimistic delete reverted + no undo record (the server still
        // has the stop, so there's nothing to undo).
        expect(b.state.trips.first.days.first.stops, hasLength(1));
        expect(b.state.pendingUndoStops, isEmpty);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'StopDeleteUndoRequested clears the record and re-adds via POST',
      build: () {
        when(() => service.deleteStop(
              't1',
              's1',
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [_day(id: 'd1')]));
        // Recreated stop gets a NEW id on POST. We assert the call args
        // (sort_order = original 0, kind = sight) below.
        when(() => service.addStop(
              't1',
              'd1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(
              id: 't1',
              days: [
                _day(id: 'd1', stops: [_stop(id: 's-new', name: 'Skanderbeg Square')]),
              ],
            ));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [
            _stop(id: 's1', name: 'Skanderbeg Square'),
          ]),
        ]),
      ]),
      act: (b) async {
        b.add(const StopDeleteRequested('t1', 'd1', 's1'));
        // Wait for the delete to land + undo timer to be armed before
        // dispatching the undo; otherwise the record isn't there yet.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(const StopDeleteUndoRequested('s1'));
      },
      wait: const Duration(milliseconds: 100),
      verify: (b) {
        expect(b.state.pendingUndoStops, isEmpty);
        // The server's addStop response replaced the optimistic state,
        // so the day now has the re-created stop (with the server's new id).
        final stops = b.state.trips.first.days.first.stops;
        expect(stops, hasLength(1));
        expect(stops.first.name, 'Skanderbeg Square');
        verify(() => service.addStop(
              't1',
              'd1',
              any(that: containsPair('sort_order', 0)),
              bearerToken: any(named: 'bearerToken'),
            )).called(1);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'StopDeleteUndoExpired clears the record without re-adding',
      build: () => build(),
      seed: () => TripsState(
        trips: [
          _trip(id: 't1', days: [_day(id: 'd1')]),
        ],
        pendingUndoStops: {
          's1': const UndoStopRecord(
            tripId: 't1',
            dayId: 'd1',
            stopId: 's1',
            stopName: 'Skanderbeg Square',
            originalSortOrder: 0,
            body: {'name': 'Skanderbeg Square', 'kind': 'sight'},
          ),
        },
      ),
      act: (b) => b.add(const StopDeleteUndoExpired('s1')),
      verify: (b) {
        expect(b.state.pendingUndoStops, isEmpty);
        // No addStop call — expiry just clears the banner.
        verifyNever(() => service.addStop(
              any(),
              any(),
              any(),
              bearerToken: any(named: 'bearerToken'),
            ));
      },
    );
  });

  group('StopsReorderRequested', () {
    blocTest<TripsBloc, TripsState>(
      'reorders optimistically and accepts server',
      build: () {
        when(() => service.reorderStops(
              't1',
              'd1',
              any(),
              bearerToken: any(named: 'bearerToken'),
              recomputeTimes: any(named: 'recomputeTimes'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [
              _day(id: 'd1', stops: [
                _stop(id: 's2', sortOrder: 0),
                _stop(id: 's1', sortOrder: 1),
              ])
            ]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [
            _stop(id: 's1', sortOrder: 0),
            _stop(id: 's2', sortOrder: 1),
          ]),
        ]),
      ]),
      act: (b) =>
          b.add(const StopsReorderRequested('t1', 'd1', ['s2', 's1'])),
      verify: (b) {
        final ids = b.state.trips.first.days.first.stops.map((s) => s.id).toList();
        expect(ids, ['s2', 's1']);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'no-op on mismatched id set',
      build: build,
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1'), _stop(id: 's2', sortOrder: 1)]),
        ]),
      ]),
      act: (b) =>
          b.add(const StopsReorderRequested('t1', 'd1', ['s9', 's1'])),
      expect: () => const <TripsState>[],
    );

    blocTest<TripsBloc, TripsState>(
      'optimistic preview slot-anchors times; server response replaces them',
      build: () {
        // With recomputeTimes:true the server is the authoritative
        // re-scheduler, so the final state mirrors the server response —
        // here the mock happens to return slot-anchored times because the
        // forward-walk would produce the same result on this fixture.
        when(() => service.reorderStops(
              't1',
              'd1',
              any(),
              bearerToken: any(named: 'bearerToken'),
              recomputeTimes: any(named: 'recomputeTimes'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [
              _day(id: 'd1', stops: [
                _stop(
                  id: 's2',
                  sortOrder: 0,
                  arrivalTime: '09:00',
                  endTime: '10:00',
                  durationMinutes: 60,
                ),
                _stop(
                  id: 's1',
                  sortOrder: 1,
                  arrivalTime: '12:00',
                  endTime: '13:30',
                  durationMinutes: 90,
                ),
              ]),
            ]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [
            _stop(
              id: 's1',
              sortOrder: 0,
              arrivalTime: '09:00',
              endTime: '10:00',
              durationMinutes: 60,
            ),
            _stop(
              id: 's2',
              sortOrder: 1,
              arrivalTime: '12:00',
              endTime: '13:30',
              durationMinutes: 90,
            ),
          ]),
        ]),
      ]),
      act: (b) =>
          b.add(const StopsReorderRequested('t1', 'd1', ['s2', 's1'])),
      verify: (b) {
        final stops = b.state.trips.first.days.first.stops;
        // Position 0 keeps the 09:00 slot (now owned by s2);
        // position 1 keeps the 12:00 slot (now owned by s1).
        expect(stops[0].id, 's2');
        expect(stops[0].arrivalTime, '09:00');
        expect(stops[0].endTime, '10:00');
        expect(stops[0].durationMinutes, 60);
        expect(stops[1].id, 's1');
        expect(stops[1].arrivalTime, '12:00');
        expect(stops[1].endTime, '13:30');
        expect(stops[1].durationMinutes, 90);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'reorder payload omits per-position time fields and sets recomputeTimes',
      build: () {
        when(() => service.reorderStops(
              any(),
              any(),
              any(),
              bearerToken: any(named: 'bearerToken'),
              recomputeTimes: any(named: 'recomputeTimes'),
            )).thenAnswer((_) async =>
            _trip(id: 't1', days: [_day(id: 'd1', stops: const [])]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [
            _stop(id: 's1', sortOrder: 0, arrivalTime: '09:00'),
            _stop(id: 's2', sortOrder: 1, arrivalTime: '12:00'),
          ]),
        ]),
      ]),
      act: (b) =>
          b.add(const StopsReorderRequested('t1', 'd1', ['s2', 's1'])),
      verify: (_) {
        // Server is the sole authority on times when recomputeTimes is on,
        // so the wire payload carries just stop_id + sort_order pairs.
        final capturedOrder = verify(() => service.reorderStops(
              't1',
              'd1',
              captureAny(),
              bearerToken: any(named: 'bearerToken'),
              recomputeTimes: captureAny(named: 'recomputeTimes'),
            )).captured;
        final order = capturedOrder[0] as List<Map<String, dynamic>>;
        final recompute = capturedOrder[1] as bool;
        expect(order, const [
          {'stop_id': 's2', 'sort_order': 0},
          {'stop_id': 's1', 'sort_order': 1},
        ]);
        expect(recompute, isTrue);
      },
    );
  });

  group('StopMoveToDayRequested', () {
    blocTest<TripsBloc, TripsState>(
      'cross-day move sends recomputeTimes and autoPosition when sortOrder is null',
      build: () {
        when(() => service.moveStop(
              any(),
              any(),
              targetDayId: any(named: 'targetDayId'),
              sortOrder: any(named: 'sortOrder'),
              bearerToken: any(named: 'bearerToken'),
              recomputeTimes: any(named: 'recomputeTimes'),
              autoPosition: any(named: 'autoPosition'),
            )).thenAnswer((inv) async {
          // Capture into the outer-scope `moveCallArgs` map declared in
          // the enclosing test (see verify block). Closure-based capture
          // sidesteps mocktail's brittle capture-ordering across matcher
          // counts.
          moveCallArgs
            ..['targetDayId'] = inv.namedArguments[#targetDayId]
            ..['sortOrder'] = inv.namedArguments[#sortOrder]
            ..['recomputeTimes'] = inv.namedArguments[#recomputeTimes]
            ..['autoPosition'] = inv.namedArguments[#autoPosition];
          return _trip(id: 't1', days: [
            _day(id: 'd1', stops: const []),
            _day(id: 'd2', stops: [_stop(id: 's1', sortOrder: 0)]),
          ]);
        });
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1', sortOrder: 0)]),
          _day(id: 'd2', stops: const []),
        ]),
      ]),
      act: (b) => b.add(
        const StopMoveToDayRequested(
          tripId: 't1',
          sourceDayId: 'd1',
          targetDayId: 'd2',
          stopId: 's1',
        ),
      ),
      verify: (_) {
        expect(moveCallArgs['targetDayId'], 'd2');
        expect(moveCallArgs['sortOrder'], isNull);
        expect(moveCallArgs['recomputeTimes'], isTrue);
        expect(moveCallArgs['autoPosition'], isTrue);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'cross-day move with explicit sortOrder turns autoPosition off',
      build: () {
        moveCallArgs.clear();
        when(() => service.moveStop(
              any(),
              any(),
              targetDayId: any(named: 'targetDayId'),
              sortOrder: any(named: 'sortOrder'),
              bearerToken: any(named: 'bearerToken'),
              recomputeTimes: any(named: 'recomputeTimes'),
              autoPosition: any(named: 'autoPosition'),
            )).thenAnswer((inv) async {
          moveCallArgs
            ..['sortOrder'] = inv.namedArguments[#sortOrder]
            ..['autoPosition'] = inv.namedArguments[#autoPosition];
          return _trip(id: 't1', days: [
            _day(id: 'd1', stops: const []),
            _day(id: 'd2', stops: [_stop(id: 's1', sortOrder: 0)]),
          ]);
        });
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1', sortOrder: 0)]),
          _day(id: 'd2', stops: const []),
        ]),
      ]),
      act: (b) => b.add(
        const StopMoveToDayRequested(
          tripId: 't1',
          sourceDayId: 'd1',
          targetDayId: 'd2',
          stopId: 's1',
          sortOrder: 0,
        ),
      ),
      verify: (_) {
        expect(moveCallArgs['sortOrder'], 0);
        expect(moveCallArgs['autoPosition'], isFalse);
      },
    );
  });

  group('DayAddRequested / DayDeleteRequested', () {
    blocTest<TripsBloc, TripsState>(
      'addDay optimistically inserts a temp day then accepts server',
      build: () {
        when(() => service.addDay(
              't1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [
              _day(id: 'd1', dayNumber: 1),
              _day(id: 'd2', dayNumber: 2, title: 'Berat'),
            ]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [_day(id: 'd1', dayNumber: 1)]),
      ]),
      act: (b) =>
          b.add(const DayAddRequested('t1', 2, title: 'Berat')),
      verify: (b) {
        expect(b.state.trips.first.days.length, 2);
        expect(b.state.trips.first.days.last.id, 'd2');
        expect(b.state.pendingTripIds, isEmpty);
      },
    );

    blocTest<TripsBloc, TripsState>(
      'deleteDay optimistically removes and accepts server',
      build: () {
        when(() => service.deleteDay(
              't1',
              'd2',
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async => _trip(id: 't1', days: [
              _day(id: 'd1', dayNumber: 1),
            ]));
        return build();
      },
      seed: () => TripsState(trips: [
        _trip(id: 't1', days: [
          _day(id: 'd1', dayNumber: 1),
          _day(id: 'd2', dayNumber: 2),
        ]),
      ]),
      act: (b) => b.add(const DayDeleteRequested('t1', 'd2')),
      verify: (b) =>
          expect(b.state.trips.first.days.map((d) => d.id), ['d1']),
    );
  });

  group('Error events', () {
    blocTest<TripsBloc, TripsState>(
      'TripsErrorSurfaced sets lastError',
      build: build,
      act: (b) => b.add(const TripsErrorSurfaced('boom')),
      expect: () => const [TripsState(lastError: 'boom')],
    );

    blocTest<TripsBloc, TripsState>(
      'ErrorDismissed clears lastError when set',
      build: build,
      seed: () => const TripsState(lastError: 'boom'),
      act: (b) => b.add(const ErrorDismissed()),
      expect: () => const [TripsState()],
    );

    blocTest<TripsBloc, TripsState>(
      'ErrorDismissed is a no-op when lastError already null',
      build: build,
      act: (b) => b.add(const ErrorDismissed()),
      expect: () => const <TripsState>[],
    );
  });

  group('Per-day serialization', () {
    test(
      'two same-day events: second addStop fires only after first emits',
      () async {
        final order = <String>[];
        // First call resolves slowly; second call resolves quickly. With
        // serialization, the second SERVICE call must not fire until the
        // first completes.
        final firstCompleter = Completer<Trip>();
        when(() => service.addStop(
              't1',
              'd1',
              any(),
              bearerToken: any(named: 'bearerToken'),
            )).thenAnswer((_) async {
          order.add('call');
          if (!firstCompleter.isCompleted) {
            return firstCompleter.future;
          }
          return _trip(id: 't1', days: [
            _day(id: 'd1', stops: [_stop(id: 's1'), _stop(id: 's2', sortOrder: 1)])
          ]);
        });

        final bloc = TripsBloc(
          service: service,
          tokenReader: () => _token,
          buddyBlocProvider: () => buddy,
        );
        bloc.emit(TripsState(trips: [
          _trip(id: 't1', days: [_day(id: 'd1')]),
        ]));

        bloc.add(const StopAddRequested('t1', 'd1', {
          'name': 'A',
          'kind': 'sight',
        }));
        bloc.add(const StopAddRequested('t1', 'd1', {
          'name': 'B',
          'kind': 'sight',
        }));

        // Let event loop dispatch.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        // Only the first call should have started.
        expect(order, ['call']);

        firstCompleter.complete(_trip(id: 't1', days: [
          _day(id: 'd1', stops: [_stop(id: 's1')]),
        ]));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(order.length, 2);
        await bloc.close();
      },
    );

    test('different-day events run in parallel', () async {
      final activeCalls = <String>{};
      var maxConcurrent = 0;

      Future<Trip> serve(String dayId) async {
        activeCalls.add(dayId);
        if (activeCalls.length > maxConcurrent) {
          maxConcurrent = activeCalls.length;
        }
        await Future<void>.delayed(const Duration(milliseconds: 30));
        activeCalls.remove(dayId);
        return _trip(id: 't1', days: [_day(id: dayId)]);
      }

      when(() => service.addStop(
            't1',
            'd1',
            any(),
            bearerToken: any(named: 'bearerToken'),
          )).thenAnswer((_) => serve('d1'));
      when(() => service.addStop(
            't1',
            'd2',
            any(),
            bearerToken: any(named: 'bearerToken'),
          )).thenAnswer((_) => serve('d2'));

      final bloc = TripsBloc(
        service: service,
        tokenReader: () => _token,
        buddyBlocProvider: () => buddy,
      );
      bloc.emit(TripsState(trips: [
        _trip(id: 't1', days: [_day(id: 'd1'), _day(id: 'd2')]),
      ]));

      bloc.add(const StopAddRequested('t1', 'd1', {
        'name': 'A',
        'kind': 'sight',
      }));
      bloc.add(const StopAddRequested('t1', 'd2', {
        'name': 'B',
        'kind': 'sight',
      }));

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(maxConcurrent, 2);
      await bloc.close();
    });
  });
}
