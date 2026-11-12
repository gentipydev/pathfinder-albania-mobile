import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';

class ThethData extends DestinationData {
  ThethData()
    : super(
        type: DestinationType.theth,
        title: $strings.thethTitle,
        regionTitle: $strings.thethRegionTitle,
        videoId: 'Ob1A95pc-H8',
        startYr: 1670,
        artifactCulture: $strings.thethArtifactCulture,
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
          1892: $strings.theth1892ce,
          1908: $strings.theth1908ce,
          1966: $strings.theth1966ce,
          2011: $strings.theth2011ce,
          2017: $strings.theth2017ce,
          2022: $strings.theth2022ce,
        },
      );
}
