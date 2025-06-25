import WidgetKit
import SwiftUI

@main
struct MacWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ImageWidget1()
        ImageWidget2()
        ImageWidget3()
        ImageWidget4()
        ToDoListWidget()
        HolidayWidget()
    }
}
