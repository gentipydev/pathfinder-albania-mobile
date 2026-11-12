import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';

class ApolloniaData extends DestinationData {
  ApolloniaData()
    : super(
        type: DestinationType.apollonia,
        title: $strings.apolloniaTitle,
        regionTitle: $strings.apolloniaRegionTitle,
        videoId: 't1gj4M0J2BU',
        startYr: -588,
        endYr: 400,
        artifactCulture: $strings.apolloniaArtifactCulture,
        lat: 40.7210,
        lng: 19.4712,
        pullQuote1Top: $strings.apolloniaPullQuote1Top,
        pullQuote1Bottom: $strings.apolloniaPullQuote1Bottom,
        pullQuote1Author: '',
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
          -588: $strings.apollonia588bce,
          -229: $strings.apollonia229bce,
          -148: $strings.apollonia148bce,
          -44: $strings.apollonia44bce,
          1272: $strings.apollonia1272ce,
          1924: $strings.apollonia1924ce,
        },
      );
}
