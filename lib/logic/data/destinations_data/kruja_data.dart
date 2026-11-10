import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class KrujaData extends DestinationData {
  KrujaData()
    : super(
        type: DestinationType.kruja,
        title: $strings.krujaTitle,
        regionTitle: $strings.krujaRegionTitle,
        videoId: 'SIxTr3WbZlY',
        startYr: 400,
        artifactCulture: $strings.krujaArtifactCulture,
        lat: 41.5147,
        lng: 19.7884,
        pullQuote1Top: $strings.krujaPullQuote1Top,
        pullQuote1Bottom: $strings.krujaPullQuote1Bottom,
        pullQuote1Author: $strings.krujaPullQuote1Author,
        pullQuote2: $strings.krujaPullQuote2,
        pullQuote2Author: $strings.krujaPullQuote2Author,
        callout1: $strings.krujaCallout1,
        callout2: $strings.krujaCallout2,
        videoCaption: $strings.krujaVideoCaption,
        mapCaption: $strings.krujaMapCaption,
        historyInfo1: $strings.krujaHistoryInfo1,
        historyInfo2: $strings.krujaHistoryInfo2,
        constructionInfo1: $strings.krujaConstructionInfo1,
        constructionInfo2: $strings.krujaConstructionInfo2,
        locationInfo1: $strings.krujaLocationInfo1,
        locationInfo2: $strings.krujaLocationInfo2,
        events: {
          1190: $strings.kruja1190ce,
          1443: $strings.kruja1443ce,
          1450: $strings.kruja1450ce,
          1478: $strings.kruja1478ce,
          1982: $strings.kruja1982ce,
          1989: $strings.kruja1989ce,
        },
      );
}
