import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/agent/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';
import 'package:travel_buddy/agent/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/agent/features/buddy/bloc/buddy_state.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/agent/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/agent/logic/buddy/chat_message.dart';
import 'package:travel_buddy/agent/logic/buddy/chat_service.dart';
import 'package:travel_buddy/agent/domain/entities/trip_route.dart';
import 'package:travel_buddy/agent/logic/buddy/chat_stream_event.dart';
import 'package:travel_buddy/agent/logic/buddy/live_stop.dart';
import 'package:travel_buddy/agent/logic/buddy/live_trip.dart';
import 'package:travel_buddy/agent/logic/buddy/conversations_service.dart';

class _MockChatService extends Mock implements ChatService {}

class _MockConversationsService extends Mock implements ConversationsService {}

class _MockAuthBloc extends Mock implements AuthBloc {}

class _MockTripsBloc extends Mock implements TripsBloc {}

class _FakeTrip extends Fake implements Trip {
  _FakeTrip(this.id);
  @override
  final String id;
}

class _FakeTripsEvent extends Fake implements TripsEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTripsEvent());
  });

  late _MockChatService chat;
  late _MockConversationsService convs;
  late _MockAuthBloc auth;
  late _MockTripsBloc trips;
  late List<StreamController<ChatStreamEvent>> streamQueue;
  String? token;

  BuddyBloc build() => BuddyBloc(
        service: chat,
        conversationsServiceProvider: () => convs,
        tokenReader: () => token,
        authBlocProvider: () => auth,
        tripsBlocProvider: () => trips,
      );

  setUp(() {
    chat = _MockChatService();
    convs = _MockConversationsService();
    auth = _MockAuthBloc();
    trips = _MockTripsBloc();
    streamQueue = [];
    token = 'tok';
    SharedPreferences.setMockInitialValues({});
    when(() => chat.stream(
          message: any(named: 'message'),
          conversationId: any(named: 'conversationId'),
          bearerToken: any(named: 'bearerToken'),
          imageUrls: any(named: 'imageUrls'),
          tripId: any(named: 'tripId'),
        )).thenAnswer((_) {
      final c = StreamController<ChatStreamEvent>();
      streamQueue.add(c);
      return c.stream;
    });
    when(() => trips.add(any())).thenReturn(null);
  });

  Future<void> tick([int ms = 5]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  group('BuddyInitialized', () {
    blocTest<BuddyBloc, BuddyState>(
      'restores conversationId from SharedPreferences',
      setUp: () => SharedPreferences.setMockInitialValues({
        'buddy.conversationId': 'persisted',
      }),
      build: build,
      act: (b) async {
        b.add(const BuddyInitialized());
        await tick();
      },
      verify: (b) => expect(b.state.conversationId, 'persisted'),
    );

    blocTest<BuddyBloc, BuddyState>(
      'is idempotent — second BuddyInitialized is a no-op',
      setUp: () => SharedPreferences.setMockInitialValues({
        'buddy.conversationId': 'persisted',
      }),
      build: build,
      act: (b) async {
        b.add(const BuddyInitialized());
        await tick();
        b.add(const BuddyInitialized());
        await tick();
      },
      expect: () => const [BuddyState(conversationId: 'persisted')],
    );
  });

  group('BuddySendMessageRequested', () {
    blocTest<BuddyBloc, BuddyState>(
      'empty text and no images is a no-op',
      build: build,
      act: (b) async {
        b.add(const BuddySendMessageRequested(text: '   '));
        await tick();
      },
      expect: () => const [],
      verify: (_) => verifyNever(() => chat.stream(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            bearerToken: any(named: 'bearerToken'),
            imageUrls: any(named: 'imageUrls'),
            tripId: any(named: 'tripId'),
          )),
    );

    blocTest<BuddyBloc, BuddyState>(
      'concurrent send while streaming is dropped',
      build: build,
      act: (b) async {
        b.add(const BuddySendMessageRequested(text: 'one'));
        await tick();
        b.add(const BuddySendMessageRequested(text: 'two'));
        await tick();
      },
      verify: (_) => verify(() => chat.stream(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            bearerToken: any(named: 'bearerToken'),
            imageUrls: any(named: 'imageUrls'),
            tripId: any(named: 'tripId'),
          )).called(1),
    );

    test('TextDelta concatenates content into the streaming asst by id',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const TextDelta('hello '));
      await tick();
      streamQueue[0].add(const TextDelta('world'));
      await tick();
      streamQueue[0].add(const StreamDone());
      await streamQueue[0].close();
      await tick();
      expect(bloc.state.messages.last.content, 'hello world');
      expect(bloc.state.messages.last.isStreaming, isFalse);
      expect(bloc.state.isStreaming, isFalse);
      await bloc.close();
    });

    test('ConversationIdEvent persists to SharedPreferences', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const ConversationIdEvent('conv-42'));
      await tick();
      streamQueue[0].add(const StreamDone());
      await streamQueue[0].close();
      await tick();
      expect(bloc.state.conversationId, 'conv-42');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('buddy.conversationId'), 'conv-42');
      await bloc.close();
    });

    test('PlaceCardEvent inserts card before streaming asst', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'show me a place'));
      await tick();
      streamQueue[0].add(const PlaceCardEvent({'name': 'Berat'}));
      await tick();
      // [user, card, asst]
      final msgs = bloc.state.messages;
      expect(msgs.length, 3);
      expect(msgs[0].role, ChatRole.user);
      expect(msgs[1].richKind, 'place_card');
      expect(msgs[2].isStreaming, isTrue);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('ItineraryStreamEvent attaches draft to the asst', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      final draft = ItineraryDraft.fromToolJson({'title': 'Albania', 'days': []});
      streamQueue[0].add(ItineraryStreamEvent(draft));
      await tick();
      expect(bloc.state.messages.last.itinerary, isNotNull);
      await streamQueue[0].close();
      await bloc.close();
    });

    // ---- live itinerary streaming ----------------------------------------

    LiveStop liveStop({
      required String id,
      required int index,
      required int day,
      required int sort,
      String name = 'Stop',
      String? dayTitle,
      String? city = 'Tirana',
    }) =>
        LiveStop(
          id: id,
          index: index,
          dayNumber: day,
          dayTitle: dayTitle,
          sortOrder: sort,
          name: name,
          kind: StopKind.sight,
          city: city,
          lat: 41.0 + index,
          lng: 19.0 + index,
        );

    test('ItineraryStreamStartEvent flips the bubble and resets the live trip',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryStreamStartEvent());
      await tick();
      expect(bloc.state.messages.last.isItinerary, isTrue);
      expect(bloc.state.messages.last.liveStops, isEmpty);
      expect(bloc.state.liveTrip?.id, kLiveTripId);
      expect(bloc.state.liveTripMessageId, bloc.state.messages.last.id);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('ItineraryStopEvent grows both the chat rows and the live trip',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryStreamStartEvent());
      streamQueue[0].add(ItineraryStopEvent(
        liveStop(id: 'live-1-0', index: 1, day: 1, sort: 0, dayTitle: 'Old town'),
      ));
      streamQueue[0].add(ItineraryStopEvent(
        liveStop(id: 'live-2-0', index: 2, day: 2, sort: 0),
      ));
      await tick();
      final msg = bloc.state.messages.last;
      expect(msg.liveStops.map((s) => s.id), ['live-1-0', 'live-2-0']);
      final trip = bloc.state.liveTrip!;
      expect(trip.days.map((d) => d.dayNumber), [1, 2]);
      expect(trip.days.first.id, 'live-day-1');
      expect(trip.days.first.title, 'Old town');
      expect(trip.days.first.stops.single.id, 'live-1-0');
      // Marker ids must survive onto the trip or itinerary_routes orphans.
      expect(trip.days.last.stops.single.lat, closeTo(43.0, 1e-9));
      await streamQueue[0].close();
      await bloc.close();
    });

    test('out-of-order stops are sorted by day then sort_order', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryStreamStartEvent());
      streamQueue[0]
          .add(ItineraryStopEvent(liveStop(id: 'live-1-1', index: 2, day: 1, sort: 1)));
      streamQueue[0]
          .add(ItineraryStopEvent(liveStop(id: 'live-1-0', index: 1, day: 1, sort: 0)));
      await tick();
      expect(
        bloc.state.messages.last.liveStops.map((s) => s.id),
        ['live-1-0', 'live-1-1'],
      );
      expect(
        bloc.state.liveTrip!.days.single.stops.map((s) => s.id),
        ['live-1-0', 'live-1-1'],
      );
      await streamQueue[0].close();
      await bloc.close();
    });

    test('a repeated stop id replaces rather than duplicates', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryStreamStartEvent());
      streamQueue[0].add(ItineraryStopEvent(
          liveStop(id: 'live-1-0', index: 1, day: 1, sort: 0, name: 'First')));
      streamQueue[0].add(ItineraryStopEvent(
          liveStop(id: 'live-1-0', index: 1, day: 1, sort: 0, name: 'Second')));
      await tick();
      expect(bloc.state.messages.last.liveStops, hasLength(1));
      expect(bloc.state.messages.last.liveStops.single.name, 'Second');
      expect(bloc.state.liveTrip!.days.single.stops, hasLength(1));
      expect(bloc.state.liveTrip!.days.single.stops.single.name, 'Second');
      await streamQueue[0].close();
      await bloc.close();
    });

    test('ItineraryRoutesEvent merges onto the live trip without moving stops',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryStreamStartEvent());
      streamQueue[0]
          .add(ItineraryStopEvent(liveStop(id: 'live-1-0', index: 1, day: 1, sort: 0)));
      await tick();
      final before = bloc.state.liveTrip!.days;
      streamQueue[0].add(const ItineraryRoutesEvent([
        TripRoute(
          id: 'r1',
          tripDayId: 'live-day-1',
          fromStopId: 'live-1-0',
          toStopId: 'live-1-1',
          encodedPolyline: 'abc',
          travelMode: 'walking',
        ),
      ]));
      await tick();
      expect(bloc.state.liveTrip!.routes, hasLength(1));
      expect(bloc.state.liveTrip!.days, before);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('ItineraryStreamEvent titles the live trip and leaves rows alone',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryStreamStartEvent());
      streamQueue[0]
          .add(ItineraryStopEvent(liveStop(id: 'live-1-0', index: 1, day: 1, sort: 0)));
      await tick();
      streamQueue[0].add(ItineraryStreamEvent(
        ItineraryDraft.fromToolJson({'title': 'Tirana in 3 days', 'days': []}),
      ));
      await tick();
      expect(bloc.state.liveTrip!.title, 'Tirana in 3 days');
      // Streamed rows win — the draft must not overwrite them.
      expect(bloc.state.messages.last.liveStops, hasLength(1));
      await streamQueue[0].close();
      await bloc.close();
    });

    test('draft populates rows when no stop was mappable', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(ItineraryStreamEvent(
        ItineraryDraft.fromToolJson({
          'title': 'Tirana',
          'days': [
            {
              'day_number': 1,
              'title': 'Old town',
              'stops': [
                {'name': 'Skanderbeg Square', 'kind': 'sight', 'notes': 'Heart'},
              ],
            },
          ],
        }),
      ));
      await tick();
      final msg = bloc.state.messages.last;
      expect(msg.isItinerary, isTrue);
      expect(msg.liveStops, hasLength(1));
      expect(msg.liveStops.single.name, 'Skanderbeg Square');
      expect(msg.liveStops.single.description, 'Heart');
      await streamQueue[0].close();
      await bloc.close();
    });

    test('ItineraryPreviewEvent sets the live trip wholesale', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(ItineraryPreviewEvent(Trip.fromJson({
        'id': 'preview',
        'title': 'Tirana',
        'days': [],
        'routes': [],
      })));
      await tick();
      expect(bloc.state.liveTrip!.title, 'Tirana');
      expect(bloc.state.liveTripMessageId, bloc.state.messages.last.id);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('ItineraryInvalidStreamEvent flips itineraryFailed', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const ItineraryInvalidStreamEvent('bad shape'));
      await tick();
      expect(bloc.state.messages.last.itineraryFailed, isTrue);
      expect(bloc.state.lastError, isNull);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('TripRefinedStreamEvent fires TripMerged + flips tripRefined',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'shorten day 2'));
      await tick();
      final trip = _FakeTrip('t1');
      streamQueue[0].add(TripRefinedStreamEvent(trip));
      await tick();
      expect(bloc.state.messages.last.tripRefined, isTrue);
      verify(() => trips.add(any(that: isA<TripMerged>()))).called(1);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('RefineFailedStreamEvent flips refineFailed', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'refine'));
      await tick();
      streamQueue[0].add(const RefineFailedStreamEvent('replace failed'));
      await tick();
      expect(bloc.state.messages.last.refineFailed, isTrue);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('PersistFailed flips notSaved on the streaming asst', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const PersistFailed());
      await tick();
      expect(bloc.state.messages.last.notSaved, isTrue);
      await streamQueue[0].close();
      await bloc.close();
    });

    test('500 error sets hasError, lastError, and clears isStreaming',
        () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const StreamError('boom', statusCode: 500));
      await tick();
      expect(bloc.state.messages.last.hasError, isTrue);
      expect(bloc.state.messages.last.isStreaming, isFalse);
      expect(bloc.state.isStreaming, isFalse);
      expect(bloc.state.lastError, 'boom');
      await streamQueue[0].close();
      await bloc.close();
    });

    test('StreamDone flips isStreaming on bloc and asst', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const TextDelta('done.'));
      streamQueue[0].add(const StreamDone());
      await tick();
      await streamQueue[0].close();
      await tick();
      expect(bloc.state.isStreaming, isFalse);
      expect(bloc.state.messages.last.isStreaming, isFalse);
      await bloc.close();
    });
  });

  group('401 retry', () {
    test('retries with refreshed token and second stream resolves', () async {
      when(() => auth.refreshAccessToken()).thenAnswer((_) async => 'new-tok');
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const StreamError('expired', statusCode: 401));
      await tick(20);
      // Second stream should now exist.
      expect(streamQueue.length, 2);
      streamQueue[1].add(const TextDelta('after-refresh'));
      streamQueue[1].add(const StreamDone());
      await tick();
      await streamQueue[1].close();
      await tick();
      expect(bloc.state.messages.last.content, 'after-refresh');
      expect(bloc.state.messages.last.hasError, isFalse);
      verify(() => auth.refreshAccessToken()).called(1);
      await bloc.close();
    });

    test('refresh returning null surfaces the error', () async {
      when(() => auth.refreshAccessToken()).thenAnswer((_) async => null);
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const StreamError('expired', statusCode: 401));
      await tick();
      expect(bloc.state.messages.last.hasError, isTrue);
      expect(bloc.state.lastError, 'expired');
      await streamQueue[0].close();
      await bloc.close();
    });

    test('reset-flags before retry clears notSaved + itineraryFailed',
        () async {
      when(() => auth.refreshAccessToken()).thenAnswer((_) async => 'new-tok');
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const TextDelta('partial '));
      streamQueue[0].add(const PersistFailed());
      streamQueue[0].add(const ItineraryInvalidStreamEvent('bad'));
      await tick();
      expect(bloc.state.messages.last.notSaved, isTrue);
      expect(bloc.state.messages.last.itineraryFailed, isTrue);
      streamQueue[0].add(const StreamError('expired', statusCode: 401));
      await tick(20);
      // After retry, transient flags reset, content cleared.
      streamQueue[1].add(const TextDelta('fresh'));
      streamQueue[1].add(const StreamDone());
      await tick();
      await streamQueue[1].close();
      await tick();
      expect(bloc.state.messages.last.content, 'fresh');
      expect(bloc.state.messages.last.notSaved, isFalse);
      expect(bloc.state.messages.last.itineraryFailed, isFalse);
      await bloc.close();
    });
  });

  group('404 in scoped mode', () {
    test('clears scopedTrip and dispatches TripsErrorSurfaced', () async {
      when(() => convs.getOrCreateForTrip(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => TripConversationRef(id:'c1'));
      when(() => convs.get(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => const <ChatMessage>[]);
      final bloc = build();
      bloc.add(BuddyOpenRefineRequested(_FakeTrip('t1')));
      await tick();
      expect(bloc.state.scopedTrip, isNotNull);
      bloc.add(const BuddySendMessageRequested(text: 'refine'));
      await tick();
      streamQueue[0].add(const StreamError('gone', statusCode: 404));
      await tick();
      expect(bloc.state.scopedTrip, isNull);
      verify(() => trips.add(any(that: isA<TripsErrorSurfaced>()))).called(1);
      await streamQueue[0].close();
      await bloc.close();
    });
  });

  group('BuddyStreamCancelRequested', () {
    test('cancels mid-stream and clears asst.isStreaming', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const TextDelta('partial '));
      await tick();
      bloc.add(const BuddyStreamCancelRequested());
      await tick();
      expect(bloc.state.isStreaming, isFalse);
      expect(bloc.state.messages.last.isStreaming, isFalse);
      expect(bloc.state.lastError, isNull);
      await bloc.close();
    });
  });

  group('BuddyConversationCleared', () {
    test('empties messages, clears prefs, resets state', () async {
      SharedPreferences.setMockInitialValues({
        'buddy.conversationId': 'old',
      });
      final bloc = build();
      bloc.add(const BuddyInitialized());
      await tick();
      expect(bloc.state.conversationId, 'old');
      bloc.add(const BuddyConversationCleared());
      await tick();
      expect(bloc.state, equals(const BuddyState()));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('buddy.conversationId'), isNull);
      await bloc.close();
    });
  });

  group('BuddyOpenRefineRequested', () {
    test('hydrates messages, sets scopedTrip, sets requestedTab=1', () async {
      when(() => convs.getOrCreateForTrip(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => TripConversationRef(id:'c-trip'));
      when(() => convs.get(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => [
                ChatMessage(id: 'h1', role: ChatRole.assistant, content: 'hello')
              ]);
      final bloc = build();
      bloc.add(BuddyOpenRefineRequested(_FakeTrip('t1')));
      await tick();
      expect(bloc.state.scopedTrip?.id, 't1');
      expect(bloc.state.conversationId, 'c-trip');
      expect(bloc.state.requestedTab, 1);
      expect(bloc.state.messages.length, 1);
      await bloc.close();
    });
  });

  group('BuddyRefineModeExited', () {
    test('drops scopedTrip while preserving messages', () async {
      when(() => convs.getOrCreateForTrip(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => TripConversationRef(id:'c1'));
      when(() => convs.get(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => [
                ChatMessage(id: 'h1', role: ChatRole.assistant, content: 'hello')
              ]);
      final bloc = build();
      bloc.add(BuddyOpenRefineRequested(_FakeTrip('t1')));
      await tick();
      bloc.add(const BuddyRefineModeExited());
      await tick();
      expect(bloc.state.scopedTrip, isNull);
      expect(bloc.state.messages.length, 1);
      await bloc.close();
    });
  });

  group('BuddySavedTripLinked', () {
    test('patches savedTripId on the matching message', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'plan'));
      await tick();
      streamQueue[0].add(const TextDelta('here you go'));
      streamQueue[0].add(const StreamDone());
      await tick();
      await streamQueue[0].close();
      await tick();
      final asstId = bloc.state.messages.last.id;
      expect(bloc.state.messages.last.savedTripId, isNull);
      bloc.add(BuddySavedTripLinked(
        assistantMessageId: asstId,
        savedTripId: 'trip-77',
      ));
      await tick();
      expect(bloc.state.messages.last.savedTripId, 'trip-77');
      await bloc.close();
    });

    test('is a no-op when the message id is not in state', () async {
      final bloc = build();
      bloc.add(const BuddySavedTripLinked(
        assistantMessageId: 'unknown',
        savedTripId: 'trip-99',
      ));
      await tick();
      expect(bloc.state.messages, isEmpty);
      await bloc.close();
    });
  });

  group('BuddyTabRequested / BuddyTabConsumed', () {
    blocTest<BuddyBloc, BuddyState>(
      'requested+consumed cycle',
      build: build,
      act: (b) async {
        b.add(const BuddyTabRequested(2));
        await tick();
        b.add(const BuddyTabConsumed());
        await tick();
      },
      expect: () => const [
        BuddyState(requestedTab: 2),
        BuddyState(),
      ],
    );
  });

  group('BuddyRetryLastRequested', () {
    test('no-op when no prior user text', () async {
      final bloc = build();
      bloc.add(const BuddyRetryLastRequested());
      await tick();
      expect(bloc.state.messages, isEmpty);
      verifyNever(() => chat.stream(
            message: any(named: 'message'),
            conversationId: any(named: 'conversationId'),
            bearerToken: any(named: 'bearerToken'),
            imageUrls: any(named: 'imageUrls'),
            tripId: any(named: 'tripId'),
          ));
      await bloc.close();
    });

    test('drops the failed asst and re-streams', () async {
      final bloc = build();
      bloc.add(const BuddySendMessageRequested(text: 'hi'));
      await tick();
      streamQueue[0].add(const StreamError('boom', statusCode: 500));
      await tick();
      expect(bloc.state.messages.last.hasError, isTrue);
      bloc.add(const BuddyRetryLastRequested());
      await tick();
      // The hasError asst was popped and replaced by a fresh streaming one.
      expect(bloc.state.messages.last.hasError, isFalse);
      expect(bloc.state.messages.last.isStreaming, isTrue);
      streamQueue[1].add(const TextDelta('retried'));
      streamQueue[1].add(const StreamDone());
      await tick();
      await streamQueue[1].close();
      await tick();
      expect(bloc.state.messages.last.content, 'retried');
      await bloc.close();
    });
  });

  group('BuddyConversationLoaded', () {
    test('replaces messages, sets conversationId, drops scopedTrip', () async {
      final bloc = build();
      // Pre-set scoped state, then load history — scopedTrip must clear.
      when(() => convs.getOrCreateForTrip(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => TripConversationRef(id:'c-trip'));
      when(() => convs.get(any(), bearerToken: any(named: 'bearerToken')))
          .thenAnswer((_) async => const []);
      bloc.add(BuddyOpenRefineRequested(_FakeTrip('t1')));
      await tick();
      expect(bloc.state.scopedTrip, isNotNull);
      bloc.add(BuddyConversationLoaded(
        id: 'old-conv',
        hydrated: [
          ChatMessage(id: 'h1', role: ChatRole.assistant, content: 'hi'),
        ],
      ));
      await tick();
      expect(bloc.state.conversationId, 'old-conv');
      expect(bloc.state.scopedTrip, isNull);
      expect(bloc.state.messages.length, 1);
      await bloc.close();
    });
  });
}
