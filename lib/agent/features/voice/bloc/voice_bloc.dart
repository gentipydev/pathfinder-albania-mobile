import 'dart:async';
import 'dart:math' as math;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:travel_buddy/agent/features/voice/bloc/voice_event.dart';
import 'package:travel_buddy/agent/features/voice/bloc/voice_state.dart';

/// Bloc replacement for the legacy `VoiceLogic`. Wraps `package:speech_to_text`
/// to expose continuous-listen dictation as a stream of state updates. Restart
/// glue lives in `_onStatus` — the platform engines auto-stop on silence (~2-5s
/// on Android, similar on iOS) regardless of `pauseFor`, so we re-arm with a
/// 150 ms gap to keep a single logical session alive across recognizer cycles.
class VoiceBloc extends Bloc<VoiceEvent, VoiceBlocState> {
  VoiceBloc({stt.SpeechToText? speechToText})
      : _stt = speechToText ?? stt.SpeechToText(),
        super(const VoiceBlocState()) {
    on<VoiceStartRequested>(_onStart, transformer: sequential());
    on<VoiceStopRequested>(_onStop, transformer: sequential());
    on<VoiceCancelRequested>(_onCancel, transformer: sequential());
    on<VoiceResultReceived>(_onResult, transformer: concurrent());
    on<VoiceLevelChanged>(_onLevel, transformer: concurrent());
    on<VoiceStatusChanged>(_onStatus, transformer: sequential());
    on<VoicePermissionDenied>(_onPermissionDenied, transformer: sequential());
  }

  final stt.SpeechToText _stt;
  bool _initialized = false;

  // Running ceiling for amplitude normalization. iOS reports dB, Android's
  // unit is undocumented — we adapt instead of hard-coding a range.
  double _levelMax = 1.0;

  // Continuous-listen plumbing. The platform STT engines auto-stop on their
  // own silence detection regardless of `pauseFor`. To match ChatGPT/Claude
  // voice mode UX we keep a single logical session alive across these stops
  // by restarting the recognizer and appending the new transcript to the
  // prior one until the user taps stop or cancel.
  bool _continuous = false;
  bool _userStopRequested = false;
  String _committedText = '';
  String? _localeId;

  // Bumped on every commit/stop so a late onResult arriving after
  // `onStatus('done')` is discarded — its closure captured the old id.
  int _sessionId = 0;

  Future<bool> _ensureInit() async {
    if (_initialized) return _stt.isAvailable;
    _initialized = true;
    final ok = await _stt.initialize(
      onError: (err) {
        // error_permission is fatal. Other errors (no_match, speech_timeout,
        // recognizer_busy) are normal mid-stream events; the engine fires
        // `done` shortly after, which routes through `VoiceStatusChanged`.
        if (err.errorMsg == 'error_permission') {
          add(const VoicePermissionDenied());
        }
      },
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          add(VoiceStatusChanged(status));
        }
      },
    );
    return ok;
  }

  Future<void> _onStart(
    VoiceStartRequested e,
    Emitter<VoiceBlocState> emit,
  ) async {
    final ok = await _ensureInit();
    if (!ok) {
      emit(state.copyWith(status: VoiceState.unavailable, soundLevel: 0.0));
      return;
    }
    _committedText = '';
    _userStopRequested = false;
    _continuous = true;
    _localeId = e.localeId;
    _levelMax = 1.0;
    emit(const VoiceBlocState(status: VoiceState.listening));
    await _listenInternal();
  }

  Future<void> _listenInternal() async {
    final mySession = ++_sessionId;
    await _stt.listen(
      localeId: _localeId,
      onResult: (result) {
        add(VoiceResultReceived(
          live: result.recognizedWords,
          isFinal: result.finalResult,
          sessionId: mySession,
        ));
      },
      onSoundLevelChange: (lvl) => add(VoiceLevelChanged(lvl)),
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 30),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
        autoPunctuation: true,
      ),
    );
  }

  Future<void> _onStop(
    VoiceStopRequested e,
    Emitter<VoiceBlocState> emit,
  ) async {
    if (state.status != VoiceState.listening) return;
    _userStopRequested = true;
    _continuous = false;
    await _stt.stop();
    emit(state.copyWith(status: VoiceState.idle, soundLevel: 0.0));
  }

  Future<void> _onCancel(
    VoiceCancelRequested e,
    Emitter<VoiceBlocState> emit,
  ) async {
    _userStopRequested = true;
    _continuous = false;
    await _stt.cancel();
    _committedText = '';
    emit(const VoiceBlocState());
  }

  void _onResult(VoiceResultReceived e, Emitter<VoiceBlocState> emit) {
    // Drop stragglers from a session whose tail was already committed
    // (race between onStatus('done') and a late final onResult).
    if (e.sessionId != _sessionId) return;
    final base = _committedText.trim();
    final live = e.live.trim();
    final next = base.isEmpty
        ? live
        : (live.isEmpty ? base : '$base $live');
    emit(state.copyWith(
      transcript: next,
      hasFinalResult: state.hasFinalResult || e.isFinal,
    ));
  }

  void _onLevel(VoiceLevelChanged e, Emitter<VoiceBlocState> emit) {
    // speech_to_text reports dB on iOS (dBFS, negative, 0 = loudest) and a
    // device-specific dB-like value on Android (often slightly negative for
    // silence, positive during speech). Shift into a strictly positive range,
    // then run through the adaptive ceiling so peak speech normalizes toward
    // 1.0 regardless of platform calibration.
    final v = math.max(0.0, e.rawLevel + 50.0);
    _levelMax *= 0.99;
    if (v > _levelMax) _levelMax = v;
    if (_levelMax < 8.0) _levelMax = 8.0;
    emit(state.copyWith(soundLevel: (v / _levelMax).clamp(0.0, 1.0)));
  }

  Future<void> _onStatus(
    VoiceStatusChanged e,
    Emitter<VoiceBlocState> emit,
  ) async {
    final shouldRestart = _continuous &&
        !_userStopRequested &&
        state.status == VoiceState.listening;
    if (shouldRestart) {
      // Commit the in-flight tail so the next listen() session can append
      // rather than overwrite (each new listen() starts with empty
      // recognizedWords on the result callback).
      final cur = state.transcript.trim();
      if (cur.isNotEmpty) _committedText = cur;
      // Invalidate any in-flight onResult for the just-stopped session.
      _sessionId++;
      // Brief pause so the platform releases recognizer resources before we
      // re-arm. 150 ms is enough on tested devices and short enough that the
      // user barely notices the gap.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!_continuous ||
          _userStopRequested ||
          state.status != VoiceState.listening) {
        return;
      }
      try {
        await _listenInternal();
      } catch (_) {
        emit(state.copyWith(status: VoiceState.idle, soundLevel: 0.0));
      }
      return;
    }
    _sessionId++;
    if (state.status == VoiceState.listening) {
      emit(state.copyWith(status: VoiceState.idle, soundLevel: 0.0));
    }
  }

  void _onPermissionDenied(
    VoicePermissionDenied e,
    Emitter<VoiceBlocState> emit,
  ) {
    _continuous = false;
    emit(state.copyWith(
      status: VoiceState.permissionDenied,
      soundLevel: 0.0,
    ));
  }

  @override
  Future<void> close() async {
    _userStopRequested = true;
    _continuous = false;
    await _stt.cancel();
    return super.close();
  }
}
