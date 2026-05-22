import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class KorcaData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Korça values.
  KorcaData()
    : super(
        type: DestinationType.korca,
        title: $strings.korcaTitle,
        subTitle: $strings.korcaSubTitle,
        regionTitle: $strings.korcaRegionTitle,
        videoId: 'EWkDzLrhpXI',
        startYr: 1632,
        endYr: 1653,
        artifactStartYr: 1600,
        artifactEndYr: 1700,
        artifactCulture: $strings.korcaArtifactCulture,
        artifactGeolocation: $strings.korcaArtifactGeolocation,
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
          1631: $strings.korca1631ce,
          1647: $strings.korca1647ce,
          1658: $strings.korca1658ce,
          1901: $strings.korca1901ce,
          1984: $strings.korca1984ce,
          1998: $strings.korca1998ce,
        },
      );
}
