import SwiftUI

@main
struct MyApp: App {
    @ObservedObject
    private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .id(sessionManager.rootId)
        }
    }
}
