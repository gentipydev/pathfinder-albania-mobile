import 'package:equatable/equatable.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';
import 'package:pathfinder_albania/agent/logic/buddy/chat_message.dart';

class BuddyState extends Equatable {
  const BuddyState({
    this.messages = const [],
    this.isStreaming = false,
    this.lastError,
    this.conversationId,
    this.scopedTrip,
    this.requestedTab,
    this.liveTrip,
    this.liveTripMessageId,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? lastError;

  /// Server-side conversation pointer. Null = anonymous chat OR a fresh chat
  /// for which the server has not yet emitted an id event. Persisted to
  /// SharedPreferences key `buddy.conversationId` so a returning user
  /// resumes where they left off.
  final String? conversationId;

  /// The trip currently being refined, or null for a regular chat session.
  /// When non-null, every chat send carries `trip_id` so the backend re-injects
  /// fresh trip context on each turn.
  final Trip? scopedTrip;

  /// Itinerary assembled live from `itinerary_stop` frames while a plan
  /// streams, or the server-geocoded `itinerary_preview` fallback. Synthetic:
  /// its id is [kLiveTripId] and it is never persisted — it exists so the
  /// preview can reuse `TripMapScreen`, which speaks [Trip]. Reset on each new
  /// `itinerary_stream_start` so plans don't accumulate.
  final Trip? liveTrip;

  /// Id of the assistant message [liveTrip] belongs to. Only that bubble
  /// offers the map affordance, so an older itinerary bubble can never open a
  /// newer plan's map. (The web client keeps one global `activeTrip` because
  /// its map is a single pane; a per-bubble button needs the owner.)
  final String? liveTripMessageId;

  /// One-shot tab-switch request. AppShell consumes this and dispatches
  /// `BuddyTabConsumed` to clear it.
  final int? requestedTab;

  BuddyState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    Object? lastError = _sentinel,
    Object? conversationId = _sentinel,
    Object? scopedTrip = _sentinel,
    Object? requestedTab = _sentinel,
    Object? liveTrip = _sentinel,
    Object? liveTripMessageId = _sentinel,
  }) {
    return BuddyState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      lastError: identical(lastError, _sentinel)
          ? this.lastError
          : lastError as String?,
      conversationId: identical(conversationId, _sentinel)
          ? this.conversationId
          : conversationId as String?,
      scopedTrip: identical(scopedTrip, _sentinel)
          ? this.scopedTrip
          : scopedTrip as Trip?,
      requestedTab: identical(requestedTab, _sentinel)
          ? this.requestedTab
          : requestedTab as int?,
      liveTrip: identical(liveTrip, _sentinel)
          ? this.liveTrip
          : liveTrip as Trip?,
      liveTripMessageId: identical(liveTripMessageId, _sentinel)
          ? this.liveTripMessageId
          : liveTripMessageId as String?,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isStreaming,
        lastError,
        conversationId,
        scopedTrip,
        requestedTab,
        liveTrip,
        liveTripMessageId,
      ];
}

const _sentinel = Object();
