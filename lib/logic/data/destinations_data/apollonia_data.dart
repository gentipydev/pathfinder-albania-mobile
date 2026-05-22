import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class ApolloniaData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Apollonia values.
  ApolloniaData()
    : super(
        type: DestinationType.apollonia,
        title: $strings.apolloniaTitle,
        subTitle: $strings.apolloniaSubTitle,
        regionTitle: $strings.apolloniaRegionTitle,
        videoId: 't1gj4M0J2BU',
        startYr: -700,
        endYr: 1644,
        artifactStartYr: -700,
        artifactEndYr: 1650,
        artifactCulture: $strings.apolloniaArtifactCulture,
        artifactGeolocation: $strings.apolloniaArtifactGeolocation,
        lat: 40.7210,
        lng: 19.4712,
        pullQuote1Top: $strings.apolloniaPullQuote1Top,
        pullQuote1Bottom: $strings.apolloniaPullQuote1Bottom,
        pullQuote1Author: '', //No key because it doesn't generate for empty values
        pullQuote2: $strings.apolloniaPullQuote2,
        pullQuote2Author: $strings.apolloniaPullQuote2Author,
        callout1: $strings.apolloniaCallout1,
        callout2: $strings.apolloniaCallout2,
        videoCaption: $strings.apolloniaVideoCaption,
        mapCaption: $strings.apolloniaMapCaption,
        historyInfo1: $strings.apolloniaHistoryInfo1,
        historyInfo2: $strings.apolloniaHistoryInfo2,
        constructionInfo1: $strings.apolloniaConstructionInfo1,
        constructionInfo2: $strings.apolloniaConstructionInfo2,
        locationInfo1: $strings.apolloniaLocationInfo1,
        locationInfo2: $strings.apolloniaLocationInfo2,
        events: {
          -700: $strings.apollonia700bce,
          -214: $strings.apollonia214bce,
          -121: $strings.apollonia121bce,
          556: $strings.apollonia556ce,
          618: $strings.apollonia618ce,
          1487: $strings.apollonia1487ce,
        },
      );
}
