import Foundation

// MARK: - Goal Detail View Model

@MainActor
@Observable
final class GoalDetailViewModel {
    var goal: Goal
    var deposits: [Deposit] = []
    var isLoading = false
    var errorMessage: String?

    init(goal: Goal) {
        self.goal = goal
    }

    var progress: Double {
        goal.progress
    }

    var remainingAmount: Double {
        goal.remainingAmount
    }

    var daysRemaining: Int? {
        goal.daysRemaining
    }

    var formattedProgress: String {
        let percentage = Int(progress * 100)
        return "\(percentage)%"
    }

    func loadDeposits() async {
        isLoading = true
        errorMessage = nil
        do {
            deposits = await DepositService.shared.fetchAll(forGoalId: goal.id)
        } catch {
            errorMessage = "Failed to load deposits."
        }
        isLoading = false
    }

    func deleteDeposit(_ deposit: Deposit) async {
        do {
            // Remove from local array first
            deposits.removeAll { $0.id == deposit.id }
            // Update goal's current amount
            goal.currentAmount = max(goal.currentAmount - deposit.amount, 0)
            try await GoalService.shared.update(goal)
            // Delete from DB (amount already subtracted)
            try await DepositService.shared.delete(id: deposit.id)
        } catch {
            errorMessage = "Failed to delete deposit."
        }
    }

    func refreshGoal() async {
        let allGoals = await GoalService.shared.fetchAll()
        if let updated = allGoals.first(where: { $0.id == goal.id }) {
            goal = updated
        }
    }
}
