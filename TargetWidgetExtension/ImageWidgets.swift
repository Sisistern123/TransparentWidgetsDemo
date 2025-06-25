import WidgetKit
import SwiftUI
import AppKit

struct ImageEntry: TimelineEntry {
    let date: Date
    let overlay: NSImage?
}

// Helper to load the correct image file
func overlayImage(for name: String) -> NSImage? {
    guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.macwidgets") else { return nil }
    let url = container.appendingPathComponent(name)
    return NSImage(contentsOf: url)
}

// Providers (1–4)
struct Provider1: TimelineProvider {
    func placeholder(in context: Context) -> ImageEntry { .init(date: .now, overlay: nil) }
    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> Void) {
        completion(.init(date: .now, overlay: overlayImage(for: "widget1.png")))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> Void) {
        completion(.init(entries: [ImageEntry(date: .now, overlay: overlayImage(for: "widget1.png"))], policy: .never))
    }
}
struct Provider2: TimelineProvider {
    func placeholder(in context: Context) -> ImageEntry { .init(date: .now, overlay: nil) }
    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> Void) {
        completion(.init(date: .now, overlay: overlayImage(for: "widget2.png")))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> Void) {
        completion(.init(entries: [ImageEntry(date: .now, overlay: overlayImage(for: "widget2.png"))], policy: .never))
    }
}
struct Provider3: TimelineProvider {
    func placeholder(in context: Context) -> ImageEntry { .init(date: .now, overlay: nil) }
    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> Void) {
        completion(.init(date: .now, overlay: overlayImage(for: "widget3.png")))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> Void) {
        completion(.init(entries: [ImageEntry(date: .now, overlay: overlayImage(for: "widget3.png"))], policy: .never))
    }
}
struct Provider4: TimelineProvider {
    func placeholder(in context: Context) -> ImageEntry { .init(date: .now, overlay: nil) }
    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> Void) {
        completion(.init(date: .now, overlay: overlayImage(for: "widget4.png")))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> Void) {
        completion(.init(entries: [ImageEntry(date: .now, overlay: overlayImage(for: "widget4.png"))], policy: .never))
    }
}

// ImageWidgets (1–4)
struct ImageWidget1: Widget {
    let kind: String = "MyClearWidget1"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider1()) { entry in
            if let overlay = entry.overlay {
                Image(nsImage: overlay).resizable().scaledToFill().clipped()
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("Image Widget 1")
        .description("Shows custom PNG 1")
        .containerBackgroundRemovable(true)
    }
}
struct ImageWidget2: Widget {
    let kind: String = "MyClearWidget2"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider2()) { entry in
            if let overlay = entry.overlay {
                Image(nsImage: overlay).resizable().scaledToFill().clipped()
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("Image Widget 2")
        .description("Shows custom PNG 2")
        .containerBackgroundRemovable(true)
    }
}
struct ImageWidget3: Widget {
    let kind: String = "MyClearWidget3"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider3()) { entry in
            if let overlay = entry.overlay {
                Image(nsImage: overlay).resizable().scaledToFill().clipped()
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("Image Widget 3")
        .description("Shows custom PNG 3")
        .containerBackgroundRemovable(true)
    }
}
struct ImageWidget4: Widget {
    let kind: String = "MyClearWidget4"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider4()) { entry in
            if let overlay = entry.overlay {
                Image(nsImage: overlay).resizable().scaledToFill().clipped()
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("Image Widget 4")
        .description("Shows custom PNG 4")
        .containerBackgroundRemovable(true)
    }
}
