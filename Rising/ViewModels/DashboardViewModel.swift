import Foundation

@MainActor
@Observable
/// View model for the dashboard screen.
final class DashboardViewModel {
    /// All goals to display.
    var goals: [Goal] = []
    /// Whether data is currently being loaded.
    var isLoading = false
    /// Error message to display if loading fails.
    var errorMessage: String?

    private let goalService: GoalServiceProtocol
    private let achievementService: AchievementService
    private let depositService: DepositServiceProtocol

    /// Creates a dashboard view model.
    /// - Parameter goalService: Service for goal operations (defaults to shared instance).
    /// - Parameter achievementService: Service for achievement tracking (defaults to shared instance).
    /// - Parameter depositService: Service for deposit operations (defaults to shared instance).
    init(
        goalService: GoalServiceProtocol = GoalService.shared,
        achievementService: AchievementService = .shared,
        depositService: DepositServiceProtocol = DepositService.shared
    ) {
        self.goalService = goalService
        self.achievementService = achievementService
        self.depositService = depositService
    }

    /// Sum of all goal current amounts.
    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    /// Sum of all goal target amounts.
    var totalTarget: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }

    /// Overall progress across all goals (0.0 to 1.0).
    var overallProgress: Double {
        guard totalTarget > 0 else { return 0 }
        return totalSaved / totalTarget
    }

    /// Whether there are no goals to display.
    var isEmpty: Bool {
        goals.isEmpty
    }

    /// Loads all goals from the service.
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            goals = await goalService.fetchAll()
            let deposits = await depositService.fetchAll()
            achievementService.checkAndUpdate(
                deposits: deposits,
                goals: goals,
                hasJoinedCommunity: false,
                isSubscribed: false
            )
        } catch {
            errorMessage = "Failed to load your goals. Pull to refresh."
        }
        isLoading = false
    }

    /// Deletes a goal and removes it from the list.
    /// - Parameter goal: The goal to delete.
    func deleteGoal(_ goal: Goal) async {
        do {
            try await goalService.delete(id: goal.id)
            goals.removeAll { $0.id == goal.id }
        } catch {
            errorMessage = "Failed to delete goal. Try again."
        }
    }
}
