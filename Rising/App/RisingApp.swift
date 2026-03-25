import SwiftUI

@main
struct RisingApp: App {
    @State private var themeMode: ThemeService.ThemeMode = ThemeService.shared.themeMode

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch themeMode {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}
