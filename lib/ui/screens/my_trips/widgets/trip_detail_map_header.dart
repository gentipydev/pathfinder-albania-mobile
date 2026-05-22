import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/domain/entities/trip.dart';
import 'package:travel_buddy/ui/screens/buddy/widgets/itinerary_map_thumbnail.dart';
import 'package:travel_buddy/ui/screens/trip_map/trip_map_screen.dart';

/// Pinned section above the trip-detail timeline that opens [TripMapScreen]
/// for the saved trip. Reuses the chat-bubble's [ItineraryMapThumbnail] so
/// the Hero morph (tag `'itinerary_map_<tripId>'`) lands identically to the
/// post-save flow. When the trip has no `staticMapUrl` (legacy / enrichment
/// failure) we fall back to a small pill button — tap still opens the full
/// map, just without the morph.
///
/// Callers should pass the latest `trip` snapshot (parent reads from
/// `TripsBloc.state.trips` via a `BlocSelector`). On tap, `Navigator.push`
/// captures whatever `trip` value is in scope at tap time — i.e., the
/// post-edit, re-enriched trip the server returned from the last mutation.
class TripDetailMapHeader extends StatelessWidget {
  const TripDetailMapHeader({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final hasStatic =
        trip.staticMapUrl != null && trip.staticMapUrl!.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        $styles.insets.md,
        $styles.insets.sm,
        $styles.insets.md,
        0,
      ),
      child: hasStatic
          ? ItineraryMapThumbnail(
              trip: trip,
              onTap: () => _openMap(context, trip),
            )
          : _OpenMapFallbackButton(onTap: () => _openMap(context, trip)),
    );
  }

  static void _openMap(BuildContext context, Trip trip) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: $styles.times.med,
        reverseTransitionDuration: $styles.times.med,
        pageBuilder: (_, _, _) => TripMapScreen(trip: trip),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

/// No-thumbnail fallback for trips whose `static_map_url` enrichment never
/// landed. Sized to roughly match the thumbnail's visual weight so the
/// layout stays balanced when a few trips in the list have it and others
/// don't.
class _OpenMapFallbackButton extends StatelessWidget {
  const _OpenMapFallbackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    return Material(
      color: colors.greyStrong,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: $styles.insets.md,
            vertical: $styles.insets.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 20, color: colors.accent1),
              Gap($styles.insets.sm),
              Expanded(
                child: Text(
                  $strings.tripDetailViewOnMapButton,
                  style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
                ),
              ),
              Icon(
                Icons.open_in_full,
                size: 16,
                color: colors.greyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
