import SwiftUI

@main
struct HousieApp: App {
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

            TicketView(caller: caller)
                .tabItem { Label("Tickets", systemImage: "rectangle.grid.3x2.fill") }

            HowToPlayView()
                .tabItem { Label("How to Play", systemImage: "book.pages.fill") }
        }
    }
}
