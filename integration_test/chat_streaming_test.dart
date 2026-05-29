// Deterministic integration test for the buddy chat streaming render path.
//
// It mounts the REAL `BuddyScreen` with a fully faked dependency graph and
// scripts an SSE token stream through a fake `ChatService` — no live backend,
// no auth, no network. This guards the Session-7 streaming-smoothness fix:
//   * while a turn streams, the bubble renders cheap plain `Text` (raw
//     markdown markers visible) and NO `MarkdownBody` is mounted;
//   * markdown is parsed exactly once, on completion;
//   * the per-token render cost stays flat (no O(n) growth from re-parsing the
//     whole growing string each token).
//
// Run headless:   flutter test integration_test/chat_streaming_test.dart
// Run on device:  flutter test integration_test/chat_streaming_test.dart -d <id>
//   (a device run yields real frame timings; the iOS *simulator* does not
//    support profile mode, so true frame-time numbers need a physical device
//    or an Android emulator.)

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/features/auth/bloc/auth_event.dart';
import 'package:travel_buddy/features/auth/bloc/auth_state.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/features/tts/bloc/tts_bloc.dart';
import 'package:travel_buddy/features/tts/bloc/tts_event.dart';
import 'package:travel_buddy/features/tts/bloc/tts_state.dart';
import 'package:travel_buddy/features/voice/bloc/voice_bloc.dart';
import 'package:travel_buddy/features/voice/bloc/voice_event.dart';
import 'package:travel_buddy/features/voice/bloc/voice_state.dart';
import 'package:travel_buddy/l10n/app_localizations.dart';
import 'package:travel_buddy/logic/buddy/chat_service.dart';
import 'package:travel_buddy/logic/buddy/chat_stream_event.dart';
import 'package:travel_buddy/logic/buddy/conversations_service.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/ui/screens/buddy/buddy_screen.dart';

class _MockChatService extends Mock implements ChatService {}

class _MockConversationsService extends Mock implements ConversationsService {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockTripsBloc extends MockBloc<TripsEvent, TripsState>
    implements TripsBloc {}

class _MockVoiceBloc extends MockBloc<VoiceEvent, VoiceBlocState>
    implements VoiceBloc {}

class _MockTtsBloc extends MockBloc<TtsEvent, TtsBlocState>
    implements TtsBloc {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _MockChatService chat;
  late _MockConversationsService convs;
  late _MockAuthBloc auth;
  late _MockTripsBloc trips;
  late _MockVoiceBloc voice;
  late _MockTtsBloc tts;
  late BuddyBloc buddy;
  late List<StreamController<ChatStreamEvent>> streamQueue;

  setUpAll(() async {
    // Production reads `$strings.<key>` synchronously via GetIt<LocaleLogic>.
    if (!GetIt.I.isRegistered<LocaleLogic>()) {
      final logic = LocaleLogic();
      await logic.loadIfChanged(const Locale('en'));
      GetIt.I.registerSingleton<LocaleLogic>(logic);
    }
  });

  setUp(() {
    chat = _MockChatService();
    convs = _MockConversationsService();
    auth = _MockAuthBloc();
    trips = _MockTripsBloc();
    voice = _MockVoiceBloc();
    tts = _MockTtsBloc();
    streamQueue = [];
    SharedPreferences.setMockInitialValues({});

    whenListen(trips, const Stream<TripsState>.empty(),
        initialState: const TripsState());
    whenListen(voice, const Stream<VoiceBlocState>.empty(),
        initialState: const VoiceBlocState());
    whenListen(tts, const Stream<TtsBlocState>.empty(),
        initialState: const TtsBlocState());
    whenListen(auth, const Stream<AuthState>.empty(),
        initialState: const AuthState());

    // The screen pulls Voice/Tts from GetIt in initState/dispose; provide the
    // same mock instances there as in the widget tree.
    GetIt.I.registerSingleton<VoiceBloc>(voice);
    GetIt.I.registerSingleton<TtsBloc>(tts);

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

    buddy = BuddyBloc(
      service: chat,
      conversationsServiceProvider: () => convs,
      tokenReader: () => 'tok',
      authBlocProvider: () => auth,
      tripsBlocProvider: () => trips,
    );
  });

  tearDown(() async {
    await buddy.close();
    for (final c in streamQueue) {
      if (!c.isClosed) await c.close();
    }
    if (GetIt.I.isRegistered<VoiceBloc>()) GetIt.I.unregister<VoiceBloc>();
    if (GetIt.I.isRegistered<TtsBloc>()) GetIt.I.unregister<TtsBloc>();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<BuddyBloc>.value(value: buddy),
            BlocProvider<AuthBloc>.value(value: auth),
            BlocProvider<VoiceBloc>.value(value: voice),
            BlocProvider<TtsBloc>.value(value: tts),
            BlocProvider<TripsBloc>.value(value: trips),
          ],
          child: BuddyScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  StreamController<ChatStreamEvent> activeStream() => streamQueue.last;

  testWidgets(
      'streams plain text during a turn, swaps to MarkdownBody on completion',
      (tester) async {
    await pumpScreen(tester);

    // Real UI entry: the welcome shows tappable suggestion chips.
    buddy.add(const BuddySendMessageRequested(
        text: 'Best things to do in Berat'));
    await tester.pump();
    await tester.pump();

    // Script a markdown reply token-by-token.
    const tokens = [
      '**Berat** ',
      'is a ',
      'UNESCO town. ',
      'Visit *Gorica ',
      'Bridge* ',
      'and the ',
      'castle.',
    ];
    for (final t in tokens) {
      activeStream().add(TextDelta(t));
      await tester.pump(const Duration(milliseconds: 1));
    }

    // MID-STREAM: cheap plain Text only — no markdown parsing yet, and the raw
    // `**` / `*` markers are visible (proves plain-Text-during-stream).
    expect(find.byType(MarkdownBody), findsNothing,
        reason: 'markdown must not be parsed while streaming');
    expect(find.textContaining('**Berat**'), findsWidgets,
        reason: 'raw markdown markers should be visible in plain Text');

    // Complete the turn.
    activeStream().add(const StreamDone());
    await activeStream().close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // ON COMPLETION: parsed exactly once into a MarkdownBody; raw markers gone.
    expect(find.byType(MarkdownBody), findsOneWidget,
        reason: 'completed reply renders as formatted markdown');
    expect(find.textContaining('**Berat**'), findsNothing,
        reason: 'raw markers should be parsed away after completion');
    expect(buddy.state.isStreaming, isFalse);
  });

  testWidgets('per-token render cost stays flat under a 120-token burst',
      (tester) async {
    await pumpScreen(tester);

    buddy.add(const BuddySendMessageRequested(text: 'Plan a long trip'));
    await tester.pump();
    await tester.pump();

    final stream = activeStream();
    final pumpMicros = <int>[];
    final sw = Stopwatch();
    for (var i = 0; i < 120; i++) {
      stream.add(TextDelta('word$i and some filler text. '));
      sw
        ..reset()
        ..start();
      await tester.pump(const Duration(milliseconds: 1));
      sw.stop();
      pumpMicros.add(sw.elapsedMicroseconds);
    }

    int median(List<int> xs) {
      final s = [...xs]..sort();
      return s[s.length ~/ 2];
    }

    final firstTen = median(pumpMicros.sublist(0, 10));
    final lastTen = median(pumpMicros.sublist(pumpMicros.length - 10));
    // ignore: avoid_print
    print('[stream-perf] median first-10=${firstTen}us '
        'last-10=${lastTen}us tokens=${pumpMicros.length}');

    // The bug this guards: re-parsing the whole growing markdown string every
    // token makes per-token cost grow ~O(n). With plain-Text streaming it
    // stays flat. A generous 8x ceiling catches gross O(n) regressions while
    // tolerating per-environment noise.
    expect(lastTen, lessThan(firstTen * 8 + 2000),
        reason: 'per-token render cost should not grow with reply length');

    activeStream().add(const StreamDone());
    await activeStream().close();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MarkdownBody), findsOneWidget);
  });
}
