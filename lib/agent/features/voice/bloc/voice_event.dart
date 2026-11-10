import 'package:equatable/equatable.dart';

abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => const [];
}

/// Public: start a continuous-listen session. Resets transcript and seeds
/// `_localeId` for the inner `_listenInternal` call.
class VoiceStartRequested extends VoiceEvent {
  const VoiceStartRequested({this.localeId});
  final String? localeId;

  @override
  List<Object?> get props => [localeId];
}

/// Public: user-initiated stop. Returns the recognizer to idle and preserves
/// the accumulated transcript so the caller can read it via `state.transcript`.
class VoiceStopRequested extends VoiceEvent {
  const VoiceStopRequested();
}

/// Public: user-initiated cancel. Resets transcript to empty (unlike stop).
class VoiceCancelRequested extends VoiceEvent {
  const VoiceCancelRequested();
}

/// Internal: STT plugin's `onResult` fired. Carries `sessionId` so a late
/// callback from a prior session is dropped (matches `_sessionId` guard
/// at `voice_logic.dart:131`).
class VoiceResultReceived extends VoiceEvent {
  const VoiceResultReceived({
    required this.live,
    required this.isFinal,
    required this.sessionId,
  });
  final String live;
  final bool isFinal;
  final int sessionId;

  @override
  List<Object?> get props => [live, isFinal, sessionId];
}

/// Internal: STT plugin's `onSoundLevelChange` fired. Raw platform value;
/// the bloc applies `_onSoundLevel` normalization before emitting.
class VoiceLevelChanged extends VoiceEvent {
  const VoiceLevelChanged(this.rawLevel);
  final double rawLevel;

  @override
  List<Object?> get props => [rawLevel];
}

/// Internal: STT plugin's `onStatus` fired with one of `notListening`/`done`.
/// Triggers the continuous-listen restart logic.
class VoiceStatusChanged extends VoiceEvent {
  const VoiceStatusChanged(this.platformStatus);
  final String platformStatus;

  @override
  List<Object?> get props => [platformStatus];
}

/// Internal: STT plugin's `onError` fired with `errorMsg == 'error_permission'`.
/// Other errors are absorbed silently — the engine fires `done` shortly after,
/// which routes through `VoiceStatusChanged`.
class VoicePermissionDenied extends VoiceEvent {
  const VoicePermissionDenied();
}
