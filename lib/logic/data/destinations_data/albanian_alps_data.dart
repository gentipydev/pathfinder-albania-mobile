import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class AlbanianAlpsData extends DestinationData {
  AlbanianAlpsData()
    : super(
        type: DestinationType.albanianAlps,
        title: $strings.albanianAlpsTitle,
        regionTitle: $strings.albanianAlpsRegionTitle,
        videoId: 'ino-e2NHikE',
        startYr: 1400,
        artifactCulture: $strings.albanianAlpsArtifactCulture,
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
          1909: $strings.albanianAlps1909ce,
          1929: $strings.albanianAlps1929ce,
          1996: $strings.albanianAlps1996ce,
          2009: $strings.albanianAlps2009ce,
          2011: $strings.albanianAlps2011ce,
          2022: $strings.albanianAlps2022ce,
        },
      );
}
