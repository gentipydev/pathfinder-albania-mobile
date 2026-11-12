import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/agent/logic/buddy/place_card.dart';
import 'package:pathfinder_albania/agent/utils/open_in_maps.dart';

class PlaceCardWidget extends StatefulWidget {
  const PlaceCardWidget({super.key, required this.place});

  final PlaceCard place;

  @override
  State<PlaceCardWidget> createState() => _PlaceCardWidgetState();
}

class _PlaceCardWidgetState extends State<PlaceCardWidget> {
  late List<String> _photos;
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _photos = widget.place.effectivePhotos;
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant PlaceCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.place != oldWidget.place) {
      setState(() {
        _photos = widget.place.effectivePhotos;
        _currentIndex = 0;
      });
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleOpenMap() async {
    final p = widget.place;
    await openInMaps(name: p.name, lat: p.lat, lng: p.lng);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // The chat column is capped at maxContentWidth2 on wide web/desktop
    // windows, so derive the carousel math from that cap, not the screen.
    final cardW = math.min(mq.size.width, $styles.sizes.maxContentWidth2) - 32;
    final cardH = math.min(mq.size.height * 0.62, 480.0);
    final photoH = cardH * 0.55;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm, vertical: $styles.insets.xs),
      child: SizedBox(
        width: cardW,
        height: cardH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular($styles.corners.card),
          child: ColoredBox(
            color: $styles.colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: photoH,
                  child: _buildPhotoCarousel(cardW, photoH),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all($styles.insets.sm),
                    child: _buildDetails(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Photo carousel ----

  Widget _buildPhotoCarousel(double cardW, double photoH) {
    if (_photos.isEmpty) {
      return _PhotoPlaceholder(width: cardW, height: photoH);
    }
    if (_photos.length == 1) {
      return _PhotoTile(url: _photos.first);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _photos.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (_, i) => _PhotoTile(url: _photos[i]),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _CounterPill(
            text: '${_currentIndex + 1} / ${_photos.length}',
          ),
        ),
      ],
    );
  }

  // ---- Details ----

  Widget _buildDetails() {
    final p = widget.place;
    final subtitle = p.subtitle;
    final desc = p.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null && subtitle.isNotEmpty)
          Text(
            subtitle,
            style: $styles.text.bodySmall.copyWith(color: $styles.colors.caption),
          ),
        if (desc != null && desc.isNotEmpty) ...[
          SizedBox(height: $styles.insets.xs),
          Text(
            desc,
            style: $styles.text.bodySmall.copyWith(color: $styles.colors.greyMedium),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (p.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildTagRow(p.tags),
        ],
        const Spacer(),
        _buildActionRow(),
      ],
    );
  }

  Widget _buildTagRow(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: [for (final t in tags) _TagChip(label: t)],
    );
  }

  Widget _buildActionRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _handleOpenMap,
        icon: Icon(
          Icons.location_on_outlined,
          size: 16,
          color: $styles.colors.caption,
        ),
        label: Text(
          $strings.placeCardOpenInMaps,
          style: $styles.text.bodySmall.copyWith(color: $styles.colors.caption),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          iconColor: $styles.colors.caption,
        ),
      ),
    );
  }
}

// ---- Sub-widgets ----

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular($styles.corners.card),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        placeholder: (_, _) => const _PhotoPlaceholder(),
        errorWidget: (_, _, _) => const _PhotoPlaceholder(),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: $styles.colors.black.withValues(alpha: .6),
        borderRadius: BorderRadius.circular($styles.corners.pill),
      ),
      child: Text(
        text,
        style: $styles.text.bodySmall.copyWith(
          color: $styles.colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: $styles.colors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.place_outlined,
        size: 48,
        color: $styles.colors.caption,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: $styles.colors.greyStrong,
        border: Border.all(color: $styles.colors.accent1, width: 0.5),
        borderRadius: BorderRadius.circular($styles.corners.card),
      ),
      child: Text(
        label,
        style: $styles.text.caption.copyWith(color: $styles.colors.white),
      ),
    );
  }
}
