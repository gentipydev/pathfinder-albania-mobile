import 'package:travel_buddy/domain/entities/itinerary_draft.dart';

enum ChatRole { user, assistant }

/// One retrieved RAG chunk surfaced to the user as provenance. The backend
/// sends a list of these on `event: rag_sources` for a grounded turn; the
/// assistant bubble renders them behind an "N sources" chip. `title` is a
/// short source label (place name / contextual header); `snippet` is the
/// first line of the chunk content.
class RagSource {
  final String title;
  final String snippet;
  const RagSource({required this.title, required this.snippet});

  factory RagSource.fromJson(Map<String, dynamic> json) => RagSource(
        title: (json['title'] as String?)?.trim() ?? '',
        snippet: (json['snippet'] as String?)?.trim() ?? '',
      );
}

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

  /// RAG provenance for a grounded assistant turn, from `event: rag_sources`.
  /// Drives the "N sources" chip rendered below the bubble after streaming
  /// finishes. Null on ungrounded turns and on rehydrated history (the server
  /// stores message text only, so the chip is live-turn ephemeral).
  final List<RagSource>? ragSources;

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
    this.itinerary,
    this.savedTripId,
    this.ragSources,
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
    Object? itinerary = _sentinel,
    Object? savedTripId = _sentinel,
    Object? ragSources = _sentinel,
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
      itinerary: identical(itinerary, _sentinel)
          ? this.itinerary
          : itinerary as ItineraryDraft?,
      savedTripId: identical(savedTripId, _sentinel)
          ? this.savedTripId
          : savedTripId as String?,
      ragSources: identical(ragSources, _sentinel)
          ? this.ragSources
          : ragSources as List<RagSource>?,
    );
  }
}

const _sentinel = Object();
