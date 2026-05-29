import 'package:travel_buddy/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/domain/entities/trip.dart';

sealed class ChatStreamEvent {
  const ChatStreamEvent();
}

class TextDelta extends ChatStreamEvent {
  final String text;
  const TextDelta(this.text);
}

class StreamError extends ChatStreamEvent {
  final String message;
  final int? statusCode;
  const StreamError(this.message, {this.statusCode});
}

/// Server returned HTTP 429 — the request never opened an SSE stream.
/// Distinct from [StreamError] so the UI can render a soft "slow down for
/// a moment" inline indicator instead of a generic error footer, and so a
/// future auto-retry can wait `retryAfter` seconds before re-firing.
/// `retryAfter` is parsed from the `Retry-After` response header; falls
/// back to 60s when the header is missing or unparseable.
class RateLimitedEvent extends ChatStreamEvent {
  final Duration retryAfter;
  const RateLimitedEvent({this.retryAfter = const Duration(seconds: 60)});
}

class StreamDone extends ChatStreamEvent {
  const StreamDone();
}

class PlaceCardEvent extends ChatStreamEvent {
  final Map<String, dynamic> data;
  const PlaceCardEvent(this.data);
}

class ConversationIdEvent extends ChatStreamEvent {
  final String id;
  const ConversationIdEvent(this.id);
}

/// Server replied successfully but failed to persist the assistant message.
/// The text already streamed to the client is fine; only the durable copy is
/// missing. UI marks the bubble as "not saved" inline — no error retry needed.
class PersistFailed extends ChatStreamEvent {
  const PersistFailed();
}

/// Structured itinerary payload from the `emit_itinerary` tool. Lands once,
/// after the text stream completes but before [StreamDone]. The buddy logic
/// attaches the draft to the asst message it streamed in; the chat UI shows
/// a "Save itinerary" button on that bubble after streaming finishes.
class ItineraryStreamEvent extends ChatStreamEvent {
  final ItineraryDraft draft;
  const ItineraryStreamEvent(this.draft);
}

/// Server attempted to emit a structured itinerary but the tool payload
/// failed Pydantic validation against TripCreate. The natural-language reply
/// already streamed and remains visible; the bubble shows a soft inline
/// footer instead of a Save CTA. `reason` is for debug logs only — it is
/// never surfaced to the user.
class ItineraryInvalidStreamEvent extends ChatStreamEvent {
  final String reason;
  const ItineraryInvalidStreamEvent(this.reason);
}

/// Refine-with-Buddy success: the server applied the validated itinerary to
/// the saved trip in-place and is shipping back the canonical post-replace
/// `Trip` JSON. Lands once per refine turn, in the same SSE position the
/// non-refine path emits `event: itinerary`. The buddy logic feeds the trip
/// to `tripsLogic.mergeTrip` and flips an inline "✓ Trip updated" indicator
/// on the assistant message.
class TripRefinedStreamEvent extends ChatStreamEvent {
  final Trip trip;
  const TripRefinedStreamEvent(this.trip);
}

/// Refine-with-Buddy failure: Claude emitted a valid itinerary but the
/// server-side replace transaction failed. The natural-language reply
/// already streamed and stays visible; the bubble shows a soft footer
/// indicating the change wasn't applied. The trip on disk is unchanged.
class RefineFailedStreamEvent extends ChatStreamEvent {
  final String reason;
  const RefineFailedStreamEvent(this.reason);
}
