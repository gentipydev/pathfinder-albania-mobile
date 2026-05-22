import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class BeratData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Berat values.
  BeratData()
    : super(
        type: DestinationType.berat,
        title: $strings.beratTitle,
        subTitle: $strings.beratSubTitle,
        regionTitle: $strings.beratRegionTitle,
        videoId: 'k_615AauSds',
        startYr: 1922,
        endYr: 1931,
        artifactStartYr: 1600,
        artifactEndYr: 2100,
        artifactCulture: '',
        artifactGeolocation: $strings.beratArtifactGeolocation,
        lat: 40.7053,
        lng: 19.9519,
        pullQuote1Top: $strings.beratPullQuote1Top,
        pullQuote1Bottom: $strings.beratPullQuote1Bottom,
        pullQuote1Author: '',
        pullQuote2: $strings.beratPullQuote2,
        pullQuote2Author: $strings.beratPullQuote2Author,
        callout1: $strings.beratCallout1,
        callout2: $strings.beratCallout2,
        videoCaption: $strings.beratVideoCaption,
        mapCaption: $strings.beratMapCaption,
        historyInfo1: $strings.beratHistoryInfo1,
        historyInfo2: $strings.beratHistoryInfo2,
        constructionInfo1: $strings.beratConstructionInfo1,
        constructionInfo2: $strings.beratConstructionInfo2,
        locationInfo1: $strings.beratLocationInfo1,
        locationInfo2: $strings.beratLocationInfo2,
        events: {
          1850: $strings.berat1850ce,
          1921: $strings.berat1921ce,
          1922: $strings.berat1922ce,
          1926: $strings.berat1926ce,
          1931: $strings.berat1931ce,
          2006: $strings.berat2006ce,
        },
      );
}
