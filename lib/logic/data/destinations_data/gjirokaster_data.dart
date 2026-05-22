import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/destination_data.dart';

class GjirokasterData extends DestinationData {
  // TODO(rebrand): lat/lng, videoId, year ranges, and event year keys below
  // are inherited from the original upstream template data and need to be
  // replaced with real Gjirokastër values.
  GjirokasterData()
    : super(
        type: DestinationType.gjirokaster,
        title: $strings.gjirokasterTitle,
        subTitle: $strings.gjirokasterSubTitle,
        regionTitle: $strings.gjirokasterRegionTitle,
        videoId: 'GXoEpNjgKzg',
        startYr: 70,
        endYr: 80,
        artifactStartYr: 0,
        artifactEndYr: 500,
        artifactCulture: $strings.gjirokasterArtifactCulture,
        artifactGeolocation: $strings.gjirokasterArtifactGeolocation,
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
          70: $strings.gjirokaster70ce,
          82: $strings.gjirokaster82ce,
          1140: $strings.gjirokaster1140ce,
          1490: $strings.gjirokaster1490ce,
          1829: $strings.gjirokaster1829ce,
          1990: $strings.gjirokaster1990ce,
        },
      );
}
