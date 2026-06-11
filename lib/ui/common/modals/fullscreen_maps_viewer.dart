import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';
import 'package:travel_buddy/ui/common/controls/app_header.dart';
import 'package:travel_buddy/ui/common/google_maps_marker.dart';

class FullscreenMapsViewer extends StatelessWidget {
  FullscreenMapsViewer({super.key, required this.type});
  final DestinationType type;

  DestinationData get data => destinationsLogic.getData(type);
  late final startPos = CameraPosition(target: LatLng(data.lat, data.lng), zoom: 17);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          top: false,
          child: GoogleMap(
            mapType: MapType.hybrid,
            markers: {getMapsMarker(startPos.target)},
            initialCameraPosition: startPos,
            myLocationButtonEnabled: false,
          ),
        ),
        // Keeps the back button tappable on web — without it the tap falls
        // through to the GoogleMap platform view. No-op on mobile.
        PointerInterceptor(child: AppHeader(isTransparent: true)),
      ],
    );
  }
}
