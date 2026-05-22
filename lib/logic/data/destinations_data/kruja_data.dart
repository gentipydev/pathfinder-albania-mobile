import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class KrujaData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Kruja values.
  KrujaData()
    : super(
        type: DestinationType.kruja,
        title: $strings.krujaTitle,
        subTitle: $strings.krujaSubTitle,
        regionTitle: $strings.krujaRegionTitle,
        videoId: 'ezDiSkOU0wc',
        startYr: -312,
        endYr: 100,
        artifactStartYr: -500,
        artifactEndYr: 500,
        artifactCulture: $strings.krujaArtifactCulture,
        artifactGeolocation: $strings.krujaArtifactGeolocation,
        lat: 41.5147,
        lng: 19.7884,
        pullQuote1Top: $strings.krujaPullQuote1Top,
        pullQuote1Bottom: $strings.krujaPullQuote1Bottom,
        pullQuote1Author: $strings.krujaPullQuote1Author,
        pullQuote2: $strings.krujaPullQuote2,
        pullQuote2Author: $strings.krujaPullQuote2Author,
        callout1: $strings.krujaCallout1,
        callout2: $strings.krujaCallout2,
        videoCaption: $strings.krujaVideoCaption,
        mapCaption: $strings.krujaMapCaption,
        historyInfo1: $strings.krujaHistoryInfo1,
        historyInfo2: $strings.krujaHistoryInfo2,
        constructionInfo1: $strings.krujaConstructionInfo1,
        constructionInfo2: $strings.krujaConstructionInfo2,
        locationInfo1: $strings.krujaLocationInfo1,
        locationInfo2: $strings.krujaLocationInfo2,
        events: {
          -1200: $strings.kruja1200bce,
          -106: $strings.kruja106bce,
          551: $strings.kruja551ce,
          1812: $strings.kruja1812ce,
          1958: $strings.kruja1958ce,
          1989: $strings.kruja1989ce,
        },
      );
}
