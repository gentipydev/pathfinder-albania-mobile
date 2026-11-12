import 'package:pathfinder_albania/common_libs.dart';
import 'package:pathfinder_albania/logic/data/destination_data.dart';

class KorcaData extends DestinationData {
  KorcaData()
    : super(
        type: DestinationType.korca,
        title: $strings.korcaTitle,
        regionTitle: $strings.korcaRegionTitle,
        videoId: 'kEwM3D2At64',
        startYr: 1484,
        artifactCulture: $strings.korcaArtifactCulture,
        lat: 40.6161,
        lng: 20.7802,
        pullQuote1Top: $strings.korcaPullQuote1Top,
        pullQuote1Bottom: $strings.korcaPullQuote1Bottom,
        pullQuote1Author: $strings.korcaPullQuote1Author,
        pullQuote2: $strings.korcaPullQuote2,
        pullQuote2Author: $strings.korcaPullQuote2Author,
        callout1: $strings.korcaCallout1,
        callout2: $strings.korcaCallout2,
        videoCaption: $strings.korcaVideoCaption,
        mapCaption: $strings.korcaMapCaption,
        historyInfo1: $strings.korcaHistoryInfo1,
        historyInfo2: $strings.korcaHistoryInfo2,
        constructionInfo1: $strings.korcaConstructionInfo1,
        constructionInfo2: $strings.korcaConstructionInfo2,
        locationInfo1: $strings.korcaLocationInfo1,
        locationInfo2: $strings.korcaLocationInfo2,
        events: {
          1769: $strings.korca1769ce,
          1887: $strings.korca1887ce,
          1891: $strings.korca1891ce,
          1916: $strings.korca1916ce,
          1968: $strings.korca1968ce,
          1994: $strings.korca1994ce,
        },
      );
}
