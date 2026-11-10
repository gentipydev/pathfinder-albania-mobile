import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
// `hide Size`: Mapbox exports its own Size, which shadows dart:ui's
// everywhere Flutter widgets need it.
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
// `hide Point`: common_libs re-exports dart:math, whose Point collides with
// the GeoJSON Point that Mapbox geometries are built from.
import 'package:travel_buddy/common_libs.dart' hide Point;
import 'package:travel_buddy/logic/common/platform_info.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';
import 'package:travel_buddy/styles/map_style.dart';
import 'package:travel_buddy/ui/common/controls/app_header.dart';
import 'package:travel_buddy/ui/common/map_marker.dart';

/// Full-screen satellite map centred on a single destination, with one pin.
///
/// Stateful because Mapbox annotations are imperative: the pin can only be
/// created once the style has loaded, so there is nothing to declare in
/// [build] the way a declarative `markers: {...}` property would allow.
class FullscreenMapsViewer extends StatefulWidget {
  const FullscreenMapsViewer({super.key, required this.type});
  final DestinationType type;

  @override
  State<FullscreenMapsViewer> createState() => _FullscreenMapsViewerState();
}

class _FullscreenMapsViewerState extends State<FullscreenMapsViewer> {
  MapboxMap? _map;
  bool _pinInstalled = false;

  late final DestinationData _data = destinationsLogic.getData(widget.type);
  late final Position _position = Position(_data.lng, _data.lat);

  /// Built once: MapWidget re-runs a viewport transition whenever this value
  /// differs from the previous build's.
  late final ViewportState _viewport = CameraViewportState(
    center: Point(coordinates: _position),
    zoom: 17,
  );

  Future<void> _installPin() async {
    final map = _map;
    if (map == null || !mounted || _pinInstalled) return;
    _pinInstalled = true;
    final manager = await map.annotations.createPointAnnotationManager();
    if (!mounted) return;
    await manager.create(buildPinAnnotationOptions(_position));
  }

  @override
  Widget build(BuildContext context) {
    // Mapbox ships iOS and Android only — render just the header so the back
    // button still works instead of throwing on the platform view.
    if (kIsWeb || PlatformInfo.isDesktop) {
      return ColoredBox(
        color: $styles.colors.black,
        child: Stack(
          children: [const SizedBox.expand(), AppHeader(isTransparent: true)],
        ),
      );
    }

    return Stack(
      children: [
        SafeArea(
          top: false,
          child: MapWidget(
            key: const ValueKey('destination_map'),
            styleUri: kMapboxSatelliteStyle,
            viewport: _viewport,
            onMapCreated: (map) {
              _map = map;
              unawaited(
                map.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
              );
            },
            // Annotations can only be created against a loaded style.
            onStyleLoadedListener: (_) => unawaited(_installPin()),
          ),
        ),
        AppHeader(isTransparent: true),
      ],
    );
  }
}
