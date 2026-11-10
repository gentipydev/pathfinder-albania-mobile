import 'package:equatable/equatable.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';
import 'package:travel_buddy/agent/logic/buddy/chat_message.dart';

abstract class BuddyEvent extends Equatable {
  const BuddyEvent();

  @override
  List<Object?> get props => const [];
}

/// Restore `conversationId` from SharedPreferences. Idempotent — bootstrap
/// dispatches once; calling again is a no-op.
class BuddyInitialized extends BuddyEvent {
  const BuddyInitialized();
}

/// Replace the in-memory conversation with hydrated history. Used by
/// `ConversationsScreen` when the user taps a row.
class BuddyConversationLoaded extends BuddyEvent {
  const BuddyConversationLoaded({required this.id, required this.hydrated});
  final String id;
  final List<ChatMessage> hydrated;

  @override
  List<Object?> get props => [id, hydrated];
}

/// Open (or resume) refine chat for the given trip. Resolves the trip's 1:1
/// conversation, hydrates its history, sets `scopedTrip`, and asks AppShell
/// to switch to the Buddy tab via `requestedTab`.
class BuddyOpenRefineRequested extends BuddyEvent {
  const BuddyOpenRefineRequested(this.trip);
  final Trip trip;

  @override
  List<Object?> get props => [trip];
}

/// Drop `scopedTrip` while keeping conversation alive. Subsequent sends will
/// reuse the conversation_id and will not include `trip_id`.
class BuddyRefineModeExited extends BuddyEvent {
  const BuddyRefineModeExited();
}

class BuddySendMessageRequested extends BuddyEvent {
  const BuddySendMessageRequested({
    required this.text,
    this.imageUrls = const [],
  });
  final String text;
  final List<String> imageUrls;

  @override
  List<Object?> get props => [text, imageUrls];
}

class BuddyRetryLastRequested extends BuddyEvent {
  const BuddyRetryLastRequested();
}

/// Reset the entire conversation to a fresh state. AuthBloc dispatches this
/// on logout so the next user starts clean.
class BuddyConversationCleared extends BuddyEvent {
  const BuddyConversationCleared();
}

class BuddyStreamCancelRequested extends BuddyEvent {
  const BuddyStreamCancelRequested();
}

/// Set `state.requestedTab` to a non-null value. AppShell observes via
/// `BlocListener` and dispatches `BuddyTabConsumed` after switching.
class BuddyTabRequested extends BuddyEvent {
  const BuddyTabRequested(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class BuddyTabConsumed extends BuddyEvent {
  const BuddyTabConsumed();
}

/// Fired by `TripsBloc` after a successful `ItinerarySaveRequested` so the
/// originating assistant message can show an inline static-map thumbnail.
/// Carries the assistant message id (which the Save button forwards through
/// the `ItinerarySaveRequested` event) and the freshly-created trip id.
class BuddySavedTripLinked extends BuddyEvent {
  const BuddySavedTripLinked({
    required this.assistantMessageId,
    required this.savedTripId,
  });

  final String assistantMessageId;
  final String savedTripId;

  @override
  List<Object?> get props => [assistantMessageId, savedTripId];
}
