
import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_state.dart';
import 'package:travel_buddy/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/features/tts/bloc/tts_bloc.dart';
import 'package:travel_buddy/features/tts/bloc/tts_event.dart';
import 'package:travel_buddy/features/tts/bloc/tts_state.dart';
import 'package:travel_buddy/features/voice/bloc/voice_bloc.dart';
import 'package:travel_buddy/features/voice/bloc/voice_event.dart';
import 'package:travel_buddy/features/voice/bloc/voice_state.dart';
import 'package:travel_buddy/logic/buddy/attachment.dart';
import 'package:travel_buddy/logic/buddy/attachment_service.dart';
import 'package:travel_buddy/logic/buddy/chat_message.dart';
import 'package:travel_buddy/logic/buddy/place_card.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/services/trip_service.dart';
import 'package:travel_buddy/services/user_service.dart';
import 'package:travel_buddy/ui/common/centered_box.dart';
import 'package:travel_buddy/ui/common/themed_date_picker.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/attach_button.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/attachment_strip.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/itinerary_map_thumbnail.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/place_card.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/voice_button.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/voice_dictation_strip.dart';
import 'package:travel_buddy/ui/screens/trip_map/trip_map_screen.dart';
import 'package:travel_buddy/utils/dlog.dart';

class BuddyScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  BuddyScreen({super.key});

  @override
  State<BuddyScreen> createState() => _BuddyScreenState();
}

class _BuddyScreenState extends State<BuddyScreen> with GetItStateMixin {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<PendingAttachment> _attachments = [];
  final _uuid = const Uuid();

  /// Whatever was already in the text field at the moment dictation started.
  /// New transcript is appended to this so users can dictate after typing
  /// a partial message (or vice-versa).
  String _voicePrefix = '';
  VoiceState _lastVoiceState = VoiceState.idle;

  @override
  void initState() {
    super.initState();
    _lastVoiceState = GetIt.I<VoiceBloc>().state.status;
  }

  @override
  void dispose() {
    final voice = GetIt.I<VoiceBloc>();
    if (voice.state.status == VoiceState.listening) {
      voice.add(const VoiceCancelRequested());
    }
    GetIt.I<TtsBloc>().add(const TtsStopRequested());
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Driven by `BlocListener<VoiceBloc>` in `build`. Combines the old
  /// `_onVoiceStateChanged` (capture composer prefix on idle→listening) and
  /// `_onTranscript` (stream live transcript into composer) into one call —
  /// both used to be ValueNotifier listeners on separate fields.
  void _onVoiceChange(BuildContext _, VoiceBlocState s) {
    if (_lastVoiceState != VoiceState.listening &&
        s.status == VoiceState.listening) {
      _voicePrefix = _composer.text.trimRight();
    }
    _lastVoiceState = s.status;

    if (s.status != VoiceState.listening) return;
    final live = s.transcript.trim();
    final base = _voicePrefix;
    final composed = base.isEmpty
        ? live
        : (live.isEmpty ? base : '$base $live');
    if (_composer.text != composed) {
      _composer.text = composed;
      _composer.selection =
          TextSelection.collapsed(offset: _composer.text.length);
    }
  }

  Future<void> _uploadAttachment(PendingAttachment att, XFile file) async {
    debugPrint(
        '[BuddyScreen] _uploadAttachment: id=${att.id} path=${file.path}');
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('[BuddyScreen] currentUser=${user?.id ?? 'null'}');
    if (user == null) {
      debugPrint('[BuddyScreen] aborting upload — currentUser is null');
      if (!mounted) return;
      setState(() {
        att.status = AttachmentStatus.failed;
        att.errorMessage = $strings.buddyAttachFailed;
      });
      return;
    }
    try {
      final url =
          await GetIt.I<AttachmentService>().upload(file, userId: user.id);
      if (!mounted) return;
      setState(() {
        att.status = AttachmentStatus.ready;
        att.remoteUrl = url;
      });
    } catch (err, st) {
      debugPrint('[BuddyScreen] upload failed: $err');
      dlog(
        'Attachment upload failed',
        name: 'BuddyScreen',
        error: err,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() {
        att.status = AttachmentStatus.failed;
        att.errorMessage = switch (err) {
          AttachmentException(reason: AttachmentRejectReason.tooLarge) =>
            $strings.buddyAttachSizeError,
          AttachmentException(reason: AttachmentRejectReason.unsupportedFormat) =>
            $strings.buddyAttachFormatError,
          _ => $strings.buddyAttachFailed,
        };
      });
    }
  }

  void _handlePicked(XFile file) {
    debugPrint(
        '[BuddyScreen] _handlePicked: path=${file.path} existing=${_attachments.length}');
    if (_attachments.isNotEmpty) return;
    final att = PendingAttachment(id: _uuid.v4(), localPath: file.path);
    setState(() => _attachments.add(att));
    _uploadAttachment(att, XFile(file.path));
  }

  void _handleRemove(String id) {
    setState(() => _attachments.removeWhere((a) => a.id == id));
  }

  void _handleRetry(String id) {
    final idx = _attachments.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    final old = _attachments[idx];
    final fresh = PendingAttachment(id: old.id, localPath: old.localPath);
    setState(() => _attachments[idx] = fresh);
    _uploadAttachment(fresh, XFile(fresh.localPath));
  }

  Future<void> _sendCurrent() async {
    // If still listening, stop first so the recognizer flushes its final
    // tail into _composer.text via the transcript listener before we read it.
    final voice = context.read<VoiceBloc>();
    if (voice.state.status == VoiceState.listening) {
      voice.add(const VoiceStopRequested());
      final s = await voice.stream
          .firstWhere((s) => s.status != VoiceState.listening);
      if (!mounted) return;
      final finalText = s.transcript.trim();
      // Defensive: if the BlocListener's microtask hasn't run yet, write the
      // composed text ourselves so we never submit a stale value.
      final composed = _voicePrefix.isEmpty
          ? finalText
          : (finalText.isEmpty
              ? _voicePrefix
              : '$_voicePrefix $finalText');
      if (_composer.text != composed) {
        _composer.text = composed;
      }
    }
    final text = _composer.text;
    final readyUrls = _attachments
        .where((a) => a.status == AttachmentStatus.ready && a.remoteUrl != null)
        .map((a) => a.remoteUrl!)
        .toList(growable: false);
    if (text.trim().isEmpty && readyUrls.isEmpty) return;
    context.read<BuddyBloc>().add(
          BuddySendMessageRequested(text: text, imageUrls: readyUrls),
        );
    _composer.clear();
    setState(_attachments.clear);
  }

  void _sendQuick(String text) {
    context.read<BuddyBloc>().add(BuddySendMessageRequested(text: text));
  }

  @override
  Widget build(BuildContext context) {
    // Each region subscribes to only the slice of BuddyState it needs, so a
    // per-token `messages` change rebuilds the message list alone — never the
    // header or composer. The composer reacts to its own controller for the
    // send-button state, so typing doesn't rebuild the list either.
    return BlocListener<VoiceBloc, VoiceBlocState>(
      listenWhen: (a, b) =>
          a.status != b.status || a.transcript != b.transcript,
      listener: _onVoiceChange,
      child: Scaffold(
        backgroundColor: $styles.colors.black,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _Header(),
              BlocSelector<BuddyBloc, BuddyState, Trip?>(
                selector: (s) => s.scopedTrip,
                builder: (ctx, scopedTrip) => scopedTrip == null
                    ? const SizedBox.shrink()
                    : _RefineBanner(trip: scopedTrip),
              ),
              Expanded(
                child: BlocSelector<BuddyBloc, BuddyState,
                    ({List<ChatMessage> messages, Trip? scopedTrip})>(
                  selector: (s) =>
                      (messages: s.messages, scopedTrip: s.scopedTrip),
                  builder: (ctx, data) => data.messages.isEmpty
                      ? _BuddyWelcome(
                          onPick: _sendQuick,
                          scopedTrip: data.scopedTrip,
                        )
                      : _MessageList(
                          messages: data.messages,
                          scroll: _scroll,
                        ),
                ),
              ),
              const VoiceDictationStrip(),
              BlocSelector<BuddyBloc, BuddyState,
                  ({bool isStreaming, Trip? scopedTrip})>(
                selector: (s) =>
                    (isStreaming: s.isStreaming, scopedTrip: s.scopedTrip),
                builder: (ctx, data) => _Composer(
                  controller: _composer,
                  attachments: _attachments,
                  isStreaming: data.isStreaming,
                  hintText: data.scopedTrip != null
                      ? $strings.refineComposerHint
                      : $strings.buddyComposerHint,
                  onSend: _sendCurrent,
                  onCancel: () => context
                      .read<BuddyBloc>()
                      .add(const BuddyStreamCancelRequested()),
                  onPicked: _handlePicked,
                  onRemoveAttachment: _handleRemove,
                  onRetryAttachment: _handleRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.md,
        vertical: $styles.insets.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: $styles.colors.greyStrong),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: $styles.colors.accent1.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.travel_explore,
              color: $styles.colors.accent1,
              size: 20,
            ),
          ),
          Gap($styles.insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  $strings.buddyHeaderTitle,
                  style: $styles.text.bodyBold.copyWith(
                    color: $styles.colors.offWhite,
                  ),
                ),
                Text(
                  $strings.buddyHeaderSubtitle,
                  style: $styles.text.caption.copyWith(
                    color: $styles.colors.greyMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: $strings.buddyHistoryTooltip,
            icon: Icon(Icons.history, color: $styles.colors.offWhite),
            onPressed: () => context.push(ScreenPaths.conversations),
          ),
          IconButton(
            tooltip: $strings.buddyNewChatTooltip,
            icon: Icon(Icons.edit_outlined, color: $styles.colors.offWhite),
            onPressed: () => context
                .read<BuddyBloc>()
                .add(const BuddyConversationCleared()),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  const _MessageList({required this.messages, required this.scroll});

  final List<ChatMessage> messages;
  final ScrollController scroll;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  bool _showPill = false;
  bool _scrollScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scroll.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scroll.hasClients) return;
    // Reverse list: pixels > 0 means user scrolled up away from the latest.
    final shouldShow = widget.scroll.position.pixels > 120;
    if (shouldShow != _showPill) {
      setState(() => _showPill = shouldShow);
    }
  }

  @override
  void didUpdateWidget(covariant _MessageList old) {
    super.didUpdateWidget(old);
    final lengthChanged = widget.messages.length != old.messages.length;
    final contentGrew = widget.messages.isNotEmpty &&
        old.messages.isNotEmpty &&
        widget.messages.last.content.length != old.messages.last.content.length;
    // A new turn always scrolls into view; mid-stream growth only follows if
    // the user hasn't scrolled up to read history.
    if (lengthChanged) {
      _scrollToBottom(force: true);
    } else if (contentGrew) {
      _scrollToBottom(force: false);
    }
  }

  void _scrollToBottom({required bool force}) {
    // Coalesce per-token scroll requests: at most one animation is scheduled
    // at a time, so a fast token stream doesn't pile up post-frame callbacks.
    if (_scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!widget.scroll.hasClients) return;
      // In a reverse ListView, 0 is the bottom (latest message).
      if (!force && widget.scroll.position.pixels > 120) return;
      widget.scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToBottom() {
    if (!widget.scroll.hasClients) return;
    widget.scroll.animateTo(
      0,
      duration: $styles.times.pageTransition,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversed = widget.messages.reversed.toList(growable: false);
    // Cap the conversation column on wide (web/tablet) windows; bubbles,
    // markdown and rich cards all inherit the constraint.
    return CenteredBox(
      width: $styles.sizes.maxContentWidth2,
      child: Stack(
        children: [
          ListView.builder(
            controller: widget.scroll,
            reverse: true,
            padding: EdgeInsets.symmetric(
              horizontal: $styles.insets.sm,
              vertical: $styles.insets.sm,
            ),
            itemCount: reversed.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _MessageItem(message: reversed[i]),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _showPill ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_showPill,
                  child: _ScrollToLatestPill(onTap: _jumpToBottom),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  const _MessageItem({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isRich && message.richKind == 'place_card') {
      return PlaceCardWidget(
        place: PlaceCard.fromJson(message.richData!),
      );
    }
    if (message.role == ChatRole.user) {
      return _UserBubble(message: message);
    }
    return _AssistantMessage(message: message);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    // 80% of the (already capped) chat column, with an absolute ceiling so
    // bubbles stay chat-like on wide web/desktop windows.
    final maxWidth = math.min(MediaQuery.of(context).size.width * .8, 480.0);
    final hasImage = message.attachmentUrls.isNotEmpty;
    final hasText = message.content.isNotEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular($styles.corners.card),
                child: CachedNetworkImage(
                  imageUrl: message.attachmentUrls.first,
                  width: 220,
                  fit: BoxFit.cover,
                ),
              ),
            if (hasImage && hasText) Gap($styles.insets.xs),
            if (hasText)
              Container(
                padding: EdgeInsets.all($styles.insets.xs + 2),
                decoration: BoxDecoration(
                  color: colors.greyStrong,
                  borderRadius: BorderRadius.circular($styles.corners.card),
                ),
                child: Text(
                  message.content,
                  style: $styles.text.body.copyWith(color: colors.offWhite),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final showTyping = message.isStreaming && message.content.isEmpty;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          left: $styles.insets.xxs,
          right: $styles.insets.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTyping)
              _TypingDots()
            // While tokens stream in, render plain Text. Parsing markdown on
            // every delta re-tokenizes the whole (growing) string per token —
            // the dominant streaming jank source. We parse once, on completion.
            else if (message.isStreaming)
              Text(
                message.content,
                style: $styles.text.body.copyWith(color: colors.offWhite),
              )
            else
              MarkdownBody(
                key: ValueKey('md_${message.id}'),
                data: message.content,
                selectable: true,
                softLineBreak: true,
                fitContent: true,
                shrinkWrap: true,
                onTapLink: (text, href, title) async {
                  if (href == null) return;
                  final uri = Uri.tryParse(href);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                styleSheet: _buildMarkdownStyle(colors),
              ),
            if (message.isStreaming && message.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: $styles.insets.xxs),
                child: _StreamingCaret(),
              ),
            if (!message.isStreaming &&
                !message.hasError &&
                message.savedTripId != null)
              _SavedTripMapThumbnail(savedTripId: message.savedTripId!),
            if (!message.isStreaming &&
                !message.hasError &&
                message.content.isNotEmpty)
              _AssistantActions(message: message),
            if (!message.isStreaming &&
                !message.hasError &&
                message.itinerary != null)
              _SaveItineraryButton(
                key: ValueKey('save_${message.id}'),
                message: message,
              ),
            if (!message.isStreaming &&
                !message.hasError &&
                message.itineraryFailed)
              _ItineraryFailedFooter(),
            if (!message.isStreaming &&
                !message.hasError &&
                message.tripRefined)
              _TripRefinedFooter(),
            if (!message.isStreaming &&
                !message.hasError &&
                message.refineFailed)
              _RefineFailedFooter(),
            if (!message.isStreaming &&
                !message.hasError &&
                message.notSaved)
              _NotSavedFooter(),
            if (message.hasError)
              _ErrorFooter(
                onRetry: () => context
                    .read<BuddyBloc>()
                    .add(const BuddyRetryLastRequested()),
              ),
          ],
        ),
      ),
    );
  }
}

/// Resolves the saved Trip from `TripsBloc.state.trips` at render time and
/// renders the inline static-map thumbnail. The `BlocSelector` is the
/// load-bearing piece: when a refine flow updates the trip's
/// `static_map_url`, the selector projects a new url and only this widget
/// rebuilds (not the whole bubble), and `Image.network` re-fetches.
class _SavedTripMapThumbnail extends StatelessWidget {
  const _SavedTripMapThumbnail({required this.savedTripId});

  final String savedTripId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TripsBloc, TripsState, Trip?>(
      selector: (s) => s.trips.firstWhereOrNull((t) => t.id == savedTripId),
      builder: (ctx, trip) {
        if (trip == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: $styles.insets.xs),
          child: ItineraryMapThumbnail(
            trip: trip,
            // Fade transition (instead of the default slide-up) gives the
            // Hero flight room to play visibly — the thumbnail morphs into
            // the full GoogleMap on TripMapScreen.
            onTap: () => Navigator.of(ctx).push(
              PageRouteBuilder(
                transitionDuration: $styles.times.med,
                reverseTransitionDuration: $styles.times.med,
                pageBuilder: (_, _, _) => TripMapScreen(trip: trip),
                transitionsBuilder: (_, anim, _, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotSavedFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.only(top: $styles.insets.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 14, color: colors.greyMedium),
          Gap($styles.insets.xxs),
          Text(
            $strings.buddyNotSavedHint,
            style: $styles.text.bodySmall.copyWith(color: colors.greyMedium),
          ),
        ],
      ),
    );
  }
}

class _ItineraryFailedFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.only(top: $styles.insets.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 14,
            color: colors.greyMedium,
          ),
          Gap($styles.insets.xxs),
          Flexible(
            child: Text(
              $strings.buddyItineraryUnstructured,
              style: $styles.text.bodySmall.copyWith(
                color: colors.greyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline footer on the assistant bubble of a successful refine turn. Shows a
/// "Trip updated" indicator and a link back to the saved trip detail. Uses
/// the scoped trip's id so the link survives until the user explicitly exits
/// refine mode.
class _TripRefinedFooter extends StatelessWidget with GetItMixin {
  _TripRefinedFooter();

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final scoped = context.select<BuddyBloc, Trip?>((b) => b.state.scopedTrip);
    return Padding(
      padding: EdgeInsets.only(top: $styles.insets.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: colors.accent1),
          Gap($styles.insets.xxs),
          Text(
            $strings.refineTripUpdated,
            style: $styles.text.bodySmall.copyWith(color: colors.greyMedium),
          ),
          if (scoped != null) ...[
            Gap($styles.insets.xs),
            TextButton(
              onPressed: () =>
                  context.go(ScreenPaths.trip(scoped.id)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: $styles.insets.xs,
                  vertical: 0,
                ),
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: colors.accent1,
              ),
              child: Text(
                $strings.refineViewTrip,
                style: $styles.text.bodySmall.copyWith(color: colors.accent1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline footer when refinement applied to the wire failed server-side. The
/// natural-language reply above describes the proposed change; the trip on
/// disk is unchanged. No retry CTA — the user can rephrase and re-ask.
class _RefineFailedFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.only(top: $styles.insets.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 14, color: colors.greyMedium),
          Gap($styles.insets.xxs),
          Flexible(
            child: Text(
              $strings.refineFailedFooter,
              style: $styles.text.bodySmall.copyWith(color: colors.greyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slim banner above the message list while in refine mode. Calls
/// `BuddyRefineModeExited` on tap, which clears `scopedTrip` so the
/// composer drops the `trip_id` from subsequent sends — the conversation
/// itself stays alive (the user can chat without committing further
/// changes).
class _RefineBanner extends StatelessWidget {
  const _RefineBanner({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.md,
        vertical: $styles.insets.xs,
      ),
      decoration: BoxDecoration(
        color: colors.accent1.withValues(alpha: .08),
        border: Border(
          bottom: BorderSide(color: colors.greyStrong),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: colors.accent1),
          Gap($styles.insets.xs),
          Expanded(
            child: Text(
              $strings.refineBannerTitle(trip.title),
              style: $styles.text.bodySmall
                  .copyWith(color: colors.offWhite)
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<BuddyBloc>().add(const BuddyRefineModeExited()),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: $styles.insets.sm,
                vertical: 0,
              ),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.accent1,
            ),
            child: Text(
              $strings.refineBannerExit,
              style: $styles.text.bodySmall.copyWith(color: colors.accent1),
            ),
          ),
        ],
      ),
    );
  }
}

MarkdownStyleSheet? _cachedMdStyle;
AppColors? _cachedMdColors;

MarkdownStyleSheet _buildMarkdownStyle(AppColors colors) {
  if (_cachedMdStyle != null && identical(_cachedMdColors, colors)) {
    return _cachedMdStyle!;
  }
  final base = $styles.text.body.copyWith(
    color: colors.offWhite,
    height: 1.55,
  );
  final contentFont = $styles.text.contentFont;
  TextStyle heading(double size, FontWeight weight) => contentFont.copyWith(
        color: colors.offWhite,
        fontSize: size,
        height: (size + 6) / size,
        fontWeight: weight,
      );
  _cachedMdColors = colors;
  _cachedMdStyle = MarkdownStyleSheet(
    p: base,
    pPadding: EdgeInsets.only(bottom: $styles.insets.xs),
    h1: heading(22, FontWeight.w700),
    h1Padding: EdgeInsets.only(
      top: $styles.insets.sm,
      bottom: $styles.insets.xxs,
    ),
    h2: heading(19, FontWeight.w700),
    h2Padding: EdgeInsets.only(
      top: $styles.insets.sm,
      bottom: $styles.insets.xxs,
    ),
    h3: heading(17, FontWeight.w600),
    h3Padding: EdgeInsets.only(
      top: $styles.insets.xs + 2,
      bottom: $styles.insets.xxs,
    ),
    strong: base.copyWith(fontWeight: FontWeight.w700),
    em: base.copyWith(fontStyle: FontStyle.italic),
    a: base.copyWith(
      color: colors.accent1,
      decoration: TextDecoration.underline,
      decorationColor: colors.accent1.withValues(alpha: .5),
    ),
    listBullet: base,
    listIndent: 20,
    blockSpacing: $styles.insets.xs,
    code: $styles.text.bodySmall.copyWith(
      fontFamily: 'B612Mono',
      color: colors.accent1,
      backgroundColor: colors.black.withValues(alpha: .4),
    ),
    codeblockPadding: EdgeInsets.all($styles.insets.xs),
    codeblockDecoration: BoxDecoration(
      color: colors.black.withValues(alpha: .55),
      borderRadius: BorderRadius.circular($styles.corners.sm),
      border: Border.all(color: colors.greyStrong.withValues(alpha: .6)),
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: colors.accent1, width: 3)),
      color: colors.greyStrong.withValues(alpha: .25),
    ),
    blockquotePadding: EdgeInsets.symmetric(
      horizontal: $styles.insets.xs,
      vertical: $styles.insets.xxs,
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: colors.greyStrong, width: 1),
      ),
    ),
  );
  return _cachedMdStyle!;
}

class _StreamingCaret extends StatefulWidget {
  @override
  State<_StreamingCaret> createState() => _StreamingCaretState();
}

class _StreamingCaretState extends State<_StreamingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return RepaintBoundary(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.25, end: 1.0).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
        ),
        child: Container(
          width: 8,
          height: 16,
          decoration: BoxDecoration(
            color: colors.accent1,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value - i * 0.2) % 1.0) * 2 * pi;
            final t = (sin(phase) + 1) / 2;
            final scale = 0.6 + 0.4 * t;
            final opacity = 0.35 + 0.65 * t;
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: $styles.colors.offWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.attachments,
    required this.isStreaming,
    required this.hintText,
    required this.onSend,
    required this.onCancel,
    required this.onPicked,
    required this.onRemoveAttachment,
    required this.onRetryAttachment,
  });

  final TextEditingController controller;
  final List<PendingAttachment> attachments;
  final bool isStreaming;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback onCancel;
  final ValueChanged<XFile> onPicked;
  final ValueChanged<String> onRemoveAttachment;
  final ValueChanged<String> onRetryAttachment;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final hasReady =
        attachments.any((a) => a.status == AttachmentStatus.ready);

    // Same cap as the message list so the composer aligns with the column.
    return CenteredBox(
      width: $styles.sizes.maxContentWidth2,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          $styles.insets.sm,
          $styles.insets.xs,
          $styles.insets.sm,
          $styles.insets.sm,
        ),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.greyStrong.withValues(alpha: .55),
            borderRadius: BorderRadius.circular($styles.corners.card),
            border: Border.all(
              color: colors.greyMedium.withValues(alpha: .3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (attachments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AttachmentStrip(
                    attachments: attachments,
                    onRemove: onRemoveAttachment,
                    onRetry: onRetryAttachment,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AttachButton(onPicked: onPicked),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
                      child: TextField(
                        controller: controller,
                        maxLines: 6,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        style: $styles.text.body.copyWith(color: colors.offWhite),
                        cursorColor: colors.accent1,
                        decoration: InputDecoration.collapsed(
                          hintText: hintText,
                          hintStyle: TextStyle(color: colors.greyMedium),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (ctx, value, _) => _buildAction(
                      value.text.trim().isNotEmpty || hasReady,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(bool canSend) {
    // No dictation on web (speech_to_text browser support is unreliable), so
    // the action slot is always send/stop there. Send is safe when the field
    // is empty — _sendCurrent no-ops on blank input.
    if (kIsWeb) {
      if (isStreaming) return _RoundButton.stop(onTap: onCancel);
      return _RoundButton.send(onTap: onSend);
    }
    return BlocSelector<VoiceBloc, VoiceBlocState, VoiceState>(
      selector: (s) => s.status,
      builder: (ctx, vState) {
        // While listening, the mic button (which now toggles to a stop icon
        // via its own state listener) takes precedence over Send so the user
        // must explicitly stop the recognizer before submitting.
        if (vState == VoiceState.listening) return const VoiceButton();
        if (isStreaming) return _RoundButton.stop(onTap: onCancel);
        if (canSend) return _RoundButton.send(onTap: onSend);
        return const VoiceButton();
      },
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton._({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  factory _RoundButton.send({required VoidCallback onTap}) => _RoundButton._(
        icon: Icons.arrow_upward_rounded,
        onTap: onTap,
        tooltip: $strings.buddySendTooltip,
      );

  factory _RoundButton.stop({required VoidCallback onTap}) => _RoundButton._(
        icon: Icons.stop_rounded,
        onTap: onTap,
        tooltip: 'Stop',
      );

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.accent1,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            width: 44,
            child: Icon(icon, color: colors.black),
          ),
        ),
      ),
    );
  }
}

class _BuddyWelcome extends StatelessWidget {
  const _BuddyWelcome({required this.onPick, this.scopedTrip});
  final ValueChanged<String> onPick;
  final Trip? scopedTrip;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final isRefine = scopedTrip != null;
    final title =
        isRefine ? $strings.refineEmptyTitle : $strings.buddyEmptyTitle;
    final subtitle =
        isRefine ? $strings.refineEmptySubtitle : $strings.buddyEmptySubtitle;
    final chips = isRefine
        ? [
            $strings.refineSuggestionShortenDay,
            $strings.refineSuggestionAddBeach,
            $strings.refineSuggestionSwapStop,
          ]
        : [
            $strings.buddySuggestionTirana,
            $strings.buddySuggestionBerat,
            $strings.buddySuggestionBudget,
          ];
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: $styles.insets.md,
          vertical: $styles.insets.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: colors.accent1.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colors.accent1,
                size: 28,
              ),
            ),
            Gap($styles.insets.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: $styles.text.contentFont.copyWith(
                color: colors.offWhite,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            Gap($styles.insets.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: $styles.text.body.copyWith(
                color: colors.greyMedium,
                height: 1.4,
              ),
            ),
            Gap($styles.insets.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: $styles.insets.xs,
              runSpacing: $styles.insets.xs,
              children: [
                for (final text in chips)
                  _SuggestionChip(text: text, onTap: () => onPick(text)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: colors.accent1.withValues(alpha: .5),
          width: 1,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: $styles.insets.sm,
            vertical: $styles.insets.xs + 2,
          ),
          child: Text(
            text,
            style: $styles.text.bodySmall.copyWith(color: colors.offWhite),
          ),
        ),
      ),
    );
  }
}

class _ScrollToLatestPill extends StatelessWidget {
  const _ScrollToLatestPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Material(
      color: colors.greyStrong,
      shape: StadiumBorder(
        side: BorderSide(
          color: colors.greyMedium.withValues(alpha: .4),
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: colors.offWhite,
              ),
              const Gap(4),
              Text(
                'Latest',
                style: $styles.text.bodySmall.copyWith(color: colors.offWhite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantActions extends StatelessWidget {
  const _AssistantActions({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CopyButton(content: message.content),
          // TTS playback is mobile-only; browser TTS support is unreliable.
          if (!kIsWeb) _TtsButton(message: message),
        ],
      ),
    );
  }
}

class _TtsButton extends StatelessWidget {
  const _TtsButton({required this.message});

  final ChatMessage message;

  /// Map the app language code to a primary BCP-47 tag plus reasonable
  /// fallbacks. Albanian voices are not always installed, so we cascade.
  ({String primary, List<String> fallbacks}) _localesForApp() {
    final lang = GetIt.I<LocaleLogic>().strings.localeName;
    switch (lang) {
      case 'sq':
        return (primary: 'sq-AL', fallbacks: ['it-IT', 'en-US']);
      case 'en':
      default:
        return (primary: 'en-US', fallbacks: ['en-GB']);
    }
  }

  void _toggle(BuildContext ctx) {
    final bloc = ctx.read<TtsBloc>();
    final s = bloc.state;
    final isMine = s.activeMessageId == message.id;
    if (isMine && s.status != TtsState.idle) {
      bloc.add(const TtsStopRequested());
    } else {
      final loc = _localesForApp();
      bloc.add(TtsSpeakRequested(
        messageId: message.id,
        text: message.content,
        localeId: loc.primary,
        fallbackLocales: loc.fallbacks,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return BlocSelector<TtsBloc, TtsBlocState, ({String? activeId, TtsState status})>(
      selector: (s) => (activeId: s.activeMessageId, status: s.status),
      builder: (ctx, slice) {
        final isMine = slice.activeId == message.id;
        final isSpeaking = isMine &&
            (slice.status == TtsState.speaking ||
                slice.status == TtsState.loading);
        final color = isSpeaking ? colors.accent1 : colors.greyMedium;
        final icon = isSpeaking
            ? Icons.stop_circle_outlined
            : Icons.volume_up_outlined;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Tooltip(
            message: isSpeaking ? $strings.buddyTtsStop : $strings.buddyTtsPlay,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _toggle(ctx),
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: Icon(icon, size: 18, color: color),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.content});
  final String content;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _justCopied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    if (!mounted) return;
    setState(() => _justCopied = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _justCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final color = _justCopied ? colors.accent1 : colors.greyMedium;
    final icon = _justCopied ? Icons.check_rounded : Icons.copy_rounded;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _copy,
        child: SizedBox(
          height: 28,
          width: 28,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _ErrorFooter extends StatelessWidget {
  const _ErrorFooter({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.only(top: $styles.insets.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 16, color: colors.error),
          Gap($styles.insets.xxs),
          Text(
            $strings.buddyErrorHint,
            style: $styles.text.bodySmall.copyWith(color: colors.error),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: $styles.insets.xs),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              $strings.buddyErrorRetry,
              style: $styles.text.bodySmallBold.copyWith(color: colors.accent1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a streamed `ItineraryDraft` inline in the assistant bubble: title,
/// optional summary, then each day with its day pill and ordered stops.
/// Mirrors the visual language of `trip_detail_screen.dart` so a saved trip
/// looks continuous with its chat preview.
class _ItineraryPreview extends StatelessWidget {
  const _ItineraryPreview({required this.itinerary});
  final ItineraryDraft itinerary;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final summary = itinerary.summary?.trim();
    final hasSummary = summary != null && summary.isNotEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: $styles.insets.xs),
      child: Container(
        padding: EdgeInsets.all($styles.insets.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: colors.accent1.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular($styles.corners.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itinerary.title,
              style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
            ),
            if (hasSummary) ...[
              SizedBox(height: $styles.insets.xxs),
              Text(
                summary,
                style: $styles.text.bodySmall.copyWith(
                  color: colors.greyMedium,
                ),
              ),
            ],
            for (final day in itinerary.days) ...[
              SizedBox(height: $styles.insets.sm),
              _ItineraryDayHeader(day: day),
              SizedBox(height: $styles.insets.xs),
              for (var i = 0; i < day.stops.length; i++)
                _ItineraryStopRow(
                  stop: day.stops[i],
                  isLast: i == day.stops.length - 1,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItineraryDayHeader extends StatelessWidget {
  const _ItineraryDayHeader({required this.day});
  final DayDraft day;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final descriptor = day.title?.trim().isNotEmpty == true
        ? day.title!
        : (day.baseCity?.trim().isNotEmpty == true ? day.baseCity! : '');
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.accent1.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular($styles.corners.pill),
          ),
          child: Text(
            $strings.tripDetailDayLabel(day.dayNumber),
            style: $styles.text.bodySmallBold.copyWith(color: colors.accent1),
          ),
        ),
        if (descriptor.isNotEmpty) ...[
          SizedBox(width: $styles.insets.xs),
          Expanded(
            child: Text(
              descriptor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
            ),
          ),
        ],
      ],
    );
  }
}

class _ItineraryStopRow extends StatelessWidget {
  const _ItineraryStopRow({required this.stop, required this.isLast});
  final StopDraft stop;
  final bool isLast;

  IconData _kindIcon(StopKind kind) {
    switch (kind) {
      case StopKind.sight:
        return Icons.museum_outlined;
      case StopKind.beach:
        return Icons.waves;
      case StopKind.hike:
        return Icons.terrain;
      case StopKind.meal:
        return Icons.restaurant;
      case StopKind.stay:
        return Icons.hotel;
      case StopKind.transport:
        return Icons.directions_car;
      case StopKind.activity:
        return Icons.local_activity;
      case StopKind.unknown:
        return Icons.place_outlined;
    }
  }

  String? _timeLabel() {
    final a = stop.arrivalTime;
    final e = stop.endTime;
    if (a != null && a.isNotEmpty && e != null && e.isNotEmpty) {
      return '$a – $e';
    }
    if (a != null && a.isNotEmpty) return a;
    return null;
  }

  String? _durationLabel() {
    final m = stop.durationMinutes;
    if (m == null || m <= 0) return null;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? '${h}h' : '${h}h ${r}m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final time = _timeLabel();
    final duration = _durationLabel();
    final notes = stop.notes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;
    final metaParts = <String>[
      if (time != null) time,
      if (duration != null) duration,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : $styles.insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              _kindIcon(stop.kind),
              size: 16,
              color: colors.accent1,
            ),
          ),
          SizedBox(width: $styles.insets.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: $styles.text.body.copyWith(color: colors.offWhite),
                ),
                if (metaParts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    metaParts.join(' · '),
                    style: $styles.text.caption.copyWith(
                      color: colors.greyMedium,
                    ),
                  ),
                ],
                if (hasNotes) ...[
                  const SizedBox(height: 2),
                  Text(
                    notes,
                    style: $styles.text.bodySmall.copyWith(
                      color: colors.greyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-process guard so the same chat-bubble Save can't be triggered twice
/// (POST /trips has no place key — it's not idempotent server-side). Lasts
/// until app restart; rehydrated chat history has `itinerary == null` so
/// no Save button shows there.
final Set<String> _savedItineraryIds = <String>{};

enum _SaveState { idle, saving, saved, error, limitReached }

class _SaveItineraryButton extends StatefulWidget {
  const _SaveItineraryButton({super.key, required this.message});
  final ChatMessage message;

  @override
  State<_SaveItineraryButton> createState() => _SaveItineraryButtonState();
}

class _SaveItineraryButtonState extends State<_SaveItineraryButton> {
  late _SaveState _state;
  DateTime? _pickedDate;

  /// Single-use guard so a 404-then-sync-retry can't loop. Reset is
  /// intentionally absent: once we've tried sync-and-retry on this button,
  /// any further failures fall straight through to the error state.
  bool _didRetryAfterSync = false;

  @override
  void initState() {
    super.initState();
    _state = _savedItineraryIds.contains(widget.message.id)
        ? _SaveState.saved
        : _SaveState.idle;
  }

  Future<void> _handleTap() async {
    if (_state == _SaveState.saving || _state == _SaveState.saved) return;

    final draft = widget.message.itinerary;
    if (draft == null) return;

    // Auth gate — mirror the old place-card flow. If the user signs in then
    // returns, we don't auto-resume; they tap Save again.
    String? token() =>
        Supabase.instance.client.auth.currentSession?.accessToken;
    if (token() == null || token()!.isEmpty) {
      if (!mounted) return;
      await context.push(ScreenPaths.auth);
      if (!mounted) return;
      if (token() == null || token()!.isEmpty) return;
    }

    // Date prompt only when Claude didn't emit one and we don't already
    // have a pick from a prior attempt. Cancel = abort; never silently
    // save without a date.
    DateTime? effectiveDate = _pickedDate ?? draft.startDate;
    if (effectiveDate == null) {
      final now = DateTime.now();
      final picked = await showThemedDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 730)),
        helpText: $strings.buddyItineraryPickStartDateHelp,
        locale: Localizations.localeOf(context),
      );
      if (picked == null) return;
      _pickedDate = picked;
      effectiveDate = picked;
    }

    if (!mounted) return;
    setState(() => _state = _SaveState.saving);
    try {
      final completer = Completer<Trip>();
      context.read<TripsBloc>().add(ItinerarySaveRequested(
            draft,
            assistantMessageId: widget.message.id,
            userPickedStartDate: _pickedDate,
            completer: completer,
          ));
      await completer.future;
      _savedItineraryIds.add(widget.message.id);
      if (!mounted) return;
      setState(() => _state = _SaveState.saved);
    } on TripServiceException catch (e, st) {
      dlog(
        'saveItinerary failed',
        error: e,
        stackTrace: st,
        name: 'buddy.save',
      );
      // Server-side cap. Either the local guard skipped (state stale at tap
      // time) or another device saved between the local check and the POST.
      // Either way: surface the inline "limit reached" branch — no SnackBar.
      if (e.statusCode == 409 && e.body.contains('trip_limit_reached')) {
        if (!mounted) return;
        setState(() => _state = _SaveState.limitReached);
        return;
      }
      // 404 from POST /trips means require_local_user couldn't find a row in
      // the local users table. AuthLogic._ensureSyncedAndLoad runs sync at
      // every session-becomes-live point, so the only path here is a
      // transient sync failure (e.g., offline at sign-in). Run sync once and
      // retry the save before falling through to the error state.
      if (e.statusCode == 404 && !_didRetryAfterSync) {
        _didRetryAfterSync = true;
        try {
          await GetIt.I<UserService>().sync(bearerToken: token());
          if (!mounted) return;
          final retryCompleter = Completer<Trip>();
          context.read<TripsBloc>().add(ItinerarySaveRequested(
                draft,
                assistantMessageId: widget.message.id,
                userPickedStartDate: _pickedDate,
                completer: retryCompleter,
              ));
          await retryCompleter.future;
          _savedItineraryIds.add(widget.message.id);
          if (!mounted) return;
          setState(() => _state = _SaveState.saved);
          return;
        } catch (e2, st2) {
          dlog(
            'saveItinerary retry-after-sync failed',
            error: e2,
            stackTrace: st2,
            name: 'buddy.save',
          );
        }
      }
      if (!mounted) return;
      setState(() => _state = _SaveState.error);
    } catch (e, st) {
      dlog(
        'saveItinerary unexpected',
        error: e,
        stackTrace: st,
        name: 'buddy.save',
      );
      if (!mounted) return;
      setState(() => _state = _SaveState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular($styles.corners.card),
    );

    // Selector on the saved-trips count so the button auto-disables when the
    // cap is reached (e.g., another itinerary card just saved) and auto-
    // re-enables when the user deletes a trip from My Trips.
    return BlocSelector<TripsBloc, TripsState, int>(
      selector: (s) => s.trips.length,
      builder: (context, count) {
        // Only override `idle` → `limitReached`. `saving`, `saved`, and the
        // retryable `error` states keep their own rendering — if the user is
        // mid-save when count flips, they finish the in-flight POST and the
        // server's own 409 trips the catch-block branch above.
        final effective = (_state == _SaveState.idle && count >= maxSavedTrips)
            ? _SaveState.limitReached
            : _state;

        Widget button;
        switch (effective) {
          case _SaveState.idle:
            button = OutlinedButton.icon(
              onPressed: _handleTap,
              icon: Icon(Icons.bookmark_outline,
                  size: 16, color: colors.accent1),
              label: Text(
                $strings.buddySaveItinerary,
                style:
                    $styles.text.bodySmallBold.copyWith(color: colors.accent1),
              ),
              style: OutlinedButton.styleFrom(
                padding: padding,
                shape: shape,
                side: BorderSide(color: colors.accent1, width: 1),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          case _SaveState.saving:
            button = OutlinedButton.icon(
              onPressed: null,
              icon: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent1),
                ),
              ),
              label: Text(
                $strings.buddySaveItinerary,
                style:
                    $styles.text.bodySmallBold.copyWith(color: colors.accent1),
              ),
              style: OutlinedButton.styleFrom(
                padding: padding,
                shape: shape,
                side: BorderSide(color: colors.accent1, width: 1),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          case _SaveState.saved:
            // Tappable affordance that routes the user to the My Trips tab.
            // The button is gated against a second save by the
            // `_savedItineraryIds` guard above, so re-tap navigates instead
            // of re-posting. AppShell consumes `BuddyState.requestedTab` to
            // switch tabs (same one-shot mechanism the trip-detail "Refine
            // with Buddy" CTA uses, in reverse).
            button = TextButton(
              onPressed: () =>
                  context.read<BuddyBloc>().add(const BuddyTabRequested(2)),
              style: TextButton.styleFrom(
                padding: padding,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                $strings.buddyItinerarySaved,
                style:
                    $styles.text.bodySmallBold.copyWith(color: colors.accent1),
              ),
            );
          case _SaveState.error:
            button = TextButton.icon(
              onPressed: _handleTap,
              icon: Icon(
                Icons.refresh_rounded,
                size: 16,
                color: colors.error,
              ),
              label: Text(
                $strings.buddyItinerarySaveRetry,
                style: $styles.text.bodySmallBold
                    .copyWith(color: colors.error),
              ),
              style: TextButton.styleFrom(
                padding: padding,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          case _SaveState.limitReached:
            // Disabled outlined button + inline helper below it. Inline
            // feedback (no SnackBar) per design preferences.
            button = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.bookmark_outline,
                      size: 16, color: colors.greyMedium),
                  label: Text(
                    $strings.buddySaveItinerary,
                    style: $styles.text.bodySmallBold
                        .copyWith(color: colors.greyMedium),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: padding,
                    shape: shape,
                    side: BorderSide(
                        color: colors.greyMedium.withValues(alpha: 0.4)),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  $strings.buddySaveLimitHelper,
                  style: $styles.text.bodySmall
                      .copyWith(color: colors.greyMedium),
                ),
              ],
            );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Align(alignment: Alignment.centerLeft, child: button),
        );
      },
    );
  }
}
