import SwiftUI
import WidgetKit
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @ObservedObject var taskStore = TaskStore.shared
    @State private var newTaskText = ""
    @State private var overlayURLs: [Int: URL] = [:] // index: widget number (1-4)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // To-Do List UI (unchanged)
            GroupBox("To-Do List") {
                HStack {
                    TextField("New Task", text: $newTaskText)
                        .textFieldStyle(.roundedBorder)
                    Button("Add", action: addTask)
                        .keyboardShortcut(.return, modifiers: [])
                }
                List {
                    ForEach(taskStore.tasks) { task in
                        HStack {
                            Button(intent: {
                                var i = ToggleTaskIntent()
                                i.id = task.id.uuidString
                                return i
                            }()) {
                                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)
                            Text(task.title)
                                .strikethrough(task.done)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            // 👇 Trash icon to remove in-app
                            Button(role: .destructive) {
                                if let idx = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                                    taskStore.remove(at: IndexSet(integer: idx))
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .frame(height: 220)
            }

            // Widget Overlay image pickers (as HStack)
            GroupBox("Widget Overlays (PNG)") {
                HStack(spacing: 24) {
                    ForEach(1...4, id: \.self) { idx in
                        VStack(spacing: 8) {
                            if let url = overlayURLs[idx], let nsImage = NSImage(contentsOf: url) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(12)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(12)
                                    .overlay(Text("No image").font(.caption))
                            }
                            Button("Select\n#\(idx)", action: { selectImage(for: idx) })
                                .font(.system(size: 12))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .padding(32)
        .onAppear(perform: loadOverlayURLs)
    }

    // MARK: - To-Do methods (unchanged)
    private func addTask() {
        guard !newTaskText.isEmpty else { return }
        let updated = taskStore.tasks + [ToDoItem(title: newTaskText)]
        newTaskText = ""
        taskStore.save(updated)
    }

    private func delete(at offsets: IndexSet) {
        taskStore.remove(at: offsets)
    }

    // MARK: - Overlay selection for multiple widgets
    private func loadOverlayURLs() {
        let fm = FileManager.default
        guard let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.macwidgets") else { return }
        var loaded = [Int: URL]()
        for idx in 1...4 {
            let url = container.appendingPathComponent("widget\(idx).png")
            if fm.fileExists(atPath: url.path) {
                loaded[idx] = url
            }
        }
        overlayURLs = loaded
    }

    private func selectImage(for idx: Int) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .image]
        panel.title = "Select PNG for Widget \(idx)"

        guard panel.runModal() == .OK, let pickedURL = panel.url else { return }

        let fm = FileManager.default
        guard let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.macwidgets") else { return }
        let dest = container.appendingPathComponent("widget\(idx).png")

        do {
            if fm.fileExists(atPath: dest.path) { try fm.removeItem(at: dest) }
            try fm.copyItem(at: pickedURL, to: dest)
            overlayURLs[idx] = dest
            WidgetCenter.shared.reloadTimelines(ofKind: "MyClearWidget\(idx)")
        } catch {
            print("❌ failed to save widget overlay:", error)
        }
    }
}
