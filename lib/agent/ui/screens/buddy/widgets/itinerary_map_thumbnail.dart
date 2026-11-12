import 'package:cached_network_image/cached_network_image.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/agent/domain/entities/trip.dart';

/// Inline 16:9 static-map preview rendered in an assistant chat bubble after
/// a streamed itinerary has been saved as a Trip. The image URL is a Mapbox
/// Static Images PNG composed server-side; this widget is purely visual and
/// holds no map SDK state.
///
/// Wrapped in a [Hero] whose tag (`'itinerary_map_<tripId>'`) matches the
/// full-screen map on TripMapScreen, so a tap morphs the bubble into the
/// interactive map.
///
/// NOTE: the two ends of that Hero flight still don't match exactly. Static
/// Images renders classic styles only, so the backend uses `light-v11`
/// (`mapbox_static.py`) while TripMapScreen uses Mapbox Standard — which is
/// GL-only and unavailable to the static endpoint. Both are Mapbox now; the
/// residual difference is a style difference, not a provider one. Don't
/// restyle one side alone. See docs/maps-setup.md.
///
/// On top of the static image:
///   - The image fades + scales in once it decodes.
///   - A soft shine band sweeps left-to-right every ~6 s as a subtle "tap me".
///   - The corner expand-hint icon breathes gently for the same purpose.
class ItineraryMapThumbnail extends StatelessWidget {
  const ItineraryMapThumbnail({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = trip.staticMapUrl;
    if (url == null || url.isEmpty) {
      // No map data — render nothing (chat bubble looks like pre-PR-2).
      return const SizedBox.shrink();
    }

    return Hero(
      tag: 'itinerary_map_${trip.id}',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const _ShimmerPlaceholder(),
                  errorWidget: (_, _, _) => const _MapUnavailable(),
                )
                    .animate()
                    .fadeIn(duration: $styles.times.fast)
                    .scale(
                      begin: const Offset(0.97, 0.97),
                      curve: Curves.easeOutCubic,
                      duration: $styles.times.med,
                    ),
                const Positioned.fill(
                  child: IgnorePointer(child: _ShineSweep()),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: const _ExpandHint()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.08, 1.08),
                        duration: $styles.times.med,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft pulsing placeholder while the static map PNG decodes. Pulses between
/// two dark tones around the elevated surface ($styles.colors.surface) so the
/// chat bubble reads as a unified surface during load.
class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder();

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        return Container(
          color: Color.lerp(
            const Color(0xFF1A1A1A),
            const Color(0xFF2A2A2A),
            t,
          ),
        );
      },
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: $styles.colors.surface,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 36,
            color: $styles.colors.greyMedium,
          ),
          Gap($styles.insets.xxs),
          Text(
            'Map unavailable',
            style: $styles.text.bodySmall.copyWith(
              color: $styles.colors.greyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandHint extends StatelessWidget {
  const _ExpandHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: $styles.colors.black.withValues(alpha: .6),
        borderRadius: BorderRadius.circular($styles.corners.pill),
      ),
      child: const Icon(
        Icons.open_in_full,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

/// Decorative shine band that sweeps across the thumbnail every ~6 s as a
/// subtle "tap me" cue. Built from a single [AnimationController] driving a
/// [LinearGradient]'s alignment — when the band slides past the right edge
/// it remains parked off-screen (transparent on both ends) for the rest of
/// the cycle, producing a natural pause without a second timer.
class _ShineSweep extends StatefulWidget {
  const _ShineSweep();

  @override
  State<_ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<_ShineSweep>
    with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(milliseconds: 6000);
  // Fraction of the cycle spent actually sweeping. The remaining ~77% is
  // the off-screen pause — keeps the effect from feeling busy.
  static const double _sweepFraction = 0.23;

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _cycle)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final raw = _ctrl.value;
        // Clamp to the sweep window; past it the band sits at +1 (off-right).
        final progress = (raw / _sweepFraction).clamp(0.0, 1.0);
        // Slide the gradient from just-off-left (-1.5) to just-off-right (+1.5).
        final shift = -1.5 + progress * 3.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(shift - 0.6, -0.3),
              end: Alignment(shift + 0.6, 0.3),
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        );
      },
    );
  }
}
