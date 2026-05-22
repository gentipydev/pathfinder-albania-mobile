import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class ThethData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Theth values.
  ThethData()
    : super(
        type: DestinationType.theth,
        title: $strings.thethTitle,
        subTitle: $strings.thethSubTitle,
        regionTitle: $strings.thethRegionTitle,
        videoId: 'cnMa-Sm9H4k',
        startYr: 1450,
        endYr: 1572,
        artifactStartYr: 1200,
        artifactEndYr: 1700,
        artifactCulture: $strings.thethArtifactCulture,
        artifactGeolocation: $strings.thethArtifactGeolocation,
        lat: 42.4046,
        lng: 19.7681,
        pullQuote1Top: $strings.thethPullQuote1Top,
        pullQuote1Bottom: $strings.thethPullQuote1Bottom,
        pullQuote1Author: $strings.thethPullQuote1Author,
        pullQuote2: $strings.thethPullQuote2,
        pullQuote2Author: $strings.thethPullQuote2Author,
        callout1: $strings.thethCallout1,
        callout2: $strings.thethCallout2,
        videoCaption: $strings.thethVideoCaption,
        mapCaption: $strings.thethMapCaption,
        historyInfo1: $strings.thethHistoryInfo1,
        historyInfo2: $strings.thethHistoryInfo2,
        constructionInfo1: $strings.thethConstructionInfo1,
        constructionInfo2: $strings.thethConstructionInfo2,
        locationInfo1: $strings.thethLocationInfo1,
        locationInfo2: $strings.thethLocationInfo2,
        events: {
          1438: $strings.theth1438ce,
          1572: $strings.theth1572ce,
          1867: $strings.theth1867ce,
          1911: $strings.theth1911ce,
          1964: $strings.theth1964ce,
          1997: $strings.theth1997ce,
        },
      );
}
