import SwiftUI

@main
struct RisingApp: App {
    @AppStorage("themeMode") private var themeMode: String = ThemeService.ThemeMode.system.rawValue
    @State private var deepLinkGoalId: UUID?
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme(for: themeMode))
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func colorScheme(for mode: String) -> ColorScheme? {
        switch ThemeService.ThemeMode(rawValue: mode) ?? .system {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "rising" else { return }

        switch url.host {
        case "goal":
            if let idString = url.pathComponents.dropFirst().first,
               let goalId = UUID(uuidString: idString) {
                deepLinkGoalId = goalId
                NotificationCenter.default.post(
                    name: .openGoalDeepLink,
                    object: nil,
                    userInfo: ["goalId": goalId]
                )
            }
        case "settings":
            NotificationCenter.default.post(name: .openSettingsDeepLink, object: nil)
        case "onboarding":
            showOnboarding = true
            NotificationCenter.default.post(name: .showOnboarding, object: nil)
        case "create":
            NotificationCenter.default.post(name: .showCreateGoal, object: nil)
        default:
            break
        }
    }
}

extension Notification.Name {
    static let openGoalDeepLink = Notification.Name("openGoalDeepLink")
    static let openSettingsDeepLink = Notification.Name("openSettingsDeepLink")
    static let showOnboarding = Notification.Name("showOnboarding")
    static let showCreateGoal = Notification.Name("showCreateGoal")
}
