import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_buddy/agent/features/tts/bloc/tts_bloc.dart';
import 'package:travel_buddy/agent/features/tts/bloc/tts_event.dart';
import 'package:travel_buddy/agent/features/tts/bloc/tts_state.dart';

class _MockFlutterTts extends Mock implements FlutterTts {}

void main() {
  late _MockFlutterTts tts;
  void Function()? startHandler;
  void Function()? completionHandler;
  void Function()? cancelHandler;
  void Function(dynamic)? errorHandler;

  TtsBloc build() => TtsBloc(tts: tts);

  setUp(() {
    tts = _MockFlutterTts();
    startHandler = null;
    completionHandler = null;
    cancelHandler = null;
    errorHandler = null;
    when(() => tts.awaitSpeakCompletion(any())).thenAnswer((_) async => 1);
    when(() => tts.setSpeechRate(any())).thenAnswer((_) async => 1);
    when(() => tts.setPitch(any())).thenAnswer((_) async => 1);
    when(() => tts.setVolume(any())).thenAnswer((_) async => 1);
    when(() => tts.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => tts.stop()).thenAnswer((_) async => 1);
    when(() => tts.speak(any())).thenAnswer((_) async => 1);
    when(() => tts.setStartHandler(any())).thenAnswer((inv) {
      startHandler = inv.positionalArguments[0] as void Function();
    });
    when(() => tts.setCompletionHandler(any())).thenAnswer((inv) {
      completionHandler = inv.positionalArguments[0] as void Function();
    });
    when(() => tts.setCancelHandler(any())).thenAnswer((inv) {
      cancelHandler = inv.positionalArguments[0] as void Function();
    });
    when(() => tts.setErrorHandler(any())).thenAnswer((inv) {
      errorHandler = inv.positionalArguments[0] as void Function(dynamic);
    });
    when(() => tts.isLanguageAvailable(any())).thenAnswer((_) async => true);
  });

  group('TtsSpeakRequested', () {
    blocTest<TtsBloc, TtsBlocState>(
      'emits loading then speaking on engine start, then idle on completion',
      build: build,
      act: (b) async {
        b.add(const TtsSpeakRequested(messageId: 'm1', text: 'Hello'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        startHandler?.call();
        await Future<void>.delayed(const Duration(milliseconds: 5));
        completionHandler?.call();
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        TtsBlocState(status: TtsState.loading, activeMessageId: 'm1'),
        TtsBlocState(status: TtsState.speaking, activeMessageId: 'm1'),
        TtsBlocState(),
      ],
    );

    blocTest<TtsBloc, TtsBlocState>(
      'empty (markdown-only) text produces no emit and no speak',
      build: build,
      act: (b) async {
        b.add(const TtsSpeakRequested(messageId: 'm1', text: '   '));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [],
      verify: (_) => verifyNever(() => tts.speak(any())),
    );

    blocTest<TtsBloc, TtsBlocState>(
      'second speak restarts: stop+speak fired for both messages',
      build: build,
      act: (b) async {
        b.add(const TtsSpeakRequested(messageId: 'm1', text: 'first'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const TtsSpeakRequested(messageId: 'm2', text: 'second'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (_) {
        verify(() => tts.speak('first')).called(1);
        verify(() => tts.speak('second')).called(1);
      },
    );
  });

  group('TtsStopRequested', () {
    blocTest<TtsBloc, TtsBlocState>(
      'stops engine and emits idle',
      build: build,
      seed: () => const TtsBlocState(
        status: TtsState.speaking,
        activeMessageId: 'm1',
      ),
      act: (b) => b.add(const TtsStopRequested()),
      expect: () => const [TtsBlocState()],
      verify: (_) => verify(() => tts.stop()).called(greaterThanOrEqualTo(1)),
    );
  });

  group('engine callbacks', () {
    blocTest<TtsBloc, TtsBlocState>(
      'engine error event resets state to idle',
      build: build,
      act: (b) async {
        b.add(const TtsSpeakRequested(messageId: 'm1', text: 'Hello'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        startHandler?.call();
        await Future<void>.delayed(const Duration(milliseconds: 5));
        errorHandler?.call('engine boom');
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        TtsBlocState(status: TtsState.loading, activeMessageId: 'm1'),
        TtsBlocState(status: TtsState.speaking, activeMessageId: 'm1'),
        TtsBlocState(),
      ],
    );

    blocTest<TtsBloc, TtsBlocState>(
      'engine cancel event resets state to idle',
      build: build,
      act: (b) async {
        b.add(const TtsSpeakRequested(messageId: 'm1', text: 'Hello'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        startHandler?.call();
        await Future<void>.delayed(const Duration(milliseconds: 5));
        cancelHandler?.call();
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        TtsBlocState(status: TtsState.loading, activeMessageId: 'm1'),
        TtsBlocState(status: TtsState.speaking, activeMessageId: 'm1'),
        TtsBlocState(),
      ],
    );
  });

  group('language fallback', () {
    blocTest<TtsBloc, TtsBlocState>(
      'falls through unsupported tags until a supported one is found',
      build: () {
        when(() => tts.isLanguageAvailable(any())).thenAnswer((inv) async {
          final c = inv.positionalArguments[0] as String;
          return c == 'en-US';
        });
        return build();
      },
      act: (b) async {
        b.add(const TtsSpeakRequested(
          messageId: 'm1',
          text: 'Hello',
          localeId: 'sq-AL',
          fallbackLocales: ['it-IT', 'en-US'],
        ));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        TtsBlocState(status: TtsState.loading, activeMessageId: 'm1'),
      ],
      verify: (_) {
        verify(() => tts.isLanguageAvailable('sq-AL')).called(1);
        verify(() => tts.isLanguageAvailable('it-IT')).called(1);
        verify(() => tts.isLanguageAvailable('en-US')).called(1);
        verify(() => tts.setLanguage('en-US')).called(1);
      },
    );
  });
}
