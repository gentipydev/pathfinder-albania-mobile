import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';
import 'package:pathfinder_albania/agent/logic/buddy/live_stop.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final String id;
  final ChatRole role;
  final DateTime createdAt;
  final String? richKind;
  final Map<String, dynamic>? richData;
  final String content;
  final bool isStreaming;
  final bool hasError;

  /// Set when the backend successfully streamed this assistant reply but
  /// failed to persist it server-side. The text shown is correct; the
  /// conversation list will not contain this turn on next load. UI shows
  /// an inline "not saved" indicator (not an error state — no retry).
  final bool notSaved;

  /// Set when the backend emitted `event: itinerary_invalid` because Claude's
  /// emit_itinerary tool payload failed server-side TripCreate validation.
  /// Bubble renders a soft inline footer; the natural-language reply is
  /// unaffected. Not an error state — no retry CTA.
  final bool itineraryFailed;

  /// Set on the assistant turn that successfully refined a saved trip.
  /// Bubble renders a "✓ Trip updated" footer with a "View trip" link.
  final bool tripRefined;

  /// Set when the backend emitted `event: refine_failed`: Claude produced a
  /// valid itinerary but the server-side replace transaction failed. Trip
  /// state on disk is unchanged. Soft inline footer; not an error state.
  final bool refineFailed;
  final List<String> attachmentUrls;

  /// Set once an `itinerary_stream_start` frame marks this assistant turn as a
  /// live itinerary. The bubble then renders [liveStops] as a structured
  /// per-stop list under the prose instead of parsing the reply as markdown.
  final bool isItinerary;

  /// Grows one entry per `itinerary_stop` frame, in lockstep with the markers
  /// on the live map — the same event drives both. Ordered by day then
  /// sort order. Empty on every non-itinerary turn and on rehydrated history
  /// (the server stores text only).
  final List<LiveStop> liveStops;

  /// Structured itinerary draft attached to this assistant turn when Claude
  /// emitted an `emit_itinerary` tool call. Drives the "Save itinerary" CTA
  /// rendered below the bubble after streaming finishes. Null on every
  /// non-itinerary turn and on rehydrated history (server stores text only).
  final ItineraryDraft? itinerary;

  /// Set on the assistant turn whose `itinerary` draft was successfully
  /// saved as a server-acknowledged Trip. The bubble looks up the live
  /// Trip in TripsState and renders an inline static-map thumbnail. Null
  /// before save (and on rehydrated history — not persisted server-side).
  final String? savedTripId;

  ChatMessage({
    required this.id,
    required this.role,
    DateTime? createdAt,
    this.content = '',
    this.isStreaming = false,
    this.hasError = false,
    this.notSaved = false,
    this.itineraryFailed = false,
    this.tripRefined = false,
    this.refineFailed = false,
    this.richKind,
    this.richData,
    this.attachmentUrls = const [],
    this.isItinerary = false,
    this.liveStops = const [],
    this.itinerary,
    this.savedTripId,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRich => richKind != null && richData != null;

  /// Returns a new ChatMessage with the named fields replaced. Only fields
  /// that buddy_logic mutates today are exposed; constants like `id`, `role`,
  /// `createdAt`, `richKind`, `richData`, and `attachmentUrls` are set at
  /// construction. `itinerary` uses the `_sentinel` pattern so callers can
  /// distinguish "leave unchanged" from "set null" — the 401 retry path needs
  /// to clear it.
  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    bool? hasError,
    bool? notSaved,
    bool? itineraryFailed,
    bool? tripRefined,
    bool? refineFailed,
    bool? isItinerary,
    List<LiveStop>? liveStops,
    Object? itinerary = _sentinel,
    Object? savedTripId = _sentinel,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      createdAt: createdAt,
      richKind: richKind,
      richData: richData,
      attachmentUrls: attachmentUrls,
      content: content ?? this.content,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      notSaved: notSaved ?? this.notSaved,
      itineraryFailed: itineraryFailed ?? this.itineraryFailed,
      tripRefined: tripRefined ?? this.tripRefined,
      refineFailed: refineFailed ?? this.refineFailed,
      isItinerary: isItinerary ?? this.isItinerary,
      liveStops: liveStops ?? this.liveStops,
      itinerary: identical(itinerary, _sentinel)
          ? this.itinerary
          : itinerary as ItineraryDraft?,
      savedTripId: identical(savedTripId, _sentinel)
          ? this.savedTripId
          : savedTripId as String?,
    );
  }
}

const _sentinel = Object();
