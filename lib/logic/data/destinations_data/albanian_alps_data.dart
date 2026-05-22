import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class AlbanianAlpsData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Albanian Alps values.
  AlbanianAlpsData()
    : super(
        type: DestinationType.albanianAlps,
        title: $strings.albanianAlpsTitle,
        subTitle: $strings.albanianAlpsSubTitle,
        regionTitle: $strings.albanianAlpsRegionTitle,
        videoId: 'lJKX3Y7Vqvs',
        startYr: -2600,
        endYr: -2500,
        artifactStartYr: -2800,
        artifactEndYr: -2300,
        artifactCulture: $strings.albanianAlpsArtifactCulture,
        artifactGeolocation: $strings.albanianAlpsArtifactGeolocation,
        lat: 42.4552,
        lng: 19.8030,
        pullQuote1Top: $strings.albanianAlpsPullQuote1Top,
        pullQuote1Bottom: $strings.albanianAlpsPullQuote1Bottom,
        pullQuote1Author: '',
        pullQuote2: $strings.albanianAlpsPullQuote2,
        pullQuote2Author: $strings.albanianAlpsPullQuote2Author,
        callout1: $strings.albanianAlpsCallout1,
        callout2: $strings.albanianAlpsCallout2,
        videoCaption: $strings.albanianAlpsVideoCaption,
        mapCaption: $strings.albanianAlpsMapCaption,
        historyInfo1: $strings.albanianAlpsHistoryInfo1,
        historyInfo2: $strings.albanianAlpsHistoryInfo2,
        constructionInfo1: $strings.albanianAlpsConstructionInfo1,
        constructionInfo2: $strings.albanianAlpsConstructionInfo2,
        locationInfo1: $strings.albanianAlpsLocationInfo1,
        locationInfo2: $strings.albanianAlpsLocationInfo2,
        events: {
          -2575: $strings.albanianAlps2575bce,
          -2465: $strings.albanianAlps2465bce,
          -443: $strings.albanianAlps443bce,
          1925: $strings.albanianAlps1925ce,
          1979: $strings.albanianAlps1979ce,
          1990: $strings.albanianAlps1990ce,
        },
      );
}
