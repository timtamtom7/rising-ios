import Foundation
import SwiftUI

// MARK: - Onboarding View Model

@MainActor
@Observable
final class OnboardingViewModel {
    var currentStep = 0
    let totalSteps = 4

    // Step 1: Welcome
    // Step 2: First Goal
    var goalName = ""
    var goalTargetAmount = ""
    var goalDeadline: Date = Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date()
    var goalDescription = ""

    // Step 3: Why Rising
    // Step 4: Ready

    var isValidGoal: Bool {
        !goalName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(goalTargetAmount) ?? 0 > 0
    }

    var canProceed: Bool {
        switch currentStep {
        case 1: return isValidGoal
        default: return true
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentStep += 1
            }
        }
    }

    func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentStep -= 1
            }
        }
    }

    func completeOnboarding() async throws {
        // Create the first goal if valid
        if isValidGoal {
            let amount = Double(goalTargetAmount) ?? 0
            try await GoalService.shared.create(
                name: goalName.trimmingCharacters(in: .whitespaces),
                targetAmount: amount,
                deadline: goalDeadline,
                iconName: "target",
                description: goalDescription.isEmpty ? nil : goalDescription
            )
        }
        OnboardingService.shared.completeOnboarding()
    }
}
