import WidgetKit
import SwiftUI
import Intents

/// Every home-widget requires a TimelineEntry. This is passed into the view and propvides any data it needs
struct TravelBuddyTimelineEntry : TimelineEntry {
    // Date is a mandatory field for all TimelineEntries
    let date: Date
    // Custom field for the Travel Buddy view
    let discoveredCount:Int;
    var title:String = "";
    var subTitle:String = "";
    var imageData:String = "";
}

/// Widget, defines some high level configuration options as well as the primary view that will display the widget.
struct TravelBuddyWidget: Widget {
    let kind: String = "TravelBuddyWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TravelBuddyTimelineProvider()) { entry in
            TravelBuddyWidgetView(entry: entry)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Travel Buddy Widget")
        .description("Track your collected artifacts!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TravelBuddyConfig {
    let iosKey = "group.com.travelbuddy.app.widget"
    let discoveredCountKey = "dicoveredCount"
}

/// TimelineProvider, returns various TravelBuddyTimelineEntry configurations for different contexts
struct TravelBuddyTimelineProvider: TimelineProvider {
    // Provide an entry for a placeholder version of the widget
    func placeholder(in context: Context) -> TravelBuddyTimelineEntry {
        TravelBuddyTimelineEntry(date: Date(), discoveredCount: 0)
    }
    
    // Provide an entry for the current time and state of the widget
    func getSnapshot(in context: Context, completion: @escaping (TravelBuddyTimelineEntry) -> ()) {
        let entry:TravelBuddyTimelineEntry
        let userDefaults = UserDefaults(suiteName: "group.com.travelbuddy.app.widget")
        let discoveredCount = userDefaults?.integer(forKey: "discoveredCount") ?? 0
        let title = userDefaults?.string(forKey: "lastDiscoveredTitle") ?? ""
        let subTitle = userDefaults?.string(forKey: "lastDiscoveredSubTitle") ?? ""
        let imageData = userDefaults?.string(forKey: "lastDiscoveredImageData") ?? ""
        entry = TravelBuddyTimelineEntry(
            date: Date(),
            discoveredCount:discoveredCount,
            title: title,
            subTitle: subTitle.prefix(1).capitalized + subTitle.dropFirst(),
            imageData: imageData
        )
        completion(entry);
    }
    
    // Provide an array of entries for the current time and, optionally, any future times
    func getTimeline(in context: Context, completion: @escaping (Timeline<TravelBuddyTimelineEntry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}





