import 'package:travel_buddy/common_libs.dart';

class TimelineEvent {
  TimelineEvent(this.year, this.description);
  final int year;
  final String description;
}

class GlobalEventsData {
  final globalEvents = [
    TimelineEvent(-2900, $strings.timelineEvent2900bce),
    TimelineEvent(-2700, $strings.timelineEvent2700bce),
    TimelineEvent(-2600, $strings.timelineEvent2600bce),
    TimelineEvent(-2560, $strings.timelineEvent2560bce),
    TimelineEvent(-1200, $strings.timelineEvent1200bce),
    TimelineEvent(-627, $strings.timelineEvent627bce),
    TimelineEvent(-358, $strings.timelineEvent358bce),
    TimelineEvent(-229, $strings.timelineEvent229bce),
    TimelineEvent(-168, $strings.timelineEvent168bce),
    TimelineEvent(-146, $strings.timelineEvent146bce),
    TimelineEvent(395, $strings.timelineEvent395ce),
    TimelineEvent(500, $strings.timelineEvent500ce),
    TimelineEvent(632, $strings.timelineEvent632ce),
    TimelineEvent(1018, $strings.timelineEvent1018ce),
    TimelineEvent(1043, $strings.timelineEvent1043ce),
    TimelineEvent(1081, $strings.timelineEvent1081ce),
    TimelineEvent(1190, $strings.timelineEvent1190ce),
    TimelineEvent(1271, $strings.timelineEvent1271ce),
    TimelineEvent(1347, $strings.timelineEvent1347ce),
    TimelineEvent(1355, $strings.timelineEvent1355ce),
    TimelineEvent(1389, $strings.timelineEvent1389ce),
    TimelineEvent(1428, $strings.timelineEvent1428ce),
    TimelineEvent(1443, $strings.timelineEvent1443ce),
    TimelineEvent(1444, $strings.timelineEvent1444ce),
    TimelineEvent(1450, $strings.timelineEvent1450ce),
    TimelineEvent(1466, $strings.timelineEvent1466ce),
    TimelineEvent(1468, $strings.timelineEvent1468ce),
    TimelineEvent(1479, $strings.timelineEvent1479ce),
    TimelineEvent(1571, $strings.timelineEvent1571ce),
    TimelineEvent(1788, $strings.timelineEvent1788ce),
    TimelineEvent(1789, $strings.timelineEvent1789ce),
    TimelineEvent(1830, $strings.timelineEvent1830ce),
    TimelineEvent(1878, $strings.timelineEvent1878ce),
    TimelineEvent(1908, $strings.timelineEvent1908ce),
    TimelineEvent(1912, $strings.timelineEvent1912ce),
    TimelineEvent(1914, $strings.timelineEvent1914ce),
    TimelineEvent(1920, $strings.timelineEvent1920ce),
    TimelineEvent(1928, $strings.timelineEvent1928ce),
    TimelineEvent(1939, $strings.timelineEvent1939ce),
    TimelineEvent(1939, $strings.timelineEvent1939ceAlbania),
    TimelineEvent(1944, $strings.timelineEvent1944ce),
    TimelineEvent(1967, $strings.timelineEvent1967ce),
    TimelineEvent(1991, $strings.timelineEvent1991ce),
    TimelineEvent(1997, $strings.timelineEvent1997ce),
    TimelineEvent(2009, $strings.timelineEvent2009ce),
    TimelineEvent(2019, $strings.timelineEvent2019ce),
  ];
}
