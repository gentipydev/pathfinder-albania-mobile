import WidgetKit
import SwiftUI
import Intents

/// Every home-widget requires a TimelineEntry. This is passed into the view and propvides any data it needs
struct PathfinderTimelineEntry : TimelineEntry {
    // Date is a mandatory field for all TimelineEntries
    let date: Date
    // Custom field for the Pathfinder Albania view
    let discoveredCount:Int;
    // Number of collectibles in the backend catalog (0 until the app sends it)
    var totalCount:Int = 0;
    var title:String = "";
    var subTitle:String = "";
    var imageData:String = "";
}

/// Widget, defines some high level configuration options as well as the primary view that will display the widget.
struct PathfinderWidget: Widget {
    let kind: String = "PathfinderWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PathfinderTimelineProvider()) { entry in
            PathfinderWidgetView(entry: entry)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Pathfinder Albania")
        .description("Track your collected artifacts!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/// TimelineProvider, returns various PathfinderTimelineEntry configurations for different contexts
struct PathfinderTimelineProvider: TimelineProvider {
    // Provide an entry for a placeholder version of the widget
    func placeholder(in context: Context) -> PathfinderTimelineEntry {
        PathfinderTimelineEntry(date: Date(), discoveredCount: 0)
    }
    
    // Provide an entry for the current time and state of the widget
    func getSnapshot(in context: Context, completion: @escaping (PathfinderTimelineEntry) -> ()) {
        let entry:PathfinderTimelineEntry
        let userDefaults = UserDefaults(suiteName: "group.com.pathfinderalbania.app.widget")
        let discoveredCount = userDefaults?.integer(forKey: "discoveredCount") ?? 0
        let totalCount = userDefaults?.integer(forKey: "totalCount") ?? 0
        let title = userDefaults?.string(forKey: "lastDiscoveredTitle") ?? ""
        let subTitle = userDefaults?.string(forKey: "lastDiscoveredSubTitle") ?? ""
        let imageData = userDefaults?.string(forKey: "lastDiscoveredImageData") ?? ""
        entry = PathfinderTimelineEntry(
            date: Date(),
            discoveredCount:discoveredCount,
            totalCount: totalCount,
            title: title,
            subTitle: subTitle.prefix(1).capitalized + subTitle.dropFirst(),
            imageData: imageData
        )
        completion(entry);
    }
    
    // Provide an array of entries for the current time and, optionally, any future times
    func getTimeline(in context: Context, completion: @escaping (Timeline<PathfinderTimelineEntry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}





