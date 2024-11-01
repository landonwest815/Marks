import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            TermsView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Term.self])
}
