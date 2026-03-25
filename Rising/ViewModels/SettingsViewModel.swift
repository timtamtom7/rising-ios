import Foundation
import SwiftUI

// MARK: - Settings View Model

@MainActor
@Observable
final class SettingsViewModel {
    var themeMode: ThemeService.ThemeMode {
        get { ThemeService.shared.themeMode }
        set { ThemeService.shared.themeMode = newValue }
    }

    var hasCompletedOnboarding: Bool {
        OnboardingService.shared.hasCompletedOnboarding
    }

    func resetOnboarding() {
        OnboardingService.shared.resetOnboarding()
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
