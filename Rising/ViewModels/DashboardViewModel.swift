import Foundation

// MARK: - Dashboard View Model

@MainActor
@Observable
final class DashboardViewModel {
    var goals: [Goal] = []
    var isLoading = false
    var errorMessage: String?

    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    var totalTarget: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }

    var overallProgress: Double {
        guard totalTarget > 0 else { return 0 }
        return totalSaved / totalTarget
    }

    var isEmpty: Bool {
        goals.isEmpty
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            goals = await GoalService.shared.fetchAll()
        } catch {
            errorMessage = "Failed to load your goals. Pull to refresh."
        }
        isLoading = false
    }

    func deleteGoal(_ goal: Goal) async {
        do {
            try await GoalService.shared.delete(id: goal.id)
            goals.removeAll { $0.id == goal.id }
        } catch {
            errorMessage = "Failed to delete goal. Try again."
        }
    }
}
