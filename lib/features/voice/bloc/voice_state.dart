import 'package:equatable/equatable.dart';

/// Mirror of the legacy enum from `lib/logic/buddy/voice_logic.dart`.
enum VoiceState {
  idle,
  unavailable,
  permissionDenied,
  listening,
}

class VoiceBlocState extends Equatable {
  const VoiceBlocState({
    this.status = VoiceState.idle,
    this.transcript = '',
    this.soundLevel = 0.0,
    this.hasFinalResult = false,
  });

  final VoiceState status;

  /// Live recognized text, including any committed tail from prior recognizer
  /// sessions in the same logical listen — see `_committedText` on the bloc.
  final String transcript;

  /// Adaptive-normalized amplitude in [0.0, 1.0]. Drives the SiriWaveform
  /// in `voice_dictation_strip.dart`.
  final double soundLevel;

  /// Flips true the first time the platform engine reports `result.finalResult`
  /// during this session. Some screens use this to gate auto-actions (e.g.
  /// only auto-submit a dictated message after a final result lands).
  final bool hasFinalResult;

  VoiceBlocState copyWith({
    VoiceState? status,
    String? transcript,
    double? soundLevel,
    bool? hasFinalResult,
  }) {
    return VoiceBlocState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      soundLevel: soundLevel ?? this.soundLevel,
      hasFinalResult: hasFinalResult ?? this.hasFinalResult,
    );
  }

  @override
  List<Object?> get props => [status, transcript, soundLevel, hasFinalResult];
}
