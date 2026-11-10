import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class GjirokasterData extends DestinationData {
  GjirokasterData()
    : super(
        type: DestinationType.gjirokaster,
        title: $strings.gjirokasterTitle,
        regionTitle: $strings.gjirokasterRegionTitle,
        videoId: 'rGi3Zr_EOss',
        startYr: 400,
        artifactCulture: $strings.gjirokasterArtifactCulture,
        lat: 40.0801,
        lng: 20.1383,
        pullQuote1Top: $strings.gjirokasterPullQuote1Top,
        pullQuote1Bottom: $strings.gjirokasterPullQuote1Bottom,
        pullQuote1Author: '',
        pullQuote2: $strings.gjirokasterPullQuote2,
        pullQuote2Author: $strings.gjirokasterPullQuote2Author,
        callout1: $strings.gjirokasterCallout1,
        callout2: $strings.gjirokasterCallout2,
        videoCaption: $strings.gjirokasterVideoCaption,
        mapCaption: $strings.gjirokasterMapCaption,
        historyInfo1: $strings.gjirokasterHistoryInfo1,
        historyInfo2: $strings.gjirokasterHistoryInfo2,
        constructionInfo1: $strings.gjirokasterConstructionInfo1,
        constructionInfo2: $strings.gjirokasterConstructionInfo2,
        locationInfo1: $strings.gjirokasterLocationInfo1,
        locationInfo2: $strings.gjirokasterLocationInfo2,
        events: {
          1336: $strings.gjirokaster1336ce,
          1418: $strings.gjirokaster1418ce,
          1811: $strings.gjirokaster1811ce,
          1932: $strings.gjirokaster1932ce,
          1936: $strings.gjirokaster1936ce,
          2005: $strings.gjirokaster2005ce,
        },
      );
}
