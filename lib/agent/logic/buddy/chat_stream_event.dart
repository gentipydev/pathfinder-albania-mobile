import 'package:travel_buddy/agent/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/agent/domain/entities/trip.dart';
import 'package:travel_buddy/agent/domain/entities/trip_route.dart';
import 'package:travel_buddy/agent/logic/buddy/live_stop.dart';

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

/// Marks the start of a live itinerary on this turn. Carries no payload — the
/// server sends `data: {}` purely as a signal. The client resets its live trip
/// so a new plan can't append onto the previous one, and flips the streaming
/// bubble into itinerary mode.
class ItineraryStreamStartEvent extends ChatStreamEvent {
  const ItineraryStreamStartEvent();
}

/// One geocoded stop, streamed as Claude writes the plan. Drives BOTH the chat
/// row and the live map marker — the same event grows both lists, so the two
/// are correlated by construction rather than by a later join.
class ItineraryStopEvent extends ChatStreamEvent {
  final LiveStop stop;
  const ItineraryStopEvent(this.stop);
}

/// Road-following routes for the live-streamed preview, keyed by the same
/// `live-{day}-{sort}` ids the markers stream under. Merging them onto the live
/// trip upgrades the straight connectors to real roads without re-animating any
/// marker. Best-effort on the server: absent when routing found nothing.
class ItineraryRoutesEvent extends ChatStreamEvent {
  final List<TripRoute> routes;
  const ItineraryRoutesEvent(this.routes);
}

/// Whole-trip fallback, emitted after the stream closes when per-stop streaming
/// surfaced nothing mappable. Server-geocoded, so unlike a draft its stops have
/// real coordinates and can be mapped directly.
class ItineraryPreviewEvent extends ChatStreamEvent {
  final Trip trip;
  const ItineraryPreviewEvent(this.trip);
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
