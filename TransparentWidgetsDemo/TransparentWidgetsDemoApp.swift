import SwiftUI

@main
struct MacWidgetsApp: App {
    let taskStore = TaskStore.shared // not @ObservedObject!

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskStore)
                .onAppear {
                    taskStore.initialize()
                }
                .onOpenURL { url in
                    // Always reload from disk!
                    taskStore.tasks = taskStore.load()
                    print("AFTER RELOAD: tasks =", taskStore.tasks)

                    if url.scheme == "macwidgets", url.host == "remove" {
                        if let id = url.queryParameters?["id"],
                           let uuid = UUID(uuidString: id) {
                            taskStore.remove(withId: uuid)
                        }
                    }
                }


        }
    }
}

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return nil }
        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}

