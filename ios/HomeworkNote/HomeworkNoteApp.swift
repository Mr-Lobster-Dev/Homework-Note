import SwiftUI

@main
struct HomeworkNoteApp: App {
    var body: some Scene {
        WindowGroup {
            WebContainer()
                .ignoresSafeArea()
                .background(Color(.systemGroupedBackground))
        }
    }
}
