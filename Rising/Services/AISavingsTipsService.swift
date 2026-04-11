import Foundation

// MARK: - R8: AI Savings Tips Service

@MainActor
@Observable
final class AISavingsTipsService {
    static let shared = AISavingsTipsService()

    var currentTip: SavingsTip?
    var isLoading = false

    private let tips: [SavingsTip] = [
        SavingsTip(
            title: "Automate your deposits",
            message: "Setting up automatic weekly deposits helps build consistency without relying on willpower.",
            iconName: "calendar.badge.plus",
            type: .action
        ),
        SavingsTip(
            title: "Round up purchases",
            message: "Link your card to round up purchases to the nearest dollar - the difference goes straight to your goal.",
            iconName: "arrow.up.circle",
            type: .action
        ),
        SavingsTip(
            title: "Celebrate milestones",
            message: "You've reached 50% of your goal! Consider a small reward from your non-essential budget.",
            iconName: "star.fill",
            type: .milestone
        ),
        SavingsTip(
            title: "Windfall boost",
            message: "Got a tax refund or bonus? Consider putting 50% toward your goal to accelerate progress.",
            iconName: "banknote",
            type: .action
        ),
        SavingsTip(
            title: "Cut one subscription",
            message: "Cancelling one unused subscription could add $100/month to your savings.",
            iconName: "xmark.circle",
            type: .action
        ),
        SavingsTip(
            title: "You're on track!",
            message: "Your savings rate is ahead of schedule. Keep it up!",
            iconName: "checkmark.seal.fill",
            type: .success
        ),
        SavingsTip(
            title: "Consider higher yield",
            message: "High-yield savings accounts currently offer ~4-5% APY. Moving your emergency fund could earn you $200+ per year.",
            iconName: "chart.line.uptrend.xyaxis",
            type: .insight
        ),
        SavingsTip(
            title: "Deposit streak",
            message: "You've made deposits 4 weeks in a row! This consistency is building your habit.",
            iconName: "flame.fill",
            type: .success
        )
    ]

    private init() {}

    func generateTip(for goal: Goal, recentDeposits: [Deposit]) -> SavingsTip {
        isLoading = true
        defer { isLoading = false }

        let progress = goal.progress
        let hasRecentDeposits = !recentDeposits.isEmpty
        let streak = calculateDepositStreak(recentDeposits)

        if streak >= 4 {
            return tips.first { $0.type == .success && $0.title.contains("streak") }!
        }

        if progress >= 1.0 {
            return SavingsTip(
                title: "Goal achieved!",
                message: "Congratulations! You've reached your target. Consider setting a new stretch goal.",
                iconName: "party.popper.fill",
                type: .milestone
            )
        }

        if progress >= 0.75 {
            return tips.first { $0.title.contains("50%") }!
        }

        if progress >= 0.5 && progress < 0.75 {
            return tips.first { $0.title.contains("round up") }!
        }

        if hasRecentDeposits && recentDeposits.count < 2 {
            return tips.first { $0.title.contains("automate") }!
        }

        if streak >= 2 {
            return tips.first { $0.title.contains("consistency") }!
        }

        return tips.randomElement()!
    }

    private func calculateDepositStreak(_ deposits: [Deposit]) -> Int {
        guard !deposits.isEmpty else { return 0 }

        let sortedDeposits = deposits.sorted { $0.date > $1.date }
        let calendar = Calendar.current
        var streak = 1

        for i in 1..<sortedDeposits.count {
            let current = sortedDeposits[i - 1].date
            let previous = sortedDeposits[i].date

            let daysBetween = calendar.dateComponents([.day], from: previous, to: current).day ?? 0

            if daysBetween <= 7 {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }
}

// MARK: - Savings Tip Model

struct SavingsTip: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let iconName: String
    let type: TipType

    enum TipType: String {
        case action
        case insight
        case success
        case milestone
    }

    var iconColor: String {
        switch type {
        case .action: return "risingPrimary"
        case .insight: return "risingAccent"
        case .success: return "risingSuccess"
        case .milestone: return "risingWarning"
        }
    }
}