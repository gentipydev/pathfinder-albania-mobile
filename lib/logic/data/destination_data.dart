import 'package:equatable/equatable.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';

class DestinationData extends Equatable {
  const DestinationData({
    required this.type,
    required this.title,
    required this.regionTitle,
    this.startYr = 0,
    this.endYr,
    this.artifactCulture = '',
    this.lat = 0,
    this.lng = 0,
    required this.pullQuote1Top,
    required this.pullQuote1Bottom,
    required this.pullQuote1Author,
    this.pullQuote2 = '',
    this.pullQuote2Author = '',
    this.callout1 = '',
    this.callout2 = '',
    required this.historyInfo1,
    required this.historyInfo2,
    required this.constructionInfo1,
    required this.constructionInfo2,
    required this.locationInfo1,
    required this.locationInfo2,
    required this.videoId,
    this.videoCaption = '',
    this.mapCaption = '',
    required this.events,
  });

  final DestinationType type;
  final String title;
  final String regionTitle;
  final String historyInfo1;
  final String historyInfo2;
  final String constructionInfo1;
  final String constructionInfo2;
  final String locationInfo1;
  final String locationInfo2;
  final String pullQuote1Top;
  final String pullQuote1Bottom;
  final String pullQuote1Author;
  final String pullQuote2;
  final String pullQuote2Author;
  final String callout1;
  final String callout2;
  final String videoId;
  final String videoCaption;
  final String mapCaption;
  /// First dated settlement or record of the place.
  final int startYr;

  /// When the place's historic period ended, or null while it is still lived in.
  final int? endYr;
  final String artifactCulture;
  final double lat;
  final double lng;
  final Map<int, String> events;

  /// [endYr], or the current year for a place that is still lived in.
  int get endYrOrNow => endYr ?? DateTime.now().year;

  @override
  List<Object?> get props => [type, title, historyInfo1];
}
