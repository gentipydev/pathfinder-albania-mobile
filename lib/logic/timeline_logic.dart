import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/timeline_data.dart';

class TimelineLogic {
  List<TimelineEvent> events = [];

  void init() {
    // Create an event for each destination, and merge it with the list of GlobalEvents
    events = [
      ...GlobalEventsData().globalEvents,
      ...destinationsLogic.all.map(
        (w) => TimelineEvent(
          w.startYr,
          $strings.timelineLabelConstruction(w.title),
        ),
      ),
    ];
  }
}
