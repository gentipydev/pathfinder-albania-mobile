import 'package:equatable/equatable.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/logic/buddy/chat_message.dart';

class BuddyState extends Equatable {
  const BuddyState({
    this.messages = const [],
    this.isStreaming = false,
    this.lastError,
    this.conversationId,
    this.scopedTrip,
    this.requestedTab,
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
      ];
}

const _sentinel = Object();
