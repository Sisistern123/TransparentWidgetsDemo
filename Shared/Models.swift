import Foundation
#if os(macOS)
import AppKit
#endif
import WidgetKit

public struct ToDoItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var done: Bool

    public init(id: UUID = UUID(), title: String, done: Bool = false) {
        self.id = id
        self.title = title
        self.done = done
    }
}

public final class TaskStore: ObservableObject {
    public static let shared = TaskStore()
    
    @Published var tasks: [ToDoItem] = []

    private let url: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.macwidgets")!
        url = container.appendingPathComponent("tasks.json")
    }
    
    public func initialize() {
        self.tasks = load()
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.macwidgets") {
            print("App Group container path:", container.path)
        }

    }


    public func load() -> [ToDoItem] {
        (try? Data(contentsOf: url))
            .flatMap { try? decoder.decode([ToDoItem].self, from: $0) } ?? []
    }

    public func save(_ items: [ToDoItem]) {
        // Don't overwrite disk with empty list unless you are sure!
        if items.isEmpty {
            print("Refusing to save empty list unless confirmed")
            // return // <-- for debugging, comment this in to prevent accidental wipes
        }
        let data = try? encoder.encode(items)
        try? data?.write(to: url, options: .atomic)
        self.tasks = items
        WidgetCenter.shared.reloadAllTimelines()
    }


    public func remove(at offsets: IndexSet) {
        var updated = self.tasks
        updated.remove(atOffsets: offsets)
        save(updated)
    }

    public func remove(withId id: UUID) {
        var updated = load()
        print("Loaded from disk before remove:", updated)
        let beforeCount = updated.count
        updated.removeAll { $0.id == id }
        let afterCount = updated.count
        print("After removeAll (should be one less):", updated)
        if afterCount == beforeCount {
            print("⚠️  No item removed! Check if ID is correct: \(id)")
        }
        save(updated)
    }




    public func toggle(id: UUID) {
        var items = load()
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].done.toggle()
            save(items)
        }
    }

    
}
