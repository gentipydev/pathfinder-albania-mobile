import 'package:travel_buddy/common_libs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/logic/buddy/conversations_service.dart';
import 'package:travel_buddy/ui/common/centered_box.dart';
import 'package:travel_buddy/ui/common/empty_state.dart';
import 'package:travel_buddy/ui/common/error_state.dart';
import 'package:travel_buddy/ui/common/modals/destructive_confirm_sheet.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  // Shared singleton — BuddyLogic also calls into this service for the
  // refine-with-buddy hydrate path. Lifetime is app-scoped; do NOT dispose
  // it here.
  ConversationsService get _service => GetIt.I<ConversationsService>();

  List<ConversationSummary>? _items;
  Object? _loadError;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _nextCursor;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  static const double _prefetchPx = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String? _bearer() =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - _prefetchPx) return;
    if (!_hasMore || _isLoadingMore || _nextCursor == null) return;
    _loadMore();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _nextCursor = null;
      _hasMore = true;
    });
    try {
      final page = await _service.list(bearerToken: _bearer());
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _nextCursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final page =
          await _service.list(bearerToken: _bearer(), cursor: _nextCursor);
      if (!mounted) return;
      setState(() {
        _items = [...?_items, ...page.items];
        _nextCursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _open(ConversationSummary summary) async {
    final navigator = Navigator.of(context);
    final bloc = context.read<BuddyBloc>();
    try {
      final messages = await _service.get(
        summary.id,
        bearerToken:
            Supabase.instance.client.auth.currentSession?.accessToken,
      );
      bloc.add(BuddyConversationLoaded(id: summary.id, hydrated: messages));
      // Wait for the bloc to flush the new state so the buddy screen rebuilds
      // with the loaded history before we pop this route. Mirrors auth_screen's
      // sign-in await pattern (`bloc.stream.firstWhere`).
      await bloc.stream.firstWhere((s) => s.conversationId == summary.id);
      if (!mounted) return;
      navigator.pop();
    } catch (_) {
      // silent: user stays on the conversations screen
    }
  }

  void _startNewChat() {
    context.read<BuddyBloc>().add(const BuddyConversationCleared());
    Navigator.of(context).pop();
  }

  Future<void> _confirmDeleteConversation(ConversationSummary summary) async {
    final confirmed = await showDestructiveConfirmSheet(
      context,
      title: $strings.conversationsDeleteTitle,
      body: $strings.conversationsDeleteConfirm,
      confirmLabel: $strings.conversationsDeleteAction,
      cancelLabel: $strings.conversationsDeleteCancel,
    );
    if (!confirmed || !mounted) return;
    await _deleteConversation(summary);
  }

  Future<void> _confirmClearAllConversations() async {
    final confirmed = await showDestructiveConfirmSheet(
      context,
      title: $strings.conversationsClearAllTitle,
      body: $strings.conversationsClearAllBody,
      confirmLabel: $strings.conversationsClearAllConfirm,
      cancelLabel: $strings.conversationsDeleteCancel,
      confirmIcon: Icons.delete_sweep_outlined,
    );
    if (!confirmed || !mounted) return;
    await _clearAllConversations();
  }

  Future<void> _clearAllConversations() async {
    final snapshot = _items;
    if (snapshot == null || snapshot.isEmpty) return;
    setState(() => _items = const []);
    try {
      await _service.clearAll(
        bearerToken:
            Supabase.instance.client.auth.currentSession?.accessToken,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = snapshot);
      return;
    }
    if (!mounted) return;
    // Any currently-open conversation in the buddy tab now points at a deleted
    // row, so reset that bloc to a fresh chat.
    context.read<BuddyBloc>().add(const BuddyConversationCleared());
  }

  Future<void> _deleteConversation(ConversationSummary summary) async {
    try {
      await _service.delete(
        summary.id,
        bearerToken:
            Supabase.instance.client.auth.currentSession?.accessToken,
      );
    } catch (_) {
      return;
    }

    if (!mounted) return;
    final bloc = context.read<BuddyBloc>();
    if (bloc.state.conversationId == summary.id) {
      bloc.add(const BuddyConversationCleared());
    }
    setState(() {
      _items?.removeWhere((s) => s.id == summary.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = (_items?.isNotEmpty) ?? false;
    return Scaffold(
      backgroundColor: $styles.colors.greyStrong,
      appBar: AppBar(
        backgroundColor: $styles.colors.greyStrong,
        foregroundColor: $styles.colors.offWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          $strings.conversationsTitle,
          style: $styles.text.bodyBold.copyWith(color: $styles.colors.offWhite),
        ),
        actions: [
          if (hasItems)
            PopupMenuButton<String>(
              tooltip: $strings.conversationsClearAllAction,
              icon: Icon(Icons.more_vert, color: $styles.colors.offWhite),
              color: $styles.colors.greyStrong,
              onSelected: (v) {
                if (v == 'clear_all') _confirmClearAllConversations();
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep_outlined,
                          color: $styles.colors.error),
                      SizedBox(width: $styles.insets.sm),
                      Text(
                        $strings.conversationsClearAllAction,
                        style: $styles.text.body
                            .copyWith(color: $styles.colors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            tooltip: $strings.conversationsNewChatTooltip,
            icon: Icon(Icons.edit_outlined, color: $styles.colors.offWhite),
            onPressed: _startNewChat,
          ),
        ],
      ),
      // Cap the conversation list on wide (web/tablet) windows.
      body: CenteredBox(
        width: $styles.sizes.maxContentWidth2,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items == null) {
      return Center(
        child: CircularProgressIndicator(color: $styles.colors.accent1),
      );
    }
    if (_loadError != null && _items == null) {
      return ErrorState(
        message: $strings.conversationsLoadFailed,
        onRetry: _load,
      );
    }
    final items = _items ?? const <ConversationSummary>[];
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: $strings.conversationsEmpty,
      );
    }
    final showFooter = _hasMore;
    final itemCount = items.length + (showFooter ? 1 : 0);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: $styles.insets.sm),
        itemCount: itemCount,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: $styles.colors.greyMedium.withValues(alpha: .15),
        ),
        itemBuilder: (context, i) {
          if (showFooter && i == items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: $styles.insets.md),
              child: Center(
                child: _isLoadingMore
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: $styles.colors.accent1,
                        ),
                      )
                    : const SizedBox(height: 22),
              ),
            );
          }
          final summary = items[i];
          return _ConversationTile(
            key: ValueKey(summary.id),
            summary: summary,
            onTap: () => _open(summary),
            onLongPress: () => _confirmDeleteConversation(summary),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    super.key,
    required this.summary,
    required this.onTap,
    required this.onLongPress,
  });

  final ConversationSummary summary;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final title =
        (summary.title?.isNotEmpty ?? false)
            ? summary.title!
            : $strings.conversationsUntitled;
    final ts = summary.updatedAt ?? summary.createdAt;
    final subtitle = ts == null ? '' : _relativeTime(ts);
    return Container(
      color: $styles.colors.greyStrong,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        title: Text(
          title,
          style: $styles.text.body.copyWith(color: $styles.colors.offWhite),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: $styles.text.caption.copyWith(color: $styles.colors.greyMedium),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: $styles.colors.greyMedium,
        ),
      ),
    );
  }
}

String _relativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
