import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/logic/data/timeline_data.dart';

class TimelineLogic {
  List<TimelineEvent> events = [];

  void init() {
    // Create an event for each destination, and merge it with the list of GlobalEvents
    final all = [
      ...GlobalEventsData().globalEvents,
      ...destinationsLogic.all.map(
        (w) => TimelineEvent(
          w.startYr,
          $strings.timelineLabelOrigin(w.title),
        ),
      ),
    ];
    // The timeline shows one card per year, so events that share a year go
    // into the same card instead of hiding each other.
    final byYear = <int, List<String>>{};
    for (final e in all) {
      byYear.putIfAbsent(e.year, () => []).add(e.description);
    }
    events = [for (final e in byYear.entries) TimelineEvent(e.key, e.value.join('\n\n'))];
  }
}
