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
                        LearnListView()
                            .tabItem { Label("Learn", systemImage: "graduationcap.fill") }
                        
                        SandboxListView()
                            .tabItem { Label("Sandbox", systemImage: "slider.horizontal.3") }
                        
                        QuizHomeView()
                            .tabItem { Label("Test", systemImage: "checkmark.seal.fill") }
                        
                        DirectoryListView()
                            .tabItem { Label("Directory", systemImage: "doc.text.magnifyingglass") }
                    }
                    .tint(.cyan)
                }
            }
            .environmentObject(progressManager)
            .preferredColorScheme(.dark)
        }
    }
}
