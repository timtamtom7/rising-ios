import Foundation
import SwiftUI

// MARK: - Settings View Model

@MainActor
@Observable
final class SettingsViewModel {
    private let subscriptionService: SubscriptionService
    private let onboardingService: OnboardingService
    private let themeService: ThemeService

    init(
        subscriptionService: SubscriptionService = .shared,
        onboardingService: OnboardingService = .shared,
        themeService: ThemeService = .shared
    ) {
        self.subscriptionService = subscriptionService
        self.onboardingService = onboardingService
        self.themeService = themeService
    }

    var themeMode: ThemeService.ThemeMode {
        get { themeService.themeMode }
        set { themeService.themeMode = newValue }
    }

    var hasCompletedOnboarding: Bool {
        onboardingService.hasCompletedOnboarding
    }

    func resetOnboarding() {
        onboardingService.resetOnboarding()
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var subscriptionStatus: SubscriptionService.Status {
        subscriptionService.subscriptionStatus
    }

    var isSubscribed: Bool {
        switch subscriptionStatus {
        case .notSubscribed:
            return false
        case .subscribed, .trialDaysRemaining:
            return true
        }
    }

    var subscriptionTierName: String {
        switch subscriptionStatus {
        case .notSubscribed:
            return "Free"
        case .subscribed(let tier):
            return tier == .yearly ? "Premium Yearly" : "Premium Monthly"
        case .trialDaysRemaining(let days):
            return "Trial (\(days) days)"
        }
    }

    func restorePurchases() async {
        await subscriptionService.restorePurchases()
    }
}
