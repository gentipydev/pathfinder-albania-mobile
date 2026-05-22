import 'dart:async';
import 'dart:io' show Platform;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:travel_buddy/features/tts/bloc/tts_event.dart';
import 'package:travel_buddy/features/tts/bloc/tts_state.dart';

/// Bloc replacement for the legacy `TtsLogic`. flutter_tts is fully owned by
/// the bloc; UI drives playback via `TtsSpeakRequested` / `TtsStopRequested`
/// and observes `state.status` / `state.activeMessageId`.
class TtsBloc extends Bloc<TtsEvent, TtsBlocState> {
  TtsBloc({FlutterTts? tts})
      : _tts = tts ?? FlutterTts(),
        super(const TtsBlocState()) {
    // restartable() — `_onSpeak` calls `_tts.stop()` before `_tts.speak()`,
    // matching today's "second tap = restart" behavior. If the user taps
    // a different message while one is playing, the new one wins.
    on<TtsSpeakRequested>(_onSpeak, transformer: restartable());
    on<TtsStopRequested>(_onStop, transformer: droppable());
    on<TtsStarted>(_onStarted);
    on<TtsFinishedOk>(_onFinishedOk);
    on<TtsCancelledByEngine>(_onCancelledByEngine);
    on<TtsErroredByEngine>(_onErroredByEngine);
  }

  final FlutterTts _tts;
  bool _initialized = false;
  String? _appliedLanguage;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    if (!kIsWeb && Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
      );
    }
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() => add(const TtsStarted()));
    _tts.setCompletionHandler(() => add(const TtsFinishedOk()));
    _tts.setCancelHandler(() => add(const TtsCancelledByEngine()));
    _tts.setErrorHandler((_) => add(const TtsErroredByEngine()));
  }

  Future<void> _onSpeak(TtsSpeakRequested e, Emitter<TtsBlocState> emit) async {
    await _ensureInit();
    await _tts.stop();
    final clean = _strip(e.text);
    if (clean.isEmpty) return;

    final lang = await _resolveLanguage([
      if (e.localeId != null && e.localeId!.isNotEmpty) e.localeId!,
      ...e.fallbackLocales,
    ]);
    if (lang != null && lang != _appliedLanguage) {
      await _tts.setLanguage(lang);
      _appliedLanguage = lang;
    }

    emit(state.copyWith(
      status: TtsState.loading,
      activeMessageId: e.messageId,
    ));
    await _tts.speak(clean);
  }

  Future<void> _onStop(TtsStopRequested e, Emitter<TtsBlocState> emit) async {
    await _tts.stop();
    emit(const TtsBlocState());
  }

  void _onStarted(TtsStarted e, Emitter<TtsBlocState> emit) =>
      emit(state.copyWith(status: TtsState.speaking));

  void _onFinishedOk(TtsFinishedOk e, Emitter<TtsBlocState> emit) =>
      emit(const TtsBlocState());

  void _onCancelledByEngine(
    TtsCancelledByEngine e,
    Emitter<TtsBlocState> emit,
  ) =>
      emit(const TtsBlocState());

  void _onErroredByEngine(
    TtsErroredByEngine e,
    Emitter<TtsBlocState> emit,
  ) =>
      emit(const TtsBlocState());

  Future<String?> _resolveLanguage(List<String> candidates) async {
    for (final c in candidates) {
      try {
        final available = await _tts.isLanguageAvailable(c);
        if (available == true) return c;
      } catch (_) {
        // platform may throw on unsupported tag — try next
      }
    }
    return null;
  }

  /// Strip markdown so the engine reads cleanly.
  String _strip(String s) {
    return s
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), ' ')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'^\s*[#>\-*]+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'[*_~]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Future<void> close() async {
    await _tts.stop();
    return super.close();
  }
}
