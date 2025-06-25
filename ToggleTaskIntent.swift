// =============================
// ToggleTaskIntent.swift (in App target)
// =============================
import AppIntents
import WidgetKit

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"

    @Parameter(title: "Task ID") var id: String

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: id) else { return .result() }
        TaskStore.shared.toggle(id: uuid)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
