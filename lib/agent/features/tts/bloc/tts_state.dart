import 'package:equatable/equatable.dart';

/// Playback state for a single TTS utterance. Mirrors the legacy enum from
/// the deleted `lib/logic/buddy/tts_logic.dart` so existing imports flip path
/// only.
enum TtsState { idle, loading, speaking }

class TtsBlocState extends Equatable {
  const TtsBlocState({
    this.status = TtsState.idle,
    this.activeMessageId,
  });

  final TtsState status;

  /// The id of the assistant ChatMessage currently being read, or null when
  /// idle. UI uses this to highlight the playing bubble's speaker icon.
  final String? activeMessageId;

  TtsBlocState copyWith({
    TtsState? status,
    Object? activeMessageId = _sentinel,
  }) {
    return TtsBlocState(
      status: status ?? this.status,
      activeMessageId: identical(activeMessageId, _sentinel)
          ? this.activeMessageId
          : activeMessageId as String?,
    );
  }

  @override
  List<Object?> get props => [status, activeMessageId];
}

const _sentinel = Object();
