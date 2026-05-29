import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_buddy/features/auth/bloc/auth_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_state.dart';
import 'package:travel_buddy/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/features/tts/bloc/tts_bloc.dart';
import 'package:travel_buddy/features/tts/bloc/tts_event.dart';
import 'package:travel_buddy/logic/buddy/chat_message.dart';
import 'package:travel_buddy/logic/buddy/chat_service.dart';
import 'package:travel_buddy/logic/buddy/chat_stream_event.dart';
import 'package:travel_buddy/logic/buddy/conversations_service.dart';
import 'package:travel_buddy/utils/dlog.dart';

/// Bloc replacement for the legacy `BuddyLogic`. Owns chat history, the SSE
/// pump (with 401 token refresh), and the refine-with-buddy flow.
///
/// SSE pump uses a manual `StreamSubscription` + `Completer` rather than
/// `emit.onEach`, because the 401 retry path needs to cancel the current
/// stream and re-subscribe with a fresh token inside the same handler — a
/// pattern `emit.onEach` does not support.
class BuddyBloc extends Bloc<BuddyEvent, BuddyState> {
  BuddyBloc({
    required ChatService service,
    ConversationsService Function()? conversationsServiceProvider,
    String? Function()? tokenReader,
    AuthBloc Function()? authBlocProvider,
    TripsBloc Function()? tripsBlocProvider,
    TtsBloc Function()? ttsBlocProvider,
  })  : _service = service,
        _conversationsServiceProvider = conversationsServiceProvider ??
            (() => GetIt.I<ConversationsService>()),
        _tokenReader = tokenReader ??
            (() => Supabase.instance.client.auth.currentSession?.accessToken),
        _authBlocProvider = authBlocProvider ?? (() => GetIt.I<AuthBloc>()),
        _tripsBlocProvider = tripsBlocProvider ?? (() => GetIt.I<TripsBloc>()),
        _ttsBlocProvider = ttsBlocProvider ?? (() => GetIt.I<TtsBloc>()),
        super(const BuddyState()) {
    on<BuddyInitialized>(_onInitialized, transformer: droppable());
    on<BuddyConversationLoaded>(
      _onConversationLoaded,
      transformer: sequential(),
    );
    on<BuddyOpenRefineRequested>(_onOpenRefine, transformer: restartable());
    on<BuddyRefineModeExited>(_onRefineModeExited);
    on<BuddySendMessageRequested>(_onSendMessage, transformer: droppable());
    on<BuddyRetryLastRequested>(_onRetryLast, transformer: droppable());
    on<BuddyConversationCleared>(
      _onConversationCleared,
      transformer: sequential(),
    );
    on<BuddyStreamCancelRequested>(_onStreamCancel, transformer: droppable());
    on<BuddyTabRequested>(_onTabRequested);
    on<BuddyTabConsumed>(_onTabConsumed);
    on<BuddySavedTripLinked>(_onSavedTripLinked);
  }

  static const String _kConversationIdKey = 'buddy.conversationId';

  final ChatService _service;
  final ConversationsService Function() _conversationsServiceProvider;
  final String? Function() _tokenReader;
  final AuthBloc Function() _authBlocProvider;
  final TripsBloc Function() _tripsBlocProvider;
  final TtsBloc Function() _ttsBlocProvider;

  StreamSubscription<ChatStreamEvent>? _sub;
  final _uuid = const Uuid();
  String? _lastUserText;
  bool _initialized = false;

  // -------------------- handlers --------------------

  Future<void> _onInitialized(
    BuddyInitialized e,
    Emitter<BuddyState> emit,
  ) async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kConversationIdKey);
    if (id != null && id.isNotEmpty) {
      emit(state.copyWith(conversationId: id));
    }
  }

  Future<void> _onConversationLoaded(
    BuddyConversationLoaded e,
    Emitter<BuddyState> emit,
  ) async {
    await _sub?.cancel();
    _sub = null;
    _lastUserText = null;
    emit(state.copyWith(
      messages: List.unmodifiable(e.hydrated),
      isStreaming: false,
      lastError: null,
      conversationId: e.id,
      // A reload is by definition a non-scoped session — the user picked a
      // conversation from the history list, not "Refine with Buddy".
      scopedTrip: null,
    ));
    await _persistConversationId(e.id);
  }

  Future<void> _onOpenRefine(
    BuddyOpenRefineRequested e,
    Emitter<BuddyState> emit,
  ) async {
    await _sub?.cancel();
    _sub = null;
    _lastUserText = null;

    try {
      final token = _tokenReader();
      final convsSvc = _conversationsServiceProvider();
      final ref =
          await convsSvc.getOrCreateForTrip(e.trip.id, bearerToken: token);
      final hydrated = await convsSvc.get(ref.id, bearerToken: token);
      emit(state.copyWith(
        messages: List.unmodifiable(hydrated),
        isStreaming: false,
        lastError: null,
        conversationId: ref.id,
        scopedTrip: e.trip,
        // Trigger AppShell's tab consume.
        requestedTab: 1,
      ));
      unawaited(_persistConversationId(ref.id));
    } catch (err, st) {
      dlog('refine open failed',
          name: 'buddy.refine', error: err, stackTrace: st);
      emit(state.copyWith(lastError: '$err'));
    }
  }

  void _onRefineModeExited(
    BuddyRefineModeExited e,
    Emitter<BuddyState> emit,
  ) {
    emit(state.copyWith(scopedTrip: null));
  }

  Future<void> _onSendMessage(
    BuddySendMessageRequested e,
    Emitter<BuddyState> emit,
  ) async {
    final trimmed = e.text.trim();
    // Belt-and-suspenders alongside `droppable()` — guards events queued
    // inside the same microtask before the transformer registered the first.
    if (state.isStreaming) return;
    if (trimmed.isEmpty && e.imageUrls.isEmpty) return;
    _lastUserText = trimmed;

    final user = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: trimmed,
      attachmentUrls: List.unmodifiable(e.imageUrls),
    );
    final asst = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      isStreaming: true,
    );
    emit(state.copyWith(
      messages: [...state.messages, user, asst],
      isStreaming: true,
      lastError: null,
    ));

    await _consumeStream(
      text: trimmed,
      asstId: asst.id,
      imageUrls: e.imageUrls,
      allowRefreshRetry: true,
      emit: emit,
    );
  }

  Future<void> _onRetryLast(
    BuddyRetryLastRequested e,
    Emitter<BuddyState> emit,
  ) async {
    if (_lastUserText == null || state.isStreaming) return;
    final list = [...state.messages];
    if (list.isNotEmpty &&
        list.last.role == ChatRole.assistant &&
        list.last.hasError) {
      list.removeLast();
    }
    final asst = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.assistant,
      isStreaming: true,
    );
    emit(state.copyWith(
      messages: [...list, asst],
      isStreaming: true,
      lastError: null,
    ));
    // Note: retry re-sends text only; prior-turn images are not re-attached.
    await _consumeStream(
      text: _lastUserText!,
      asstId: asst.id,
      imageUrls: const [],
      allowRefreshRetry: true,
      emit: emit,
    );
  }

  Future<void> _onConversationCleared(
    BuddyConversationCleared e,
    Emitter<BuddyState> emit,
  ) async {
    await _sub?.cancel();
    _sub = null;
    _lastUserText = null;
    emit(const BuddyState());
    unawaited(_persistConversationId(null));
  }

  Future<void> _onStreamCancel(
    BuddyStreamCancelRequested e,
    Emitter<BuddyState> emit,
  ) async {
    if (!state.isStreaming) return;
    await _sub?.cancel();
    _sub = null;
    final list = List.of(state.messages);
    if (list.isNotEmpty && list.last.isStreaming) {
      list[list.length - 1] = list.last.copyWith(isStreaming: false);
    }
    emit(state.copyWith(
      messages: list,
      isStreaming: false,
      lastError: null,
    ));
  }

  void _onTabRequested(BuddyTabRequested e, Emitter<BuddyState> emit) {
    emit(state.copyWith(requestedTab: e.index));
  }

  void _onTabConsumed(BuddyTabConsumed e, Emitter<BuddyState> emit) {
    emit(state.copyWith(requestedTab: null));
  }

  void _onSavedTripLinked(
    BuddySavedTripLinked e,
    Emitter<BuddyState> emit,
  ) {
    // Mirror of TripRefinedStreamEvent's pattern but in the opposite
    // direction: TripsBloc dispatches this after `_onItinerarySave` succeeds
    // so the originating assistant bubble can resolve its saved Trip via
    // BlocSelector and render the inline static-map thumbnail. No-op when
    // the message has been cleared (history loaded or conversation reset).
    final patched = _patchById(
      state.messages,
      e.assistantMessageId,
      (m) => m.copyWith(savedTripId: e.savedTripId),
    );
    if (identical(patched, state.messages)) return;
    emit(state.copyWith(messages: patched));
  }

  // -------------------- SSE pump --------------------

  Future<void> _consumeStream({
    required String text,
    required String asstId,
    required List<String> imageUrls,
    required bool allowRefreshRetry,
    required Emitter<BuddyState> emit,
  }) async {
    final completer = Completer<void>();
    bool retried = false;
    late StreamSubscription<ChatStreamEvent> sub;
    sub = _service
        .stream(
          message: text,
          conversationId: state.conversationId,
          bearerToken: _tokenReader(),
          imageUrls: imageUrls.isEmpty ? null : imageUrls,
          tripId: state.scopedTrip?.id,
        )
        .listen(
      (evt) async {
        if (emit.isDone) return;

        if (evt is StreamError &&
            evt.statusCode == 401 &&
            allowRefreshRetry &&
            !retried) {
          retried = true;
          await sub.cancel();
          final newToken = await _authBlocProvider().refreshAccessToken();
          if (newToken != null) {
            // Reset transient inline-state flags so a successful retry does
            // not surface a stale failure footer from the prior attempt.
            emit(_resetAsstFlagsForRetry(state, asstId));
            await _consumeStream(
              text: text,
              asstId: asstId,
              imageUrls: imageUrls,
              allowRefreshRetry: false,
              emit: emit,
            );
            if (!completer.isCompleted) completer.complete();
            return;
          }
          // Refresh failed — fall through to the normal error path.
          emit(_applyTerminalError(state, asstId, evt.message, evt.statusCode));
          if (!completer.isCompleted) completer.complete();
          return;
        }

        _applyEvent(evt, asstId, emit);
        if (evt is StreamDone ||
            evt is StreamError ||
            evt is RateLimitedEvent) {
          if (!completer.isCompleted) completer.complete();
        }
      },
      onError: (err) {
        if (!emit.isDone) {
          dlog('stream onError: $err', name: 'buddy.stream', error: err);
          emit(_applyOnErrorCallback(state, asstId, err));
        }
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );
    _sub = sub;
    await completer.future;
  }

  void _applyEvent(
    ChatStreamEvent evt,
    String asstId,
    Emitter<BuddyState> emit,
  ) {
    switch (evt) {
      case ConversationIdEvent(:final id):
        // Server emits this once when it auto-creates a conversation.
        // Persist immediately so a crash mid-stream doesn't orphan the
        // conversation from the client's point of view.
        emit(state.copyWith(conversationId: id));
        unawaited(_persistConversationId(id));
      case TextDelta(:final text):
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(content: m.content + text),
          ),
        ));
      case PersistFailed():
        // Reply rendered fine; server just failed to save it. Mark inline
        // so the bubble can show a subtle "not saved" indicator.
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(notSaved: true),
          ),
        ));
      case PlaceCardEvent(:final data):
        final list = List.of(state.messages);
        final idx = list.indexWhere((m) => m.id == asstId);
        final asst = idx >= 0 ? list[idx] : null;
        if (asst != null) {
          final card = ChatMessage(
            id: _uuid.v4(),
            role: ChatRole.assistant,
            richKind: 'place_card',
            richData: data,
            createdAt:
                asst.createdAt.subtract(const Duration(microseconds: 1)),
          );
          // Insert card BEFORE the streaming assistant message so visual
          // order is [user, card, asst].
          list.insert(idx, card);
        }
        emit(state.copyWith(messages: list));
      case ItineraryStreamEvent(:final draft):
        // Attach the draft to the asst message itself — the Save CTA renders
        // on this bubble after [StreamDone] flips isStreaming.
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(itinerary: draft),
          ),
        ));
      case ItineraryInvalidStreamEvent(:final reason):
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(itineraryFailed: true),
          ),
        ));
        dlog('itinerary_invalid: $reason', name: 'buddy.stream');
      case TripRefinedStreamEvent(:final trip):
        // Backend already applied the change — feed the canonical post-replace
        // Trip into the trips store and flip the bubble flag so the UI renders
        // the "✓ Trip updated" footer.
        _tripsBlocProvider().add(TripMerged(trip));
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(tripRefined: true),
          ),
        ));
      case RefineFailedStreamEvent(:final reason):
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(refineFailed: true),
          ),
        ));
        dlog('refine_failed: $reason', name: 'buddy.stream');
      case StreamError(:final message, :final statusCode):
        dlog('stream error status=$statusCode: $message',
            name: 'buddy.stream');
        emit(_applyTerminalError(state, asstId, message, statusCode));
      case RateLimitedEvent(:final retryAfter):
        // 429 from the server — request never opened a stream. Friendly
        // copy, no auto-retry (user re-taps). Surface retry_after so the
        // UI can size any countdown / disabled-send state.
        dlog('rate limited, retry_after=${retryAfter.inSeconds}s',
            name: 'buddy.stream', level: LogLevel.warning);
        final secs = retryAfter.inSeconds;
        final friendly = secs > 90
            ? 'You are sending messages too quickly. Try again in a minute.'
            : 'You are sending messages too quickly. Try again in $secs seconds.';
        emit(_applyTerminalError(state, asstId, friendly, 429));
      case StreamDone():
        emit(state.copyWith(
          messages: _patchById(
            state.messages,
            asstId,
            (m) => m.copyWith(isStreaming: false),
          ),
          isStreaming: false,
        ));
    }
  }

  BuddyState _resetAsstFlagsForRetry(BuddyState s, String asstId) {
    return s.copyWith(
      messages: _patchById(
        s.messages,
        asstId,
        (m) => m.copyWith(content: '', itineraryFailed: false, notSaved: false),
      ),
    );
  }

  BuddyState _applyTerminalError(
    BuddyState s,
    String asstId,
    String message,
    int? statusCode,
  ) {
    final messages = _patchById(
      s.messages,
      asstId,
      (m) => m.copyWith(hasError: true, isStreaming: false),
    );
    var next = s.copyWith(
      messages: messages,
      isStreaming: false,
      lastError: message,
    );
    // Trip-deleted edge case: in scoped mode a 404 on chat send means the
    // trip no longer exists server-side. Drop scoped mode and surface via
    // the trips banner.
    if (statusCode == 404 && next.scopedTrip != null) {
      _tripsBlocProvider()
          .add(const TripsErrorSurfaced('This trip no longer exists.'));
      next = next.copyWith(scopedTrip: null);
    }
    return next;
  }

  BuddyState _applyOnErrorCallback(
    BuddyState s,
    String asstId,
    Object err,
  ) {
    final messages = _patchById(
      s.messages,
      asstId,
      (m) => m.copyWith(hasError: true, isStreaming: false),
    );
    return s.copyWith(
      messages: messages,
      isStreaming: false,
      lastError: '$err',
    );
  }

  List<ChatMessage> _patchById(
    List<ChatMessage> list,
    String id,
    ChatMessage Function(ChatMessage) patch,
  ) {
    final i = list.indexWhere((m) => m.id == id);
    if (i == -1) return list;
    final out = List.of(list);
    out[i] = patch(list[i]);
    return out;
  }

  // -------------------- prefs persistence --------------------

  Future<void> _persistConversationId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await prefs.remove(_kConversationIdKey);
    } else {
      await prefs.setString(_kConversationIdKey, id);
    }
  }

  // -------------------- lifecycle --------------------

  @override
  Future<void> close() async {
    await _sub?.cancel();
    if (GetIt.I.isRegistered<TtsBloc>()) {
      _ttsBlocProvider().add(const TtsStopRequested());
    }
    return super.close();
  }
}
