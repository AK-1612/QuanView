import SwiftUI

@main
struct PlanckApp: App {
    @StateObject private var progressManager = UserProgressManager()
    @AppStorage("QuanView.HasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenWelcome {
                    WelcomeView(isPresented: Binding(
                        get: { !hasSeenWelcome },
                        set: { hasSeenWelcome = !$0 }
                    ))
                } else {
                    TabView {
                        ExploreView()
                            .tabItem { Label("Labs", systemImage: "flask.fill") }
                        
                        LabNotebookView()
                            .tabItem { Label("Logs", systemImage: "book.pages.fill") }
                    }
                    .tint(.cyan)
                }
            }
            .environmentObject(progressManager)
            .preferredColorScheme(.dark)
        }
    }
}
