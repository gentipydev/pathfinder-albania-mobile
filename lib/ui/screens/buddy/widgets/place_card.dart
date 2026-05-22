import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_buddy/logic/buddy/place_card.dart';

const Color _kOrange = Color(0xFFE07B39);
const Color _kCardBg = Color(0xFF1A1A1A);
const Color _kChipBg = Color(0xFF2A2A2A);
const Color _kGreySubtitle = Color(0xFF888888);
const Color _kGreyBody = Color(0xFFCCCCCC);

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
    Uri uri;
    final placeId = p.googlePlaceId;
    if (placeId != null && placeId.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeComponent(p.name)}'
        '&query_place_id=$placeId',
      );
    } else if (p.lat != null && p.lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${p.lat},${p.lng}',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeComponent(p.name)}',
      );
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final cardW = mq.size.width - 32;
    final cardH = math.min(mq.size.height * 0.62, 480.0);
    final photoH = cardH * 0.55;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: cardW,
        height: cardH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColoredBox(
            color: _kCardBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: photoH,
                  child: _buildPhotoCarousel(cardW, photoH),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
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
            style: const TextStyle(color: _kGreySubtitle, fontSize: 13),
          ),
        if (desc != null && desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              color: _kGreyBody,
              fontSize: 13,
              height: 1.35,
            ),
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
        icon: const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: _kGreySubtitle,
        ),
        label: const Text(
          'Open in maps',
          style: TextStyle(
            color: _kGreySubtitle,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          iconColor: _kGreySubtitle,
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
      borderRadius: BorderRadius.circular(18),
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
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
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
      color: const Color(0xFF222222),
      alignment: Alignment.center,
      child: const Icon(
        Icons.place_outlined,
        size: 48,
        color: Color(0xFF666666),
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
        color: _kChipBg,
        border: Border.all(color: _kOrange, width: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontStyle: FontStyle.italic,
          height: 1.3,
        ),
      ),
    );
  }
}
