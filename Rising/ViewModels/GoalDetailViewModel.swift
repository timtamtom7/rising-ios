import Foundation

@MainActor
@Observable
/// View model for the goal detail screen.
final class GoalDetailViewModel {
    /// The goal being displayed.
    var goal: Goal
    /// Deposits associated with the goal.
    var deposits: [Deposit] = []
    /// Whether data is currently being loaded.
    var isLoading = false
    /// Error message to display if loading fails.
    var errorMessage: String?

    private let goalService: GoalServiceProtocol
    private let depositService: DepositServiceProtocol

    /// Creates a goal detail view model.
    /// - Parameters:
    ///   - goal: The goal to display.
    ///   - goalService: Service for goal operations.
    ///   - depositService: Service for deposit operations.
    init(goal: Goal, goalService: GoalServiceProtocol = GoalService.shared, depositService: DepositServiceProtocol = DepositService.shared) {
        self.goal = goal
        self.goalService = goalService
        self.depositService = depositService
    }

    /// Progress toward the goal (0.0 to 1.0).
    var progress: Double {
        goal.progress
    }

    /// Amount remaining to reach the target.
    var remainingAmount: Double {
        goal.remainingAmount
    }

    /// Number of days until the deadline.
    var daysRemaining: Int? {
        goal.daysRemaining
    }

    /// Progress as a percentage string (e.g., "45%").
    var formattedProgress: String {
        let percentage = Int(progress * 100)
        return "\(percentage)%"
    }

    /// Loads deposits for the goal.
    func loadDeposits() async {
        isLoading = true
        errorMessage = nil
        do {
            deposits = await depositService.fetchAll(forGoalId: goal.id)
        } catch {
            errorMessage = "Failed to load deposits."
        }
        isLoading = false
    }

    /// Deletes a deposit and updates the goal's current amount.
    /// - Parameter deposit: The deposit to delete.
    func deleteDeposit(_ deposit: Deposit) async {
        do {
            deposits.removeAll { $0.id == deposit.id }
            goal.currentAmount = max(goal.currentAmount - deposit.amount, 0)
            try await goalService.update(goal)
            try await depositService.delete(id: deposit.id)
        } catch {
            errorMessage = "Failed to delete deposit."
        }
    }

    /// Refreshes the goal data from the service.
    func refreshGoal() async {
        let allGoals = await goalService.fetchAll()
        if let updated = allGoals.first(where: { $0.id == goal.id }) {
            goal = updated
        }
    }
}
