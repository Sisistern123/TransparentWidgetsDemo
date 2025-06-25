//import WidgetKit
//import SwiftUI
//import AppKit
//
//struct ImageWidget: Widget {
//    // Step 2: Change kind string to match what FooObject.mm looks for!
//    let kind: String = "MyClearWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(
//            kind: kind,
//            provider: Provider()
//        ) { entry in
//            ZStack {
//                // overlay your PNG on top of the live‐wallpaper slice
//                if let overlay = entry.overlay {
//                    Image(nsImage: overlay)
//                        .resizable()
//                        .scaledToFill()
//                        .clipped()
//                }
//            }
//            // ← no modifiers here
//        }
//        .contentMarginsDisabled()
//        .contentMarginsDisabled()
//        .supportedFamilies([WidgetFamily.systemLarge])
//        .configurationDisplayName("Live‐Screenshot + PNG")
//        .description("Fakes transparency by using your cropped screenshot.")
//        .containerBackgroundRemovable(true)
//      
//    }
//}
//
//struct ImageEntry: TimelineEntry {
//    let date: Date
//    let overlay: NSImage?
//}
//
//struct Provider: TimelineProvider {
//    typealias Entry = ImageEntry
//
//    func placeholder(in context: Context) -> ImageEntry {
//        .init(date: .now, overlay: nil)
//    }
//
//    func getSnapshot(
//        in context: Context,
//        completion: @escaping (ImageEntry) -> Void
//    ) {
//        completion(.init(date: .now, overlay: loadOverlay()))
//    }
//
//    func getTimeline(
//        in context: Context,
//        completion: @escaping (Timeline<ImageEntry>) -> Void
//    ) {
//        let entry = ImageEntry(date: .now, overlay: loadOverlay())
//        // never refresh automatically; your host app writes a new PNG when you want one
//        completion(.init(entries: [entry], policy: .never))
//    }
//
//    /// Reads “widget.png” from your App Group container.
//    private func loadOverlay() -> NSImage? {
//        guard let container = FileManager
//                .default
//                .containerURL(
//                  forSecurityApplicationGroupIdentifier:
//                    "group.com.example.macwidgets"
//                )
//        else {
//            return nil
//        }s
//        let url = container.appendingPathComponent("widget.png")
//        return NSImage(contentsOf: url)
//    }
//}
