import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/domain/entities/trip_day.dart';
import 'package:travel_buddy/domain/entities/trip_stop.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_bloc.dart';
import 'package:travel_buddy/features/buddy/bloc/buddy_event.dart';
import 'package:travel_buddy/features/trips/bloc/trips_bloc.dart';
import 'package:travel_buddy/features/trips/bloc/trips_event.dart';
import 'package:travel_buddy/features/trips/bloc/trips_state.dart';
import 'package:travel_buddy/features/visit_detection/bloc/visit_detector_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_buddy/logic/auto_track_prefs.dart';
import 'package:travel_buddy/logic/locale_logic.dart';
import 'package:travel_buddy/services/location_service.dart';
import 'package:travel_buddy/services/trip_service.dart';
import 'package:travel_buddy/ui/common/modals/destructive_confirm_sheet.dart';
import 'package:travel_buddy/ui/common/themed_date_picker.dart';
import 'package:travel_buddy/ui/screens/my_trips/widgets/edit_stop_sheet.dart';
import 'package:travel_buddy/ui/screens/my_trips/widgets/trip_detail_map_header.dart';
import 'package:travel_buddy/ui/screens/my_trips/widgets/trip_error_banner.dart';
import 'package:travel_buddy/utils/dlog.dart';

// Most edit-mode strings in this file are now localized via `$strings`. The
// remaining hardcoded surface is in `edit_stop_sheet.dart` (hint placeholders)
// — separate follow-up.
class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool _coldStartLoading = false;
  String? _coldStartError;
  bool _openingRefine = false;
  bool _consentSheetShown = false;

  /// Heartbeat for the rail-node status flip (upcoming → current → past).
  /// Emits once per minute; the timeline's StreamBuilder rebuilds with the
  /// new wall-clock time. Completion state itself is driven by the server
  /// (via [TripStop.completedAt]) and is independent of this tick.
  late final Stream<DateTime> _nowTick = Stream<DateTime>.periodic(
    const Duration(seconds: 60),
    (_) => DateTime.now(),
  ).asBroadcastStream();

  late final VisitDetectorBloc _visitDetector = VisitDetectorBloc(
    tripsBloc: context.read<TripsBloc>(),
    locationService: GetIt.I<LocationService>(),
    autoTrackPrefs: GetIt.I<AutoTrackPrefs>(),
  );

  @override
  void initState() {
    super.initState();
    _ensureLoaded();
    _initAutoTrack();
  }

  @override
  void dispose() {
    _visitDetector.close();
    super.dispose();
  }

  Future<void> _initAutoTrack() async {
    final prefs = GetIt.I<AutoTrackPrefs>();
    await prefs.load();
    if (!mounted) return;
    final tripId = widget.tripId;
    final decision = prefs.decisionFor(tripId);
    if (decision == true) {
      _visitDetector.add(VisitDetectorActivated(tripId));
    }
    // Decision == null is handled in build() once we have the Trip, so we can
    // check the date window before nagging the user about a long-past trip.
  }

  Future<void> _maybeShowConsentSheet(Trip trip) async {
    if (_consentSheetShown) return;
    final prefs = GetIt.I<AutoTrackPrefs>();
    if (prefs.decisionFor(trip.id) != null) return;
    if (!_isTripInDateWindow(trip)) return;
    _consentSheetShown = true;
    final choice = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      isScrollControlled: true,
      builder: (ctx) => _AutoTrackConsentSheet(),
    );
    if (!mounted) return;
    if (choice == true) {
      final status = await GetIt.I<LocationService>().requestForUse();
      if (!mounted) return;
      if (status == LocationEnableStatus.granted) {
        await prefs.setEnabled(trip.id, true);
        _visitDetector.add(VisitDetectorActivated(trip.id));
      } else {
        await prefs.setEnabled(trip.id, false);
        await _showAutoTrackError(status, trip);
      }
    } else if (choice == false) {
      await prefs.setEnabled(trip.id, false);
    }
  }

  Future<void> _toggleAutoTrack(Trip trip) async {
    final prefs = GetIt.I<AutoTrackPrefs>();
    final wasEnabled = prefs.isEnabled(trip.id);
    if (wasEnabled) {
      await prefs.setEnabled(trip.id, false);
      _visitDetector.add(const VisitDetectorDeactivated());
    } else {
      final status = await GetIt.I<LocationService>().requestForUse();
      if (!mounted) return;
      if (status == LocationEnableStatus.granted) {
        await prefs.setEnabled(trip.id, true);
        _visitDetector.add(VisitDetectorActivated(trip.id));
      } else {
        await prefs.setEnabled(trip.id, false);
        await _showAutoTrackError(status, trip);
      }
    }
    if (mounted) setState(() {});
  }

  /// Surfaces a sheet explaining why the user's tap on "Enable visit
  /// auto-tracking" didn't activate, with an actionable primary CTA per
  /// status: re-prompt for `denied`, Settings deep-link for
  /// `deniedForever`/`serviceDisabled`. No-op for `granted`.
  Future<void> _showAutoTrackError(
      LocationEnableStatus status, Trip trip) async {
    if (status == LocationEnableStatus.granted) return;
    final location = GetIt.I<LocationService>();
    final String title;
    final String body;
    final String primaryLabel;
    final VoidCallback onPrimary;
    switch (status) {
      case LocationEnableStatus.denied:
        title = $strings.tripDetailAutoTrackErrorPermissionTitle;
        body = $strings.tripDetailAutoTrackErrorPermissionBody;
        primaryLabel = $strings.tripDetailAutoTrackErrorRetry;
        onPrimary = () => _toggleAutoTrack(trip);
      case LocationEnableStatus.deniedForever:
        title = $strings.tripDetailAutoTrackErrorPermissionTitle;
        body = $strings.tripDetailAutoTrackErrorBlockedBody;
        primaryLabel = $strings.tripDetailAutoTrackErrorOpenSettings;
        onPrimary = () => location.openAppSettings();
      case LocationEnableStatus.serviceDisabled:
        title = $strings.tripDetailAutoTrackErrorServiceTitle;
        body = $strings.tripDetailAutoTrackErrorServiceBody;
        primaryLabel = $strings.tripDetailAutoTrackErrorOpenSettings;
        onPrimary = () => location.openLocationSettings();
      case LocationEnableStatus.granted:
        return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      isScrollControlled: true,
      builder: (ctx) => _AutoTrackErrorSheet(
        title: title,
        body: body,
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
      ),
    );
  }

  bool _isTripInDateWindow(Trip trip) {
    final start = trip.startDate;
    if (start == null) return false;
    final startDay = DateTime(start.year, start.month, start.day);
    final endExclusive = startDay.add(Duration(days: trip.days.length + 1));
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    return !todayDay.isBefore(startDay) && todayDay.isBefore(endExclusive);
  }

  Future<void> _ensureLoaded() async {
    final cached = context.read<TripsBloc>().state.trips
        .where((t) => t.id == widget.tripId)
        .cast<Trip?>()
        .firstWhere((_) => true, orElse: () => null);
    if (cached != null) return;
    setState(() => _coldStartLoading = true);
    try {
      final fetched = await GetIt.I<TripService>().getTrip(
        widget.tripId,
        bearerToken:
            Supabase.instance.client.auth.currentSession?.accessToken,
      );
      if (!mounted) return;
      context.read<TripsBloc>().add(TripMerged(fetched));
      setState(() => _coldStartLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _coldStartError = '$e';
        _coldStartLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VisitDetectorBloc>.value(
      value: _visitDetector,
      child: ColoredBox(
      color: $styles.colors.black,
      child: SafeArea(
        bottom: false,
        child: BlocSelector<TripsBloc, TripsState, List<Trip>>(
          selector: (s) => s.trips,
          builder: (ctx, trips) {
            final trip = trips
                .cast<Trip?>()
                .firstWhere(
                  (t) => t?.id == widget.tripId,
                  orElse: () => null,
                );
            if (trip != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _maybeShowConsentSheet(trip),
              );
            }
            return Column(
              children: [
                _AppBar(
                  trip: trip,
                  onBack: () => context.pop(),
                  onRename: trip == null
                      ? null
                      : (next) {
                          if (next != trip.title) {
                            context
                                .read<TripsBloc>()
                                .add(TripRenameRequested(trip.id, next));
                          }
                        },
                  onDelete:
                      trip == null ? null : () => _confirmDeleteTrip(trip),
                  // Reads on every rebuild; cheap (in-memory map) and reflects
                  // the latest setEnabled() write without extra plumbing.
                  autoTrackEnabled: trip == null
                      ? null
                      : GetIt.I<AutoTrackPrefs>().isEnabled(trip.id),
                  onToggleAutoTrack:
                      trip == null ? null : () => _toggleAutoTrack(trip),
                  onEditSummary: trip == null ? null : () => _editSummary(trip),
                  onChangeStartDate:
                      trip == null ? null : () => _editStartDate(trip),
                  onClearStartDate: trip == null || trip.startDate == null
                      ? null
                      : () => _confirmClearStartDate(trip),
                ),
                const TripErrorBanner(),
                if (trip != null) TripDetailMapHeader(trip: trip),
                if (trip != null)
                  _RefineCta(
                    busy: _openingRefine,
                    onTap: () => _openRefine(trip),
                  ),
                Expanded(child: _buildBody(trip)),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  Widget _buildBody(Trip? trip) {
    if (trip == null) {
      if (_coldStartLoading) {
        return Center(
          child: CircularProgressIndicator(color: $styles.colors.accent1),
        );
      }
      if (_coldStartError != null) {
        return Center(
          child: Text(
            $strings.buddyErrorHint,
            style: $styles.text.body.copyWith(color: Colors.redAccent),
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return StreamBuilder<DateTime>(
      initialData: DateTime.now(),
      stream: _nowTick,
      builder: (_, snap) {
        // Inline-undo: a separate BlocSelector keeps the timeline from
        // rebuilding on unrelated state changes. Selector returns a map of
        // dayId → ordered records so the per-day rendering can interleave
        // banners with live stops by sortOrder.
        return BlocSelector<TripsBloc, TripsState,
            Map<String, List<UndoStopRecord>>>(
          selector: (s) {
            if (s.pendingUndoStops.isEmpty) return const {};
            final byDay = <String, List<UndoStopRecord>>{};
            for (final r in s.pendingUndoStops.values) {
              (byDay[r.dayId] ??= <UndoStopRecord>[]).add(r);
            }
            return byDay;
          },
          builder: (_, undoByDay) => _TimelineList(
            trip: trip,
            now: snap.data ?? DateTime.now(),
            undoByDay: undoByDay,
            onSummaryTap: () => _editSummary(trip),
            onDayMenu: (day) => _showDayActions(trip, day),
            // Edit-stop sheet temporarily disabled (user request). Tap on a
            // card is a no-op for now; long-press still opens the action
            // sheet (Move to day / Duplicate / Delete). Restore by routing
            // back through `_editStop`.
            onStopTap: (_, _) {},
            onStopLongPress: (day, stop) => _showStopActions(trip, day, stop),
            onStopAdd: (_) {},
            onDayAdd: () => _addDay(trip),
            onReorder: (day, newIds) => context
                .read<TripsBloc>()
                .add(StopsReorderRequested(trip.id, day.id, newIds)),
            onUndoDelete: (stopId) => context
                .read<TripsBloc>()
                .add(StopDeleteUndoRequested(stopId)),
          ),
        );
      },
    );
  }

  // ---- edit handlers ----

  Future<void> _openRefine(Trip trip) async {
    if (_openingRefine) return;
    setState(() => _openingRefine = true);
    final buddy = context.read<BuddyBloc>();
    final tripsBloc = context.read<TripsBloc>();
    buddy.add(BuddyOpenRefineRequested(trip));
    try {
      // BuddyOpenRefineRequested fetches + emits scopedTrip on success or
      // lastError on failure. Mirrors the legacy `await openRefineForTrip`
      // contract via `bloc.stream.firstWhere`.
      final s = await buddy.stream.firstWhere(
        (s) =>
            (s.scopedTrip?.id == trip.id && s.lastError == null) ||
            s.lastError != null,
      );
      if (!mounted) return;
      if (s.lastError != null) {
        dlog('refine open failed: ${s.lastError}', name: 'refine.open');
        tripsBloc.add(TripsErrorSurfaced($strings.refineOpenFailed));
        return;
      }
      // BuddyOpenRefineRequested already set requestedTab=1, which AppShell's
      // BlocListener consumed to switch to the Buddy tab — but AppShell is
      // *under* this route, so the user sees no change until they pop. Pop
      // the trip-detail route so they land directly on the now-scoped chat.
      // canPop guards against deep-link entry where this route is the bottom
      // of the stack.
      if (context.canPop()) context.pop();
    } finally {
      if (mounted) setState(() => _openingRefine = false);
    }
  }

  Future<void> _confirmDeleteTrip(Trip trip) async {
    final ok = await showDestructiveConfirmSheet(
      context,
      title: $strings.myTripsDeleteTitle,
      body: $strings.myTripsDeleteBody,
      confirmLabel: $strings.myTripsDeleteConfirm,
      cancelLabel: $strings.myTripsDeleteCancel,
    );
    if (!ok || !mounted) return;
    context.read<TripsBloc>().add(TripDeleteRequested(trip.id));
    context.pop();
  }

  Future<void> _editSummary(Trip trip) async {
    final result = await _showTextEditDialog(
      title: 'Summary',
      initial: trip.summary ?? '',
      maxLength: 500,
      maxLines: 4,
      allowClear: true,
    );
    if (result == null) return;
    final next = result.isEmpty ? null : result;
    if (next == trip.summary) return;
    if (!mounted) return;
    context.read<TripsBloc>().add(TripSummaryUpdateRequested(trip.id, next));
  }

  Future<void> _editStartDate(Trip trip) async {
    final initial = trip.startDate ?? DateTime.now();
    final picked = await showThemedDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: $strings.buddyItineraryPickStartDateHelp,
      locale: Localizations.localeOf(context),
    );
    if (picked == null) return;
    final stripped = DateTime(picked.year, picked.month, picked.day);
    if (trip.startDate != null &&
        stripped.year == trip.startDate!.year &&
        stripped.month == trip.startDate!.month &&
        stripped.day == trip.startDate!.day) {
      return;
    }
    if (!mounted) return;
    context
        .read<TripsBloc>()
        .add(TripStartDateUpdateRequested(trip.id, startDate: stripped));
  }

  Future<void> _confirmClearStartDate(Trip trip) async {
    if (trip.startDate == null) return;
    final ok = await showDestructiveConfirmSheet(
      context,
      title: 'Clear start date?',
      body: 'The trip will no longer show calendar dates.',
      confirmLabel: 'Clear',
      cancelLabel: $strings.myTripsDeleteCancel,
      confirmIcon: Icons.event_busy_outlined,
    );
    if (!ok || !mounted) return;
    context
        .read<TripsBloc>()
        .add(TripStartDateUpdateRequested(trip.id, clear: true));
  }

  Future<void> _confirmDeleteDay(Trip trip, TripDay day) async {
    final ok = await showDestructiveConfirmSheet(
      context,
      title: 'Delete day?',
      body: 'All stops in this day will be removed.',
      confirmLabel: $strings.myTripsDeleteConfirm,
      cancelLabel: $strings.myTripsDeleteCancel,
    );
    if (!ok || !mounted) return;
    context.read<TripsBloc>().add(DayDeleteRequested(trip.id, day.id));
  }

  Future<void> _editStop(Trip trip, TripDay day, TripStop stop) async {
    final patch = await EditStopSheet.show(context, initial: stop);
    if (patch == null || patch.isEmpty) return;
    if (!mounted) return;
    context
        .read<TripsBloc>()
        .add(StopEditRequested(trip.id, day.id, stop.id, patch));
  }

  /// Long-press menu shown over a stop card in edit mode. Routes to the
  /// existing edit / delete handlers and to the new move-to-day picker. Lives
  /// here (not in a shared widget) because it threads `trip` + `day` through
  /// without ceremony — same trade-off as `_confirmDeleteStop`.
  Future<void> _showStopActions(
    Trip trip,
    TripDay day,
    TripStop stop,
  ) async {
    final action = await showModalBottomSheet<_StopAction>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular($styles.corners.md),
        ),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: $styles.insets.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  $styles.insets.lg,
                  0,
                  $styles.insets.lg,
                  $styles.insets.sm,
                ),
                child: Text(
                  stop.name,
                  style: $styles.text.bodyBold
                      .copyWith(color: $styles.colors.offWhite),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // "Edit" row removed with the Edit-stop sheet (user request).
              // Hide "Move to day" when there's no other day to move into.
              if (trip.days.length > 1)
                ListTile(
                  leading: Icon(
                    Icons.swap_horiz_rounded,
                    color: $styles.colors.offWhite,
                  ),
                  title: Text(
                    $strings.tripDetailStopActionMove,
                    style: $styles.text.bodyBold
                        .copyWith(color: $styles.colors.offWhite),
                  ),
                  onTap: () => Navigator.of(sheetCtx).pop(_StopAction.move),
                ),
              ListTile(
                leading: Icon(
                  Icons.content_copy_outlined,
                  color: $styles.colors.offWhite,
                ),
                title: Text(
                  $strings.tripDetailStopActionDuplicate,
                  style: $styles.text.bodyBold
                      .copyWith(color: $styles.colors.offWhite),
                ),
                onTap: () => Navigator.of(sheetCtx).pop(_StopAction.duplicate),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: Text(
                  $strings.tripDetailStopActionDelete,
                  style: $styles.text.bodyBold.copyWith(color: Colors.redAccent),
                ),
                onTap: () => Navigator.of(sheetCtx).pop(_StopAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _StopAction.move:
        await _showMoveStopSheet(trip, day, stop);
      case _StopAction.duplicate:
        _duplicateStop(trip, day, stop);
      case _StopAction.delete:
        await _confirmDeleteStop(trip, day, stop);
    }
  }

  /// Insert a copy of `stop` immediately after it. Reuses [StopAddRequested]
  /// (no dedicated backend endpoint needed); position is the current stop's
  /// sortOrder + 1 so the duplicate appears right below the original.
  /// `completed_at`, enrichment, and the original's id are NOT copied — a
  /// duplicate is conceptually a new stop with the same plan. Encoding
  /// follows the same `kind == unknown → "activity"` coercion as
  /// `ItineraryDraft.toCreateJson` so Pydantic's Literal doesn't reject.
  void _duplicateStop(Trip trip, TripDay day, TripStop stop) {
    final kindStr =
        stop.kind == StopKind.unknown ? 'activity' : stop.kind.name;
    final transportStr =
        (stop.transportation == null ||
                stop.transportation == TransportationKind.unknown)
            ? null
            : stop.transportation!.name;
    final body = <String, dynamic>{
      'name': stop.name,
      'kind': kindStr,
      if (stop.city != null && stop.city!.isNotEmpty) 'city': stop.city,
      if (stop.address != null && stop.address!.isNotEmpty)
        'address': stop.address,
      if (stop.durationMinutes != null)
        'duration_minutes': stop.durationMinutes,
      if (stop.arrivalTime != null) 'arrival_time': stop.arrivalTime,
      if (stop.endTime != null) 'end_time': stop.endTime,
      if (transportStr != null) 'transportation': transportStr,
      if (stop.notes != null && stop.notes!.isNotEmpty) 'notes': stop.notes,
      if (stop.lat != null) 'lat': stop.lat,
      if (stop.lng != null) 'lng': stop.lng,
      if (stop.googlePlaceId != null && stop.googlePlaceId!.isNotEmpty)
        'google_place_id': stop.googlePlaceId,
    };
    context.read<TripsBloc>().add(
          StopAddRequested(
            trip.id,
            day.id,
            body,
            sortOrder: stop.sortOrder + 1,
          ),
        );
  }

  /// Day-header overflow menu. Routes the choice to existing helpers
  /// (rename / change base city use `_showTextEditDialog`; delete reuses
  /// `_confirmDeleteDay`). Closes the long-standing `TODO(day-edit)`
  /// because the day's title and base_city are now patchable post-creation.
  Future<void> _showDayActions(Trip trip, TripDay day) async {
    final action = await showModalBottomSheet<_DayAction>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular($styles.corners.md),
        ),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: $styles.insets.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  $styles.insets.lg,
                  0,
                  $styles.insets.lg,
                  $styles.insets.sm,
                ),
                child: Text(
                  $strings.tripDetailDayLabel(day.dayNumber),
                  style: $styles.text.bodyBold
                      .copyWith(color: $styles.colors.offWhite),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.drive_file_rename_outline,
                  color: $styles.colors.offWhite,
                ),
                title: Text(
                  $strings.tripDetailDayActionRename,
                  style: $styles.text.bodyBold
                      .copyWith(color: $styles.colors.offWhite),
                ),
                onTap: () => Navigator.of(sheetCtx).pop(_DayAction.rename),
              ),
              ListTile(
                leading: Icon(
                  Icons.location_city_outlined,
                  color: $styles.colors.offWhite,
                ),
                title: Text(
                  $strings.tripDetailDayActionChangeBaseCity,
                  style: $styles.text.bodyBold
                      .copyWith(color: $styles.colors.offWhite),
                ),
                onTap: () => Navigator.of(sheetCtx).pop(_DayAction.baseCity),
              ),
              // "Add stop here" row removed with the Edit-stop sheet
              // (user request) — it depends on the add-stop sheet.
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: Text(
                  $strings.tripDetailDayActionDelete,
                  style: $styles.text.bodyBold.copyWith(color: Colors.redAccent),
                ),
                onTap: () => Navigator.of(sheetCtx).pop(_DayAction.delete),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _DayAction.rename:
        final next = await _showTextEditDialog(
          title: $strings.tripDetailRenameDayDialogTitle,
          initial: day.title ?? '',
          maxLength: 200,
          maxLines: 1,
          allowClear: true,
        );
        if (next == null || !mounted) return;
        final normalized = next.trim().isEmpty ? null : next.trim();
        if (normalized == (day.title?.trim().isEmpty == true
                ? null
                : day.title)) {
          return;
        }
        context.read<TripsBloc>().add(
              DayMetaUpdateRequested(trip.id, day.id, {'title': normalized}),
            );
      case _DayAction.baseCity:
        final next = await _showTextEditDialog(
          title: $strings.tripDetailChangeBaseCityDialogTitle,
          initial: day.baseCity ?? '',
          maxLength: 200,
          maxLines: 1,
          allowClear: true,
        );
        if (next == null || !mounted) return;
        final normalized = next.trim().isEmpty ? null : next.trim();
        if (normalized == (day.baseCity?.trim().isEmpty == true
                ? null
                : day.baseCity)) {
          return;
        }
        context.read<TripsBloc>().add(
              DayMetaUpdateRequested(
                trip.id,
                day.id,
                {'base_city': normalized},
              ),
            );
      case _DayAction.delete:
        await _confirmDeleteDay(trip, day);
    }
  }

  /// Bottom sheet that lists every OTHER day on this trip as a move target.
  /// Picking one dispatches [StopMoveToDayRequested]; the bloc optimistically
  /// removes the stop from the source day and appends it to the target.
  Future<void> _showMoveStopSheet(
    Trip trip,
    TripDay sourceDay,
    TripStop stop,
  ) async {
    final candidates = trip.days
        .where((d) => d.id != sourceDay.id)
        .toList(growable: false);
    if (candidates.isEmpty) return;
    final picked = await showModalBottomSheet<TripDay>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular($styles.corners.md),
        ),
      ),
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: $styles.insets.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  $styles.insets.lg,
                  0,
                  $styles.insets.lg,
                  $styles.insets.xs,
                ),
                child: Text(
                  $strings.tripDetailMoveStopSheetTitle,
                  style: $styles.text.bodyBold
                      .copyWith(color: $styles.colors.offWhite),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  $styles.insets.lg,
                  0,
                  $styles.insets.lg,
                  $styles.insets.sm,
                ),
                child: Text(
                  $strings.tripDetailMoveStopSheetSubtitle(stop.name),
                  style: $styles.text.body
                      .copyWith(color: $styles.colors.greyMedium),
                ),
              ),
              for (final d in candidates)
                ListTile(
                  leading: Icon(
                    Icons.event_outlined,
                    color: $styles.colors.offWhite,
                  ),
                  title: Text(
                    $strings.tripDetailMoveStopOption(
                      d.dayNumber,
                      _moveStopDayLabel(d),
                    ),
                    style: $styles.text.body
                        .copyWith(color: $styles.colors.offWhite),
                  ),
                  onTap: () => Navigator.of(sheetCtx).pop(d),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || picked == null) return;
    context.read<TripsBloc>().add(
          StopMoveToDayRequested(
            tripId: trip.id,
            sourceDayId: sourceDay.id,
            targetDayId: picked.id,
            stopId: stop.id,
          ),
        );
  }

  /// One-line summary for a day used in the move-to-day picker. Falls back
  /// through title → baseCity → stop count so every row has signal.
  String _moveStopDayLabel(TripDay day) {
    final t = day.title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final c = day.baseCity?.trim();
    if (c != null && c.isNotEmpty) return c;
    if (day.stops.isEmpty) return $strings.tripDetailMoveStopOptionEmpty;
    return $strings.tripDetailMoveStopOptionCount(day.stops.length);
  }

  Future<void> _confirmDeleteStop(
    Trip trip,
    TripDay day,
    TripStop stop,
  ) async {
    final ok = await showDestructiveConfirmSheet(
      context,
      title: 'Delete stop?',
      body: 'This stop will be removed.',
      confirmLabel: $strings.myTripsDeleteConfirm,
      cancelLabel: $strings.myTripsDeleteCancel,
    );
    if (!ok || !mounted) return;
    context
        .read<TripsBloc>()
        .add(StopDeleteRequested(trip.id, day.id, stop.id));
  }

  Future<void> _addStop(Trip trip, TripDay day) async {
    final body = await EditStopSheet.show(context);
    if (body == null) return;
    if (!mounted) return;
    context.read<TripsBloc>().add(StopAddRequested(trip.id, day.id, body));
  }

  Future<void> _addDay(Trip trip) async {
    final result = await _showAddDayDialog(trip);
    if (result == null) return;
    if (!mounted) return;
    final bloc = context.read<TripsBloc>();
    if (trip.days.any((d) => d.dayNumber == result.dayNumber)) {
      bloc.add(const TripsErrorSurfaced('That day number already exists.'));
      return;
    }
    bloc.add(DayAddRequested(
      trip.id,
      result.dayNumber,
      title: result.title,
      baseCity: result.baseCity,
    ));
  }

  // ---- helpers ----

  Future<String?> _showTextEditDialog({
    required String title,
    required String initial,
    required int maxLength,
    int maxLines = 1,
    bool requireNonEmpty = false,
    bool allowClear = false,
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final text = controller.text.trim();
            final canSave = !requireNonEmpty || text.isNotEmpty;
            return AlertDialog(
              backgroundColor: $styles.colors.greyStrong,
              title: Text(
                title,
                style: $styles.text.bodyBold.copyWith(
                  color: $styles.colors.offWhite,
                ),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: maxLength,
                maxLines: maxLines,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                ),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (_) => setLocal(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text($strings.myTripsDeleteCancel),
                ),
                if (allowClear)
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(''),
                    child: Text(
                      $strings.tripDetailDialogClear,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                TextButton(
                  onPressed: canSave
                      ? () => Navigator.of(ctx).pop(controller.text.trim())
                      : null,
                  child: Text($strings.tripDetailDialogSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<_AddDayResult?> _showAddDayDialog(Trip trip) {
    final maxDay = trip.days.fold<int>(
      0,
      (acc, d) => d.dayNumber > acc ? d.dayNumber : acc,
    );
    final dayCtrl = TextEditingController(text: '${maxDay + 1}');
    final titleCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    return showDialog<_AddDayResult>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: $styles.colors.greyStrong,
          title: Text(
            $strings.tripDetailAddDayDialogTitle,
            style: $styles.text.bodyBold.copyWith(
              color: $styles.colors.offWhite,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                $strings.tripDetailAddDayNumberField,
                style: $styles.text.bodySmall.copyWith(
                  color: $styles.colors.greyMedium,
                ),
              ),
              TextField(
                controller: dayCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                ),
              ),
              Gap($styles.insets.sm),
              Text(
                $strings.tripDetailAddDayTitleField,
                style: $styles.text.bodySmall.copyWith(
                  color: $styles.colors.greyMedium,
                ),
              ),
              TextField(
                controller: titleCtrl,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                ),
              ),
              Gap($styles.insets.sm),
              Text(
                $strings.tripDetailAddDayBaseCityField,
                style: $styles.text.bodySmall.copyWith(
                  color: $styles.colors.greyMedium,
                ),
              ),
              TextField(
                controller: cityCtrl,
                style: $styles.text.body.copyWith(
                  color: $styles.colors.offWhite,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text($strings.myTripsDeleteCancel),
            ),
            TextButton(
              onPressed: () {
                final n = int.tryParse(dayCtrl.text.trim());
                if (n == null || n < 1) return;
                final t = titleCtrl.text.trim();
                final c = cityCtrl.text.trim();
                Navigator.of(ctx).pop(
                  _AddDayResult(
                    dayNumber: n,
                    title: t.isEmpty ? null : t,
                    baseCity: c.isEmpty ? null : c,
                  ),
                );
              },
              child: Text($strings.tripDetailDialogSave),
            ),
          ],
        );
      },
    );
  }
}

class _AddDayResult {
  const _AddDayResult({
    required this.dayNumber,
    this.title,
    this.baseCity,
  });
  final int dayNumber;
  final String? title;
  final String? baseCity;
}

class _AppBar extends StatefulWidget {
  const _AppBar({
    required this.trip,
    required this.onBack,
    required this.onRename,
    required this.onDelete,
    required this.autoTrackEnabled,
    required this.onToggleAutoTrack,
    required this.onEditSummary,
    required this.onChangeStartDate,
    required this.onClearStartDate,
  });
  // Pass the whole trip (instead of just title) so the inline rename's
  // controller can re-sync when the bloc emits a fresh title in response
  // to a different surface (Buddy refine, server push).
  final Trip? trip;
  final VoidCallback onBack;
  // null while trip is cold-loading. When set, the user can tap the title to
  // inline-rename; submit dispatches via the callback. We don't gate by
  // editing mode anymore — the global toggle is gone.
  final ValueChanged<String>? onRename;
  final VoidCallback? onDelete;
  // null hides the auto-track menu item (e.g. while the trip is still
  // cold-loading and we don't have a tripId yet). Otherwise reflects the
  // persisted opt-in for this trip.
  final bool? autoTrackEnabled;
  final VoidCallback? onToggleAutoTrack;
  // Trip-level edits previously gated by edit mode now live in the kebab so
  // there's no separate mode to enter. Null when unavailable (no trip yet
  // for the first three; no start_date set for clear).
  final VoidCallback? onEditSummary;
  final VoidCallback? onChangeStartDate;
  final VoidCallback? onClearStartDate;

  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> {
  bool _renaming = false;
  late final TextEditingController _controller =
      TextEditingController(text: widget.trip?.title ?? '');
  late final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant _AppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the trip's title changed elsewhere (server / Buddy refine) AND the
    // user isn't actively typing, re-seed the controller. Otherwise we'd
    // stomp their in-progress edit.
    final next = widget.trip?.title ?? '';
    if (!_renaming && next != _controller.text) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startRename() {
    if (widget.onRename == null) return;
    setState(() => _renaming = true);
    // Schedule focus after the next frame so the TextField is mounted before
    // we try to request focus on it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commitRename() {
    if (!_renaming) return;
    final next = _controller.text.trim();
    if (next.isNotEmpty &&
        widget.trip != null &&
        next != widget.trip!.title) {
      widget.onRename?.call(next);
    } else {
      // Restore the canonical title so empty / unchanged submissions don't
      // leave a stale draft sitting in the controller.
      _controller.text = widget.trip?.title ?? '';
    }
    setState(() => _renaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final title = widget.trip?.title ?? '';
    final titleWidget = _renaming
        ? TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            cursorColor: colors.accent1,
            maxLines: 1,
            style: $styles.text.h4.copyWith(color: colors.offWhite),
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _commitRename(),
            onTapOutside: (_) => _commitRename(),
          )
        : Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: $styles.text.h4.copyWith(color: colors.offWhite),
          );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.xs,
        vertical: $styles.insets.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.offWhite),
            onPressed: widget.onBack,
          ),
          Expanded(
            child: widget.onRename == null || _renaming
                ? titleWidget
                : InkWell(onTap: _startRename, child: titleWidget),
          ),
          if (widget.onDelete != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colors.offWhite),
              color: colors.greyStrong,
              onSelected: (v) {
                switch (v) {
                  case 'edit_summary':
                    widget.onEditSummary?.call();
                  case 'change_start_date':
                    widget.onChangeStartDate?.call();
                  case 'clear_start_date':
                    widget.onClearStartDate?.call();
                  case 'autotrack':
                    widget.onToggleAutoTrack?.call();
                  case 'delete':
                    widget.onDelete?.call();
                }
              },
              itemBuilder: (_) => [
                if (widget.onEditSummary != null)
                  PopupMenuItem(
                    value: 'edit_summary',
                    child: _kebabRow(
                      Icons.notes_outlined,
                      $strings.tripDetailKebabEditSummary,
                      colors,
                    ),
                  ),
                if (widget.onChangeStartDate != null)
                  PopupMenuItem(
                    value: 'change_start_date',
                    child: _kebabRow(
                      Icons.calendar_today_outlined,
                      $strings.tripDetailKebabChangeStartDate,
                      colors,
                    ),
                  ),
                if (widget.onClearStartDate != null)
                  PopupMenuItem(
                    value: 'clear_start_date',
                    child: _kebabRow(
                      Icons.event_busy_outlined,
                      $strings.tripDetailKebabClearStartDate,
                      colors,
                    ),
                  ),
                if (widget.autoTrackEnabled != null &&
                    widget.onToggleAutoTrack != null)
                  PopupMenuItem(
                    value: 'autotrack',
                    child: _kebabRow(
                      widget.autoTrackEnabled!
                          ? Icons.location_off_outlined
                          : Icons.location_on_outlined,
                      widget.autoTrackEnabled!
                          ? $strings.tripDetailAutoTrackDisableMenu
                          : $strings.tripDetailAutoTrackEnableMenu,
                      colors,
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    $strings.myTripsDeleteConfirm,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static Widget _kebabRow(IconData icon, String label, dynamic colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colors.accent1),
        const SizedBox(width: 8),
        Text(
          label,
          style: $styles.text.body.copyWith(color: colors.offWhite),
        ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({
    required this.trip,
    required this.now,
    required this.undoByDay,
    required this.onSummaryTap,
    required this.onDayMenu,
    required this.onStopTap,
    required this.onStopLongPress,
    required this.onStopAdd,
    required this.onDayAdd,
    required this.onReorder,
    required this.onUndoDelete,
  });
  final Trip trip;
  // Refreshed every 60s from the screen-level Stream.periodic so the rail
  // node flips upcoming → current → past without an explicit user action.
  // Completion ("visited") is independent and driven by `stop.completedAt`.
  final DateTime now;
  // Per-day inline-undo records keyed by dayId. Empty when no deletions
  // are within the 5s undo window. Map values may have >1 entry if the
  // user deleted several stops quickly.
  final Map<String, List<UndoStopRecord>> undoByDay;
  final VoidCallback onSummaryTap;
  final ValueChanged<TripDay> onDayMenu;
  final void Function(TripDay day, TripStop stop) onStopTap;
  final void Function(TripDay day, TripStop stop) onStopLongPress;
  final ValueChanged<TripDay> onStopAdd;
  final VoidCallback onDayAdd;
  final void Function(TripDay day, List<String> orderedStopIds) onReorder;
  final ValueChanged<String> onUndoDelete;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      _SummarySection(trip: trip, onTap: onSummaryTap),
    ];

    // Flat list of (day, stop) tuples across all days. Used so the rail's
    // "progress trail" segment between two visited stops stays solid even
    // when crossing a day boundary.
    final flat = <(TripDay, TripStop)>[
      for (final d in trip.days)
        for (final s in d.stops) (d, s),
    ];

    for (var d = 0; d < trip.days.length; d++) {
      final day = trip.days[d];
      widgets.add(
        _DayHeader(
          trip: trip,
          day: day,
          onMenu: () => onDayMenu(day),
        ),
      );
      final dayUndos = undoByDay[day.id] ?? const <UndoStopRecord>[];
      if (day.stops.isEmpty && dayUndos.isEmpty) {
        widgets.add(const _EmptyDayPlaceholder());
        // _AddStopButton removed with the Edit-stop sheet (user request).
        continue;
      }
      widgets.add(
        _ReorderableTimelineDay(
          trip: trip,
          day: day,
          flat: flat,
          now: now,
          undoRecords: dayUndos,
          onStopTap: (stop) => onStopTap(day, stop),
          onStopLongPress: (stop) => onStopLongPress(day, stop),
          onReorder: (newIds) => onReorder(day, newIds),
          onUndoDelete: onUndoDelete,
        ),
      );
      // _AddStopButton removed with the Edit-stop sheet (user request).
    }

    widgets.add(_AddDayButton(onTap: onDayAdd));

    // ListView.builder lets Flutter lazily lay out off-screen day rows
    // instead of building the entire `widgets` list up-front (the list itself
    // is still O(n), but per-row layout work is now demand-driven). For trips
    // with many days, this keeps the first frame fast.
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
      padding: EdgeInsets.only(bottom: $styles.insets.xl),
      itemCount: widgets.length,
      itemBuilder: (_, i) => widgets[i],
    );
  }
}

/// Renders one day's stops as a reorderable list, preserving the rail
/// visualization (rail nodes, visit-mark popover, progress-trail line)
/// while making the card itself tappable/long-pressable and exposing a
/// subtle drag handle. Replaces the old editing-only `_ReorderableDayStops`
/// — the contextual redesign removes the global edit toggle, so this is
/// the only stop layout left.
class _ReorderableTimelineDay extends StatelessWidget {
  const _ReorderableTimelineDay({
    required this.trip,
    required this.day,
    required this.flat,
    required this.now,
    required this.undoRecords,
    required this.onStopTap,
    required this.onStopLongPress,
    required this.onReorder,
    required this.onUndoDelete,
  });
  final Trip trip;
  final TripDay day;
  // Cross-day flat list used by `_StopRow` for the progress-trail
  // (prev/next visited) lookup. We pass the snapshot through verbatim so
  // the rail line stays consistent across day boundaries during reorder.
  final List<(TripDay, TripStop)> flat;
  final DateTime now;
  // Empty in the common case; non-empty during the 5s undo window after
  // a stop on this day was deleted. When present, we switch to a static
  // Column so drag-to-reorder doesn't fight the banner's position.
  final List<UndoStopRecord> undoRecords;
  final ValueChanged<TripStop> onStopTap;
  final ValueChanged<TripStop> onStopLongPress;
  final ValueChanged<List<String>> onReorder;
  final ValueChanged<String> onUndoDelete;

  @override
  Widget build(BuildContext context) {
    if (undoRecords.isNotEmpty) {
      return _buildMixed(context);
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: day.stops.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final ids = day.stops.map((s) => s.id).toList(growable: true);
        final moved = ids.removeAt(oldIndex);
        ids.insert(newIndex, moved);
        onReorder(ids);
      },
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: child,
      ),
      itemBuilder: (ctx, i) {
        final stop = day.stops[i];
        return _buildStopRow(stop, i);
      },
    );
  }

  /// Render the day with live stops + undo banners interleaved by
  /// sortOrder. Drag-to-reorder is disabled during this window — the
  /// presence of banners means the user is mid-decision and a sudden
  /// reorder would scramble the layout under them. Reverts to the
  /// ReorderableListView path the moment `undoRecords` empties.
  Widget _buildMixed(BuildContext context) {
    final items = <(int, Widget)>[
      for (final stop in day.stops)
        (stop.sortOrder, _buildStopRow(stop, null)),
      for (final r in undoRecords)
        (r.originalSortOrder, _buildUndoBanner(r)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return Column(children: [for (final (_, w) in items) w]);
  }

  Widget _buildStopRow(TripStop stop, int? dragIndex) {
    final flatIdx = flat.indexWhere((e) => e.$2.id == stop.id);
    final isFirstOverall = flatIdx == 0;
    final isLastOverall = flatIdx == flat.length - 1;
    final prevVisited =
        flatIdx > 0 && flat[flatIdx - 1].$2.completedAt != null;
    final nextVisited = flatIdx >= 0 &&
        flatIdx < flat.length - 1 &&
        flat[flatIdx + 1].$2.completedAt != null;
    return _StopRow(
      key: ValueKey(stop.id),
      trip: trip,
      day: day,
      stop: stop,
      isFirst: isFirstOverall,
      isLast: isLastOverall,
      now: now,
      prevVisited: prevVisited,
      nextVisited: nextVisited,
      onTap: () => onStopTap(stop),
      onLongPress: () => onStopLongPress(stop),
      dragHandleIndex: dragIndex,
    );
  }

  Widget _buildUndoBanner(UndoStopRecord r) {
    return _UndoBanner(
      key: ValueKey('undo-${r.stopId}'),
      stopName: r.stopName,
      onUndo: () => onUndoDelete(r.stopId),
    );
  }
}

/// Inline banner that takes a deleted stop's slot in the timeline for the
/// 5-second undo window. Tap UNDO to recreate the stop (via the bloc's
/// `StopAddRequested` path, preserving sortOrder; `completed_at` is lost).
class _UndoBanner extends StatelessWidget {
  const _UndoBanner({super.key, required this.stopName, required this.onUndo});
  final String stopName;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.xxs,
        $styles.insets.md,
        $styles.insets.xxs,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: $styles.insets.sm,
          vertical: $styles.insets.xs,
        ),
        decoration: BoxDecoration(
          color: colors.greyMedium.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.delete_sweep_outlined,
              size: 18,
              color: colors.greyMedium,
            ),
            SizedBox(width: $styles.insets.xs),
            Expanded(
              child: Text(
                $strings.tripDetailUndoStopBanner(stopName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: $styles.text.body.copyWith(color: colors.greyMedium),
              ),
            ),
            TextButton(
              onPressed: onUndo,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: $styles.insets.xs,
                ),
                minimumSize: const Size(0, 32),
              ),
              child: Text(
                $strings.tripDetailUndoStopButton,
                style: $styles.text.bodyBold.copyWith(color: colors.accent1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.trip, required this.onTap});
  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final hasSummary = trip.summary != null && trip.summary!.isNotEmpty;
    // Always rendered + tappable now (the global edit toggle is gone). When
    // empty, an italic placeholder doubles as the affordance to add one.
    final text = hasSummary
        ? trip.summary!
        : $strings.tripDetailSummaryPlaceholder;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          $styles.insets.md,
          $styles.insets.xs,
          $styles.insets.md,
          $styles.insets.sm,
        ),
        child: Text(
          text,
          style: $styles.text.body.copyWith(
            color: hasSummary ? colors.greyMedium : colors.caption,
            fontStyle: hasSummary ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.trip,
    required this.day,
    required this.onMenu,
  });
  final Trip trip;
  final TripDay day;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final locale = GetIt.I<LocaleLogic>().strings.localeName;
    final dateLabel = trip.startDate != null
        ? DateFormat.MMMEd(locale).format(
            trip.startDate!.add(Duration(days: day.dayNumber - 1)),
          )
        : null;
    final descriptor = day.title?.trim().isNotEmpty == true
        ? day.title!
        : (day.baseCity?.trim().isNotEmpty == true ? day.baseCity! : '');

    final visitedCount = day.stops.where((s) => s.completedAt != null).length;
    final showProgress = visitedCount > 0 && day.stops.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.md,
        $styles.insets.md,
        $styles.insets.xs,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: colors.accent1.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
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
          ] else
            const Spacer(),
          if (showProgress) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: colors.accent1.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                $strings.tripDetailDayProgress(visitedCount, day.stops.length),
                style: $styles.text.bodySmall.copyWith(color: colors.accent1),
              ),
            ),
            SizedBox(width: $styles.insets.xs),
          ],
          if (dateLabel != null) ...[
            Text(
              dateLabel,
              style: $styles.text.bodySmall.copyWith(color: colors.greyMedium),
            ),
            SizedBox(width: $styles.insets.xs),
          ],
          IconButton(
            icon: Icon(Icons.more_horiz, color: colors.greyMedium, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.xs,
        $styles.insets.md,
        $styles.insets.xs,
      ),
      child: Container(
        padding: EdgeInsets.all($styles.insets.sm),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.greyMedium.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          $strings.tripDetailEmptyDayHint,
          textAlign: TextAlign.center,
          style: $styles.text.body.copyWith(color: colors.greyMedium),
        ),
      ),
    );
  }
}

/// Low-contrast "+ Add stop" rendered at the foot of every day. Always
/// visible in the contextual redesign — it's the primary affordance to
/// extend a day, no longer gated by edit mode.
class _AddStopButton extends StatelessWidget {
  const _AddStopButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.xs,
        $styles.insets.md,
        $styles.insets.sm,
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.add, size: 16, color: colors.greyMedium),
        label: Text(
          $strings.tripDetailAddStop,
          style: $styles.text.body.copyWith(color: colors.greyMedium),
        ),
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(36),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(
            horizontal: $styles.insets.sm,
            vertical: $styles.insets.xxs,
          ),
        ),
      ),
    );
  }
}

/// Always-visible "+ Add day" at the bottom of the timeline. Lower-key
/// than the legacy FilledButton — the redesign avoids competing with the
/// "Refine with Buddy" CTA at the top.
class _AddDayButton extends StatelessWidget {
  const _AddDayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.sm,
        $styles.insets.md,
        $styles.insets.md,
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.add_circle_outline, size: 18, color: colors.accent1),
        label: Text(
          $strings.tripDetailAddDay,
          style: $styles.text.bodyBold.copyWith(color: colors.accent1),
        ),
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          backgroundColor: colors.accent1.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    super.key,
    required this.trip,
    required this.day,
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.now,
    required this.prevVisited,
    required this.nextVisited,
    this.onTap,
    this.onLongPress,
    this.dragHandleIndex,
  });

  final Trip trip;
  final TripDay day;
  final TripStop stop;
  final bool isFirst;
  final bool isLast;
  final DateTime now;
  // Whether the neighbor above/below in the flattened stop list is visited.
  // Used to draw the "progress trail" — segment between two visited stops
  // turns solid accent1 instead of dashed greyMedium.
  final bool prevVisited;
  final bool nextVisited;
  // Tap = open edit sheet, long-press = action sheet. Wired only on the
  // card portion (right of the rail) so the rail node's own popover stays
  // independently tappable.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  // Non-null when this row sits inside a `ReorderableListView.builder` —
  // the index drives `ReorderableDragStartListener` so dragging the small
  // right-edge handle lifts the row.
  final int? dragHandleIndex;

  @override
  Widget build(BuildContext context) {
    final status = stopStatusFor(trip: trip, day: day, stop: stop, now: now);
    final visited = status == StopStatus.visited;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RailNode(
              tripId: trip.id,
              dayId: day.id,
              stopId: stop.id,
              status: status,
              isFirst: isFirst,
              isLast: isLast,
              topSegmentSolid: visited && prevVisited,
              bottomSegmentSolid: visited && nextVisited,
            ),
            SizedBox(width: $styles.insets.xs),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: $styles.insets.xs),
                child: _StopCard(
                  trip: trip,
                  day: day,
                  stop: stop,
                  onTap: onTap,
                  onLongPress: onLongPress,
                  dragHandleIndex: dragHandleIndex,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Visual status for a stop's rail node. Mapped from [TripStop.completedAt]
/// (visited) and the schedule + current wall-clock time (current vs upcoming).
/// `untimed` is a separate bucket for trips without a startDate or stops
/// without arrivalTime — they render the same outlined ring as upcoming but
/// the visit-detector also skips them.
enum StopStatus { upcoming, current, visited, untimed }

/// Pure function. ±15 min visual slack on either side of the time window
/// so a stop ending at 12:00 still feels "current" at 12:07. The auto-
/// detector uses a wider 90 min slack — this is purely for visual feel.
StopStatus stopStatusFor({
  required Trip trip,
  required TripDay day,
  required TripStop stop,
  required DateTime now,
}) {
  if (stop.completedAt != null) return StopStatus.visited;
  final start = deriveStopStartDateTime(
    tripStartDate: trip.startDate,
    dayNumber: day.dayNumber,
    arrivalTime: stop.arrivalTime,
  );
  if (start == null) return StopStatus.untimed;
  final end = deriveStopEndDateTime(
    tripStartDate: trip.startDate,
    dayNumber: day.dayNumber,
    endTime: stop.endTime,
  ) ?? start.add(const Duration(hours: 1));
  const slack = Duration(minutes: 15);
  if (now.isBefore(start.subtract(slack))) return StopStatus.upcoming;
  if (now.isAfter(end.add(slack))) return StopStatus.upcoming;
  return StopStatus.current;
}

class _RailNode extends StatelessWidget {
  const _RailNode({
    required this.tripId,
    required this.dayId,
    required this.stopId,
    required this.status,
    required this.isFirst,
    required this.isLast,
    required this.topSegmentSolid,
    required this.bottomSegmentSolid,
  });
  final String tripId;
  final String dayId;
  final String stopId;
  final StopStatus status;
  final bool isFirst;
  final bool isLast;
  final bool topSegmentSolid;
  final bool bottomSegmentSolid;

  void _toggleVisited(BuildContext context) {
    final bloc = context.read<TripsBloc>();
    if (status == StopStatus.visited) {
      bloc.add(StopVisitResetRequested(
        tripId: tripId,
        dayId: dayId,
        stopId: stopId,
      ));
    } else {
      bloc.add(StopVisitMarkRequested(
        tripId: tripId,
        dayId: dayId,
        stopId: stopId,
        visitedAt: DateTime.now().toUtc(),
        source: 'manual',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return SizedBox(
      width: 28,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedRailPainter(
                dashedColor: colors.greyMedium.withValues(alpha: 0.6),
                solidColor: colors.accent1,
                hideTop: isFirst,
                hideBottom: isLast,
                topSegmentSolid: topSegmentSolid,
                bottomSegmentSolid: bottomSegmentSolid,
              ),
            ),
          ),
          Positioned(
            top: 18,
            child: Semantics(
              button: true,
              label: status == StopStatus.visited
                  ? $strings.tripDetailRailResetUpcoming
                  : $strings.tripDetailRailMarkVisited,
              child: GestureDetector(
                onTap: () => _toggleVisited(context),
                behavior: HitTestBehavior.opaque,
                child: switch (status) {
                  StopStatus.visited => _VisitedDot(),
                  StopStatus.current => const _PulseRing(),
                  StopStatus.upcoming => const _OutlinedRing(),
                  StopStatus.untimed => const _OutlinedRing(),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitedDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: colors.accent1,
        border: Border.all(color: colors.accent1, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_rounded, size: 14, color: colors.black),
    );
  }
}

class _OutlinedRing extends StatelessWidget {
  const _OutlinedRing();

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: colors.black,
        border: Border.all(
          color: colors.greyMedium.withValues(alpha: 0.6),
          width: 1.5,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Accent1 ring with a slowly pulsing outer halo. Conveys "this stop is
/// active right now" without competing with the trip-map pulse used on
/// marker taps (which is a one-shot 600ms elastic).
class _PulseRing extends StatefulWidget {
  const _PulseRing();

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        final haloScale = 1.0 + t * 0.6; // 1.0 → 1.6
        final haloAlpha = (1.0 - t) * 0.35; // fade out as it expands
        return SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: haloScale,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colors.accent1.withValues(alpha: haloAlpha),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: colors.black,
                  border: Border.all(color: colors.accent1, width: 2.0),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashedRailPainter extends CustomPainter {
  _DashedRailPainter({
    required this.dashedColor,
    required this.solidColor,
    required this.hideTop,
    required this.hideBottom,
    required this.topSegmentSolid,
    required this.bottomSegmentSolid,
  });
  final Color dashedColor;
  final Color solidColor;
  final bool hideTop;
  final bool hideBottom;
  final bool topSegmentSolid;
  final bool bottomSegmentSolid;

  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()
      ..color = dashedColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final solidPaint = Paint()
      ..color = solidColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    const dashHeight = 4.0;
    const dashGap = 4.0;
    final cx = size.width / 2;
    // Marker spans roughly y=18..36 — leave a small clear zone around it.
    const markerCenter = 27.0;
    const clearHalf = 14.0;
    final topStart = hideTop ? markerCenter + clearHalf : 0.0;
    final topEnd = markerCenter - clearHalf;
    final bottomStart = markerCenter + clearHalf;
    final bottomEnd = hideBottom ? bottomStart : size.height;

    void drawDashed(double from, double to) {
      var y = from;
      while (y < to) {
        final next = (y + dashHeight).clamp(from, to);
        canvas.drawLine(Offset(cx, y), Offset(cx, next), dashedPaint);
        y = next + dashGap;
      }
    }

    void drawSolid(double from, double to) {
      canvas.drawLine(Offset(cx, from), Offset(cx, to), solidPaint);
    }

    if (!hideTop) {
      if (topSegmentSolid) {
        drawSolid(topStart, topEnd);
      } else {
        drawDashed(topStart, topEnd);
      }
    }
    if (bottomSegmentSolid) {
      drawSolid(bottomStart, bottomEnd);
    } else {
      drawDashed(bottomStart, bottomEnd);
    }
  }

  @override
  bool shouldRepaint(_DashedRailPainter old) =>
      old.dashedColor != dashedColor ||
      old.solidColor != solidColor ||
      old.hideTop != hideTop ||
      old.hideBottom != hideBottom ||
      old.topSegmentSolid != topSegmentSolid ||
      old.bottomSegmentSolid != bottomSegmentSolid;
}

class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.trip,
    required this.day,
    required this.stop,
    this.onTap,
    this.onLongPress,
    this.dragHandleIndex,
  });
  final Trip trip;
  final TripDay day;
  final TripStop stop;
  // Tap opens the edit sheet, long-press opens the action sheet. Wired only
  // on the content area (left of the drag handle) so a press on the handle
  // doesn't also trigger these.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  // Non-null when the row is inside a `ReorderableListView.builder` — drives
  // the inline `ReorderableDragStartListener` on the card's right edge.
  // Null during the undo-window static Column path; handle is hidden.
  final int? dragHandleIndex;

  IconData _transportIcon(TransportationKind? kind) {
    switch (kind) {
      case TransportationKind.walk:
        return Icons.directions_walk;
      case TransportationKind.taxi:
        return Icons.local_taxi;
      case TransportationKind.tram:
        return Icons.tram;
      case TransportationKind.bus:
        return Icons.directions_bus;
      case TransportationKind.car:
        return Icons.directions_car;
      case TransportationKind.other:
      case TransportationKind.unknown:
      case null:
        return Icons.commute;
    }
  }

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

  String _transportLabel(TransportationKind? kind) {
    final k = kind == TransportationKind.unknown ? null : kind;
    final raw = (k ?? TransportationKind.walk).name;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  String _formatTimeRange() {
    final a = stop.arrivalTime;
    final e = stop.endTime;
    if (a != null && a.isNotEmpty && e != null && e.isNotEmpty) {
      return '$a – $e';
    }
    if (a != null && a.isNotEmpty) return a;
    return '—';
  }

  String _formatDate() {
    final locale = GetIt.I<LocaleLogic>().strings.localeName;
    if (trip.startDate != null) {
      final d = trip.startDate!.add(Duration(days: day.dayNumber - 1));
      return DateFormat('dd/MMM/yyyy', locale).format(d);
    }
    return $strings.tripDetailDayLabel(day.dayNumber);
  }

  // Returns the secondary location line, or null when the only available value
  // would just repeat the stop name (the geocoder commonly stores name-as-
  // address for landmarks). Suppressing the redundant row keeps the card from
  // showing the same text twice.
  String? _addressLine() {
    final name = stop.name.trim();
    final addr = stop.address?.trim();
    if (addr != null && addr.isNotEmpty && addr != name) {
      return addr;
    }
    final city = stop.city?.trim();
    if (city != null && city.isNotEmpty && city != name) {
      return city;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final hasDragHandle = dragHandleIndex != null;
    // ~32dp reserved on the title's right edge to clear the top-right drag
    // handle overlay (icon 18 + 2× insets.xs ≈ 30, +2 visual breathing room).
    // The padding applies to the whole title — both lines stay clear of the
    // corner, which keeps the wrap visually balanced.
    final titleRightClear = hasDragHandle ? 32.0 : 0.0;
    final addressLine = _addressLine();

    Widget contentRow = Padding(
      padding: EdgeInsets.all($styles.insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StopThumbnail(
            photoUrl: stop.photoUrl,
            fallbackIcon: _kindIcon(stop.kind),
          ),
          SizedBox(width: $styles.insets.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: titleRightClear),
                  child: Text(
                    stop.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        $styles.text.bodyBold.copyWith(color: colors.offWhite),
                  ),
                ),
                SizedBox(height: $styles.insets.xs),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaPill(
                      icon: _transportIcon(stop.transportation),
                      label: _transportLabel(stop.transportation),
                    ),
                    _MetaPill(
                      icon: Icons.schedule,
                      label: _formatTimeRange(),
                    ),
                    _MetaPill(
                      icon: Icons.calendar_today_outlined,
                      label: _formatDate(),
                    ),
                    if (stop.completedAt != null)
                      _MetaPill(
                        icon: Icons.check_circle_rounded,
                        label: $strings.tripDetailVisitedAt(
                          DateFormat.Hm().format(stop.completedAt!.toLocal()),
                        ),
                        iconColor: colors.accent1,
                        labelColor: colors.accent1,
                      ),
                  ],
                ),
                if (addressLine != null) ...[
                  SizedBox(height: $styles.insets.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: colors.greyMedium,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          addressLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: $styles.text.bodySmall.copyWith(
                            color: colors.greyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    Widget tapTarget = contentRow;
    if (onTap != null || onLongPress != null) {
      tapTarget = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        // No visual feedback on tap/long-press — the bottom sheet itself is the
        // acknowledgment. A splash/highlight overlay on the local Material
        // tints the card surface while the sheet sits on top, which reads as
        // an unwanted state change.
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: contentRow,
      );
    }

    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      // Stack so the drag handle floats in the top-right corner instead of
      // claiming a vertical column on the right of every row. The content
      // (thumbnail + text column) gets the full card width; only the title
      // reserves clearance via `titleRightClear` above.
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          tapTarget,
          if (hasDragHandle)
            Positioned(
              top: $styles.insets.xs,
              right: $styles.insets.xs,
              child: ReorderableDragStartListener(
                index: dragHandleIndex!,
                child: Padding(
                  padding: EdgeInsets.all($styles.insets.xs),
                  child: Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: colors.greyMedium.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 80x80 leading thumbnail for a stop card. Renders the server-enriched
/// photo when present, or a kind-based icon fallback. Mirrors the
/// `_PhotoPlaceholder` pattern from `place_card.dart`.
class _StopThumbnail extends StatelessWidget {
  const _StopThumbnail({required this.photoUrl, required this.fallbackIcon});

  final String? photoUrl;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    Widget fallback() => Container(
          width: 80,
          height: 80,
          color: const Color(0xFF222222),
          alignment: Alignment.center,
          child: Icon(
            fallbackIcon,
            size: 32,
            color: colors.greyMedium,
          ),
        );

    if (photoUrl == null || photoUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular($styles.corners.md),
        child: fallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular($styles.corners.md),
      child: CachedNetworkImage(
        imageUrl: photoUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback(),
        errorWidget: (_, _, _) => fallback(),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
  });
  final IconData icon;
  final String label;
  // Override when the pill should pop (e.g. the "Visited" pill uses accent1
  // for both, sharing the same color family as the rail-node check icon).
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor ?? colors.accent1),
        const SizedBox(width: 4),
        Text(
          label,
          style: $styles.text.bodySmall.copyWith(
            color: labelColor ?? colors.offWhite,
          ),
        ),
      ],
    );
  }
}

/// "Refine with Buddy" entry point. Sits between TripErrorBanner and the
/// timeline, hidden during edit mode (edit and refine are exclusive primary
/// actions on this screen). On tap, hands off to BuddyBloc which loads the
/// trip's 1:1 refine conversation, hydrates history, and asks AppShell to
/// switch to the Buddy tab.
class _RefineCta extends StatelessWidget {
  const _RefineCta({required this.busy, required this.onTap});
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.md,
        vertical: $styles.insets.xs,
      ),
      child: TextButton.icon(
        icon: busy
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accent1,
                ),
              )
            : Icon(Icons.auto_awesome, color: colors.accent1, size: 18),
        label: Text(
          $strings.refineWithBuddyButton,
          style: $styles.text.body.copyWith(color: colors.offWhite),
        ),
        onPressed: busy ? null : onTap,
        style: TextButton.styleFrom(
          foregroundColor: colors.offWhite,
          backgroundColor: colors.accent1.withValues(alpha: .12),
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// One-time opt-in sheet shown on first open of a trip whose calendar
/// window contains today. Resolves to:
///   `true`  → user tapped Enable (caller still has to confirm the OS
///             permission prompt before auto-tracking actually starts),
///   `false` → user tapped "Not now" (persisted; suppresses re-prompt),
///   `null`  → dismissed via backdrop / system back. Treated as "ask
///             again next session" — no decision persisted.

/// Action returned by the stop long-press bottom sheet. Routed by
/// `_showStopActions` to the matching handler. `edit` is intentionally
/// absent for now — the Edit-stop sheet was removed at the user's
/// request, and re-adding it should restore the enum case + the route.
enum _StopAction { move, duplicate, delete }

/// Action returned by the day-header overflow bottom sheet. Routed by
/// `_showDayActions` to the matching handler. `addStop` is intentionally
/// absent for now — the Edit-stop sheet (which `_addStop` opens) was
/// removed at the user's request.
enum _DayAction { rename, baseCity, delete }

class _AutoTrackConsentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          $styles.insets.lg,
          $styles.insets.lg,
          $styles.insets.lg,
          $styles.insets.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 22, color: colors.accent1),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: Text(
                    $strings.tripDetailAutoTrackPromptTitle,
                    style: $styles.text.bodyBold
                        .copyWith(color: colors.offWhite),
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.sm),
            Text(
              $strings.tripDetailAutoTrackPromptBody,
              style: $styles.text.body.copyWith(color: colors.greyMedium),
            ),
            SizedBox(height: $styles.insets.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.offWhite,
                      side: BorderSide(
                          color: colors.greyMedium.withValues(alpha: 0.5)),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text($strings.tripDetailAutoTrackDecline),
                  ),
                ),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent1,
                      foregroundColor: colors.greyStrong,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text($strings.tripDetailAutoTrackEnable),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet shown when "Enable visit auto-tracking" can't actually
/// activate — permission denied, denied-forever, or device-wide Location
/// Services off. Replaces the prior silent fallthrough; per the design
/// rule of no SnackBars, feedback is a modal that owns the user's
/// attention until they pick "Not now" or the status-specific CTA.
/// `onPrimary` runs after the sheet pops so async side effects (Settings
/// deep-link, retry toggle) execute against the still-mounted screen.
class _AutoTrackErrorSheet extends StatelessWidget {
  const _AutoTrackErrorSheet({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
  });
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          $styles.insets.lg,
          $styles.insets.lg,
          $styles.insets.lg,
          $styles.insets.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_off_outlined,
                    size: 22, color: colors.accent1),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: Text(
                    title,
                    style: $styles.text.bodyBold
                        .copyWith(color: colors.offWhite),
                  ),
                ),
              ],
            ),
            SizedBox(height: $styles.insets.sm),
            Text(
              body,
              style: $styles.text.body.copyWith(color: colors.greyMedium),
            ),
            SizedBox(height: $styles.insets.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.offWhite,
                      side: BorderSide(
                          color: colors.greyMedium.withValues(alpha: 0.5)),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text($strings.tripDetailAutoTrackDecline),
                  ),
                ),
                SizedBox(width: $styles.insets.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPrimary();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent1,
                      foregroundColor: colors.greyStrong,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(primaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

