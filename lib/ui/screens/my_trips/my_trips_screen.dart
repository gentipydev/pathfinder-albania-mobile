import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/features/trips/bloc/trips_error_mapper.dart';
import 'package:travel_buddy/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/ui/common/centered_box.dart';
import 'package:travel_buddy/ui/common/empty_state.dart';
import 'package:travel_buddy/ui/common/error_state.dart';
import 'package:travel_buddy/ui/common/modals/destructive_confirm_sheet.dart';
import 'package:travel_buddy/ui/screens/my_trips/widgets/trip_error_banner.dart';
import 'package:travel_buddy/ui/screens/trip_map/trip_map_colors.dart';

/// Drops a leading "N day(s) in " or "N-day " prefix from a
/// server-stored trip title so the card line shows just the
/// destination. The pill on the static map already carries the
/// duration; re-stating it inside the title is noise. Older trips
/// were saved with titles like "3 Days in Tirana" before the
/// itinerary-tool prompt was tightened — this strips that prefix
/// at display time without touching the stored value. The two
/// alternation branches separate the "N Days in X" form (where
/// "in" is required, so we don't accidentally chew into a normal
/// title that happens to start with a number) from the "N-Day X"
/// hyphenated form (where "in" isn't part of the pattern).
final RegExp _kTitleDayPrefix = RegExp(
  r'^\s*\d+(\s+[Dd]ays?\s+[Ii]n\s+|\s*-\s*[Dd]ays?\s+)',
);

String displayTripTitle(String raw) {
  final stripped = raw.replaceFirst(_kTitleDayPrefix, '');
  return stripped.trim().isEmpty ? raw : stripped;
}

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  bool _didLoad = false;
  final ScrollController _scrollController = ScrollController();

  /// Threshold (px from bottom) at which to prefetch the next page. 400px
  /// is roughly two row heights — enough lead time that users on fast scrolls
  /// don't see the footer spinner before more rows resolve.
  static const double _prefetchPx = 400;

  @override
  void initState() {
    super.initState();
    // First-time load. AuthBloc also dispatches LoadAllRequested on session
    // change so this is a safety net for cold starts that landed directly on
    // this tab.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didLoad || !mounted) return;
      _didLoad = true;
      context.read<TripsBloc>().add(const LoadAllRequested());
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - _prefetchPx) return;
    final bloc = context.read<TripsBloc>();
    final s = bloc.state;
    if (!s.hasMore || s.isLoadingMore || s.nextCursor == null) return;
    bloc.add(const TripsLoadMoreRequested());
  }

  Future<void> _confirmClearAllTrips(BuildContext context) async {
    final tripsBloc = context.read<TripsBloc>();
    final confirmed = await showDestructiveConfirmSheet(
      context,
      title: $strings.myTripsClearAllTitle,
      body: $strings.myTripsClearAllBody,
      confirmLabel: $strings.myTripsClearAllConfirm,
      cancelLabel: $strings.myTripsDeleteCancel,
      confirmIcon: Icons.delete_sweep_outlined,
    );
    if (!confirmed) return;
    tripsBloc.add(const TripClearAllRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return ColoredBox(
      color: colors.black,
      child: SafeArea(
        bottom: false,
        // Cap the header + trip list on wide (web/tablet) windows; the 16/7
        // map thumbnails then render at the width they were designed for.
        child: CenteredBox(
          width: $styles.sizes.maxContentWidth2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TripErrorBanner(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  $styles.insets.md,
                  $styles.insets.md,
                  $styles.insets.sm,
                  $styles.insets.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        $strings.myTripsTitle,
                        style: $styles.text.h2.copyWith(color: colors.offWhite),
                      ),
                    ),
                    // Cap counter. Always visible (even at 0) so users learn
                    // the limit before they hit it. `maxSavedTrips` is sourced
                    // from TripsBloc so the magic number lives in one place.
                    BlocSelector<TripsBloc, TripsState, int>(
                      selector: (s) => s.trips.length,
                      builder: (context, count) => Padding(
                        padding: EdgeInsets.only(right: $styles.insets.xs),
                        child: Text(
                          $strings.myTripsCounter(count, maxSavedTrips),
                          style: $styles.text.bodySmall
                              .copyWith(color: colors.greyMedium),
                        ),
                      ),
                    ),
                    BlocSelector<TripsBloc, TripsState, bool>(
                      selector: (s) => s.trips.isNotEmpty,
                      builder: (context, hasTrips) {
                        if (!hasTrips) return const SizedBox.shrink();
                        return PopupMenuButton<String>(
                          tooltip: $strings.myTripsClearAllAction,
                          icon: Icon(Icons.more_vert, color: colors.offWhite),
                          color: colors.greyStrong,
                          onSelected: (v) {
                            if (v == 'clear_all') _confirmClearAllTrips(context);
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
                                    $strings.myTripsClearAllAction,
                                    style: $styles.text.body
                                        .copyWith(color: $styles.colors.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
                  child: BlocBuilder<TripsBloc, TripsState>(
                    // Limit rebuilds to the state slices the body branches on
                    // (the optimistic stop/day pending markers are read by
                    // _TripRow internally, so include them here too).
                    buildWhen: (a, b) =>
                        a.trips != b.trips ||
                        a.isLoading != b.isLoading ||
                        a.isLoadingMore != b.isLoadingMore ||
                        a.hasMore != b.hasMore ||
                        a.lastError != b.lastError,
                    builder: (context, s) {
                      if (s.trips.isEmpty && s.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(color: colors.accent1),
                        );
                      }
                      if (s.trips.isEmpty && s.lastError != null) {
                        return ErrorState(
                          message: resolveTripsErrorMessage(s.lastError),
                          onRetry: () => context
                              .read<TripsBloc>()
                              .add(const LoadAllRequested()),
                        );
                      }
                      if (s.trips.isEmpty) {
                        return EmptyState(
                          icon: Icons.luggage_outlined,
                          title: $strings.myTripsEmptyTitle,
                          subtitle: $strings.myTripsEmptySubtitle,
                        );
                      }
                      final showFooter = s.hasMore;
                      final itemCount = s.trips.length + (showFooter ? 1 : 0);
                      return RefreshIndicator(
                        color: colors.accent1,
                        backgroundColor: colors.greyStrong,
                        onRefresh: () async {
                          context.read<TripsBloc>().add(const LoadAllRequested());
                        },
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          itemCount: itemCount,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: $styles.insets.sm),
                          itemBuilder: (context, i) {
                            if (showFooter && i == s.trips.length) {
                              return _PaginationFooter(
                                loading: s.isLoadingMore,
                                color: colors.accent1,
                              );
                            }
                            return _TripRow(trip: s.trips[i]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trailing sentinel row that doubles as both a "more loading" spinner
/// (`loading: true`) and a transparent placeholder while the scroll listener
/// debounces (`loading: false`). Visible only while `hasMore` is true.
class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.loading, required this.color});

  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: $styles.insets.md),
      child: Center(
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: color,
                ),
              )
            : const SizedBox(height: 22),
      ),
    );
  }
}

/// Row for a single saved trip. When `trip.staticMapUrl` is non-null the row
/// renders as a banner card with the route map at the top and a day-count
/// chip overlay; older trips (saved before static-map enrichment landed)
/// fall back to the legacy compact icon row so they remain functional.
class _TripRow extends StatefulWidget {
  const _TripRow({required this.trip});
  final Trip trip;

  @override
  State<_TripRow> createState() => _TripRowState();
}

class _TripRowState extends State<_TripRow> {
  bool _pressed = false;

  String _subtitle() {
    if (widget.trip.startDate == null) {
      return $strings.myTripsDatesNotSet;
    }
    final locale = GetIt.I<LocaleLogic>().strings.localeName;
    return DateFormat.yMMMd(locale).format(widget.trip.startDate!);
  }

  Future<void> _confirmDelete() async {
    final tripsBloc = context.read<TripsBloc>();
    final ok = await showDestructiveConfirmSheet(
      context,
      title: $strings.myTripsDeleteTitle,
      body: $strings.myTripsDeleteBody,
      confirmLabel: $strings.myTripsDeleteConfirm,
      cancelLabel: $strings.myTripsDeleteCancel,
    );
    if (!ok) return;
    tripsBloc.add(TripDeleteRequested(widget.trip.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final url = widget.trip.staticMapUrl;
    if (url == null || url.isEmpty) {
      return _CompactTripRow(
        trip: widget.trip,
        subtitle: _subtitle(),
        onTap: () => context.push(ScreenPaths.trip(widget.trip.id)),
        onLongPress: _confirmDelete,
      );
    }

    final accent = colorForDayNumber(widget.trip.days.length);
    final dayLabel = widget.trip.days.length == 1
        ? $strings.myTripsDaysOne
        : $strings.myTripsDaysOther(widget.trip.days.length);

    final card = Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: colors.accent1.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        hoverColor: Colors.white.withValues(alpha: 0.03),
        onTap: () => context.push(ScreenPaths.trip(widget.trip.id)),
        onLongPress: _confirmDelete,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    // Backend-signed URL — DO NOT re-encode. Dart's Uri.encode
                    // re-percents the `|` characters which makes the
                    // signature invalid and the static-map endpoint 403s.
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: $styles.colors.surface),
                    errorWidget: (_, _, _) =>
                        Container(color: $styles.colors.surface),
                  ),
                  // Bottom mask so the chip + future text overlays stay
                  // legible on busy/colorful maps.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                            stops: const [0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: _DayCountChip(label: dayLabel, accent: accent),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: $styles.insets.sm,
                vertical: $styles.insets.xs + 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTripTitle(widget.trip.title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: $styles.text.bodyBold
                              .copyWith(color: colors.offWhite),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: $styles.text.bodySmall
                              .copyWith(color: colors.greyMedium),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.greyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Light press-scale via flutter_animate so taps feel responsive. The
    // Listener layers on top of InkWell so we don't fight its ripple.
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: card
          .animate(target: _pressed ? 1 : 0)
          .scaleXY(end: 0.97, duration: 90.ms, curve: Curves.easeOut),
    );
  }
}

/// Legacy compact row used when `trip.staticMapUrl` is null (pre-enrichment
/// trips, backend API-key outages). Identical to the original `_TripRow`
/// shape so nothing visually regresses for those rows.
class _CompactTripRow extends StatelessWidget {
  const _CompactTripRow({
    required this.trip,
    required this.subtitle,
    required this.onTap,
    required this.onLongPress,
  });

  final Trip trip;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: colors.accent1.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        hoverColor: Colors.white.withValues(alpha: 0.03),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all($styles.insets.sm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.accent1.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.map_outlined,
                  color: colors.accent1,
                  size: 22,
                ),
              ),
              SizedBox(width: $styles.insets.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTripTitle(trip.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: $styles.text.bodyBold.copyWith(
                        color: colors.offWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: $styles.text.bodySmall.copyWith(
                        color: colors.greyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.greyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill overlay on the banner card — "3 days" tinted with the trip's
/// first-day accent from `kDayColors`. Border + dark backdrop keep it
/// legible against any map tile underneath.
class _DayCountChip extends StatelessWidget {
  const _DayCountChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular($styles.corners.pill),
        border: Border.all(color: accent, width: 1),
      ),
      child: Text(
        label,
        style: $styles.text.bodySmallBold.copyWith(color: accent),
      ),
    );
  }
}
