import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class ButrintData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Butrint values.
  ButrintData()
    : super(
        type: DestinationType.butrint,
        title: $strings.butrintTitle,
        subTitle: $strings.butrintSubTitle,
        regionTitle: $strings.butrintRegionTitle,
        videoId: 'Q6eBJjdca14',
        startYr: 550,
        endYr: 1550,
        artifactStartYr: 500,
        artifactEndYr: 1600,
        artifactCulture: $strings.butrintArtifactCulture,
        artifactGeolocation: $strings.butrintArtifactGeolocation,
        lat: 39.7440,
        lng: 20.0195,
        pullQuote1Top: $strings.butrintPullQuote1Top,
        pullQuote1Bottom: $strings.butrintPullQuote1Bottom,
        pullQuote1Author: '',
        pullQuote2: $strings.butrintPullQuote2,
        pullQuote2Author: $strings.butrintPullQuote2Author,
        callout1: $strings.butrintCallout1,
        callout2: $strings.butrintCallout2,
        videoCaption: $strings.butrintVideoCaption,
        mapCaption: $strings.butrintMapCaption,
        historyInfo1: $strings.butrintHistoryInfo1,
        historyInfo2: $strings.butrintHistoryInfo2,
        constructionInfo1: $strings.butrintConstructionInfo1,
        constructionInfo2: $strings.butrintConstructionInfo2,
        locationInfo1: $strings.butrintLocationInfo1,
        locationInfo2: $strings.butrintLocationInfo2,
        events: {
          600: $strings.butrint600ce,
          832: $strings.butrint832ce,
          998: $strings.butrint998ce,
          1100: $strings.butrint1100ce,
          1527: $strings.butrint1527ce,
          1535: $strings.butrint1535ce,
        },
      );
}
