import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:travel_buddy/features/voice/bloc/voice_bloc.dart';
import 'package:travel_buddy/features/voice/bloc/voice_event.dart';
import 'package:travel_buddy/features/voice/bloc/voice_state.dart';

class _MockStt extends Mock implements stt.SpeechToText {}

class _FakeResult extends Fake implements SpeechRecognitionResult {
  _FakeResult({required this.recognizedWords, required this.finalResult});
  @override
  final String recognizedWords;
  @override
  final bool finalResult;
}

class _FakeError extends Fake implements SpeechRecognitionError {
  _FakeError(this.errorMsg);
  @override
  final String errorMsg;
  @override
  bool get permanent => false;
}

class _FakeListenOptions extends Fake implements stt.SpeechListenOptions {}

void _noResult(SpeechRecognitionResult _) {}
void _noLevel(double _) {}
void _noError(SpeechRecognitionError _) {}
void _noStatus(String _) {}

void main() {
  setUpAll(() {
    registerFallbackValue(_noResult);
    registerFallbackValue(_noLevel);
    registerFallbackValue(_noError);
    registerFallbackValue(_noStatus);
    registerFallbackValue(_FakeListenOptions());
  });

  late _MockStt mockStt;
  void Function(SpeechRecognitionError)? capturedOnError;
  void Function(String)? capturedOnStatus;
  void Function(SpeechRecognitionResult)? capturedOnResult;
  void Function(double)? capturedOnLevel;
  bool initReturn = true;

  VoiceBloc build() => VoiceBloc(speechToText: mockStt);

  setUp(() {
    mockStt = _MockStt();
    capturedOnError = null;
    capturedOnStatus = null;
    capturedOnResult = null;
    capturedOnLevel = null;
    initReturn = true;

    when(() => mockStt.initialize(
          onError: any(named: 'onError'),
          onStatus: any(named: 'onStatus'),
        )).thenAnswer((inv) async {
      capturedOnError = inv.namedArguments[#onError]
          as void Function(SpeechRecognitionError);
      capturedOnStatus =
          inv.namedArguments[#onStatus] as void Function(String);
      return initReturn;
    });
    when(() => mockStt.isAvailable).thenReturn(true);
    when(() => mockStt.listen(
          localeId: any(named: 'localeId'),
          onResult: any(named: 'onResult'),
          listenFor: any(named: 'listenFor'),
          pauseFor: any(named: 'pauseFor'),
          onSoundLevelChange: any(named: 'onSoundLevelChange'),
          listenOptions: any(named: 'listenOptions'),
        )).thenAnswer((inv) async {
      capturedOnResult = inv.namedArguments[#onResult]
          as void Function(SpeechRecognitionResult);
      capturedOnLevel = inv.namedArguments[#onSoundLevelChange]
          as void Function(double);
    });
    when(() => mockStt.stop()).thenAnswer((_) async {});
    when(() => mockStt.cancel()).thenAnswer((_) async {});
  });

  group('VoiceStartRequested', () {
    blocTest<VoiceBloc, VoiceBlocState>(
      'emits listening when init succeeds',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        VoiceBlocState(status: VoiceState.listening),
      ],
      verify: (_) =>
          verify(() => mockStt.listen(
                localeId: any(named: 'localeId'),
                onResult: any(named: 'onResult'),
                listenFor: any(named: 'listenFor'),
                pauseFor: any(named: 'pauseFor'),
                onSoundLevelChange: any(named: 'onSoundLevelChange'),
                listenOptions: any(named: 'listenOptions'),
              )).called(1),
    );

    blocTest<VoiceBloc, VoiceBlocState>(
      'emits unavailable when init returns false',
      build: () {
        initReturn = false;
        return build();
      },
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        VoiceBlocState(status: VoiceState.unavailable),
      ],
    );
  });

  group('VoiceResultReceived', () {
    blocTest<VoiceBloc, VoiceBlocState>(
      'partial result with empty committed sets transcript to live',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnResult?.call(_FakeResult(
          recognizedWords: 'hello world',
          finalResult: false,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        VoiceBlocState(status: VoiceState.listening),
        VoiceBlocState(
          status: VoiceState.listening,
          transcript: 'hello world',
        ),
      ],
    );

    blocTest<VoiceBloc, VoiceBlocState>(
      'final result flips hasFinalResult',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnResult?.call(
          _FakeResult(recognizedWords: 'done', finalResult: true),
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (b) {
        expect(b.state.transcript, 'done');
        expect(b.state.hasFinalResult, isTrue);
      },
    );

    blocTest<VoiceBloc, VoiceBlocState>(
      'late onResult from prior session is dropped',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        // Pretend the prior session's late onResult arrives — its sessionId
        // is older than what _listenInternal captured.
        b.add(const VoiceResultReceived(
          live: 'stale',
          isFinal: false,
          sessionId: -1,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      expect: () => const [
        VoiceBlocState(status: VoiceState.listening),
      ],
    );
  });

  group('VoiceStatusChanged', () {
    blocTest<VoiceBloc, VoiceBlocState>(
      'continuous=true with listening triggers re-listen after 150ms gap',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        // Simulate engine silence-stop.
        capturedOnStatus?.call('done');
        await Future<void>.delayed(const Duration(milliseconds: 200));
      },
      verify: (_) => verify(() => mockStt.listen(
            localeId: any(named: 'localeId'),
            onResult: any(named: 'onResult'),
            listenFor: any(named: 'listenFor'),
            pauseFor: any(named: 'pauseFor'),
            onSoundLevelChange: any(named: 'onSoundLevelChange'),
            listenOptions: any(named: 'listenOptions'),
          )).called(2),
    );

    blocTest<VoiceBloc, VoiceBlocState>(
      'status=done after user stop emits idle (no restart)',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const VoiceStopRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnStatus?.call('done');
        await Future<void>.delayed(const Duration(milliseconds: 200));
      },
      verify: (b) {
        expect(b.state.status, VoiceState.idle);
        verify(() => mockStt.listen(
              localeId: any(named: 'localeId'),
              onResult: any(named: 'onResult'),
              listenFor: any(named: 'listenFor'),
              pauseFor: any(named: 'pauseFor'),
              onSoundLevelChange: any(named: 'onSoundLevelChange'),
              listenOptions: any(named: 'listenOptions'),
            )).called(1);
      },
    );
  });

  group('VoiceCancelRequested', () {
    blocTest<VoiceBloc, VoiceBlocState>(
      'resets transcript + status + soundLevel and calls _stt.cancel',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnResult?.call(
          _FakeResult(recognizedWords: 'partial', finalResult: false),
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const VoiceCancelRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (b) {
        expect(b.state.status, VoiceState.idle);
        expect(b.state.transcript, isEmpty);
        expect(b.state.soundLevel, 0.0);
        verify(() => mockStt.cancel()).called(greaterThanOrEqualTo(1));
      },
    );
  });

  group('VoicePermissionDenied', () {
    blocTest<VoiceBloc, VoiceBlocState>(
      'platform error_permission emits permissionDenied status',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnError?.call(_FakeError('error_permission'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (b) {
        expect(b.state.status, VoiceState.permissionDenied);
      },
    );

    blocTest<VoiceBloc, VoiceBlocState>(
      'non-permission errors are ignored (engine fires done shortly after)',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnError?.call(_FakeError('error_no_match'));
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (b) {
        expect(b.state.status, VoiceState.listening);
      },
    );
  });

  group('VoiceLevelChanged', () {
    blocTest<VoiceBloc, VoiceBlocState>(
      'normalizes platform dB into [0, 1]: silence (-50) is 0',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnLevel?.call(-50.0);
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (b) {
        expect(b.state.soundLevel, 0.0);
      },
    );

    blocTest<VoiceBloc, VoiceBlocState>(
      'loud speech (~0 dB) saturates near 1.0',
      build: build,
      act: (b) async {
        b.add(const VoiceStartRequested());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        capturedOnLevel?.call(0.0);
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      verify: (b) {
        expect(b.state.soundLevel, greaterThan(0.9));
      },
    );
  });
}
