import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a place in the device's own maps app.
///
/// Platform-native rather than a single web URL so the link lands in Maps on
/// iOS and whatever the user has set as their maps handler on Android, instead
/// of bouncing through a browser.
///
/// Coordinates win when we have them — a name alone is ambiguous, and every
/// caller here already has a geocoded stop. The name still rides along as the
/// query label so the pin is captioned.
///
/// Best-effort: an unlaunchable URI (no maps app, restricted profile) falls
/// through to the web fallback, and a failure there is swallowed. Opening a
/// map is never worth interrupting the user with an error.
Future<void> openInMaps({
  required String name,
  double? lat,
  double? lng,
}) async {
  final query = Uri.encodeComponent(name);
  final hasCoords = lat != null && lng != null;

  // `geo:` is the Android convention and lets the user pick their handler.
  // Apple's maps.apple.com scheme opens the Maps app directly on iOS (and
  // degrades to the web map everywhere else), so it doubles as the fallback.
  final candidates = <Uri>[
    if (!kIsWeb && Platform.isAndroid && hasCoords)
      Uri.parse('geo:$lat,$lng?q=$lat,$lng($query)'),
    if (!kIsWeb && Platform.isAndroid && !hasCoords)
      Uri.parse('geo:0,0?q=$query'),
    if (hasCoords)
      Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$query')
    else
      Uri.parse('https://maps.apple.com/?q=$query'),
  ];

  for (final uri in candidates) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Try the next candidate.
    }
  }
}
