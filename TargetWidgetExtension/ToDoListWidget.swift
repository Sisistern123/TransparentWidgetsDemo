import SwiftUI
import WidgetKit

struct ToDoListWidget: Widget {
    // If you want your swizzle to work, use "MyClearWidget" for full transparency
    let kind = "MyClearToDoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ToDoProvider()) { entry in
            TaskListView(entry: entry)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Transparent To-Do List")
        .description("Large list – tap a row to check it off.")
    }
}

struct ToDoEntry: TimelineEntry {
    let date: Date
    let tasks: [ToDoItem]
}

struct ToDoProvider: TimelineProvider {
    typealias Entry = ToDoEntry

    func placeholder(in context: Context) -> Entry {
        .init(date: .now, tasks: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let tasks = TaskStore.shared.load()
        completion(.init(date: .now, tasks: tasks))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let tasks = TaskStore.shared.load()
        let entry = Entry(date: .now, tasks: tasks)
        completion(.init(entries: [entry], policy: .never))
    }
}

private struct TaskListView: View {
    let entry: ToDoEntry

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.tasks.prefix(12), id: \.id) { task in
                    HStack(spacing: 8) {
                        Button(intent: {
                            var i = ToggleTaskIntent()
                            i.id = task.id.uuidString
                            return i
                        }()) {
                            Image(systemName: task.done
                                  ? "checkmark.circle.fill"
                                  : "circle")
                        }
                        .buttonStyle(.plain)

                        Text(task.title)
                            .strikethrough(task.done)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Remove button: opens main app to remove
                        Link(destination: URL(string: "macwidgets://remove?id=\(task.id.uuidString)")!) {
                            Image(systemName: "xmark.circle")
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 6)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
