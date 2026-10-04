import SwiftUI

@main
struct HousieApp: App {
    @UIApplicationDelegateAdaptor(CastAppDelegate.self) private var appDelegate
    @State private var caller = CallerViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(caller: caller)
                .tint(HousieTheme.saffron)
        }
    }
}

private struct RootView: View {
    let caller: CallerViewModel

    var body: some View {
        TabView {
            CallerView(model: caller)
                .tabItem { Label("Caller", systemImage: "circle.grid.3x3.fill") }

            HowToPlayView()
                .tabItem { Label("How It Works", systemImage: "questionmark.circle.fill") }
        }
        .toolbarBackground(HousieTheme.midnight.opacity(0.97), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}
