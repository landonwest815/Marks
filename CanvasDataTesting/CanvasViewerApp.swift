import SwiftUI
import SwiftData

@main
struct CanvasViewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Term.self])
        }
    }
}
