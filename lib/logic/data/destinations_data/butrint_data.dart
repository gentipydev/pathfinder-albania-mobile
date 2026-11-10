import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class ButrintData extends DestinationData {
  ButrintData()
    : super(
        type: DestinationType.butrint,
        title: $strings.butrintTitle,
        regionTitle: $strings.butrintRegionTitle,
        videoId: 'EMj-etBT7CU',
        startYr: -800,
        endYr: 1572,
        artifactCulture: $strings.butrintArtifactCulture,
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
          -228: $strings.butrint228bce,
          -44: $strings.butrint44bce,
          1386: $strings.butrint1386ce,
          1798: $strings.butrint1798ce,
          1928: $strings.butrint1928ce,
          1992: $strings.butrint1992ce,
        },
      );
}
