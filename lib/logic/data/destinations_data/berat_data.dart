import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class BeratData extends DestinationData {
  BeratData()
    : super(
        type: DestinationType.berat,
        title: $strings.beratTitle,
        regionTitle: $strings.beratRegionTitle,
        videoId: 'ryqFzg9z9FU',
        startYr: -700,
        artifactCulture: $strings.beratArtifactCulture,
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
          -200: $strings.berat200bce,
          1417: $strings.berat1417ce,
          1547: $strings.berat1547ce,
          1922: $strings.berat1922ce,
          1961: $strings.berat1961ce,
          2008: $strings.berat2008ce,
        },
      );
}
