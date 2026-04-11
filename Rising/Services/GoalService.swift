import Foundation

// MARK: - Goal Service

@MainActor
final class GoalService {
    /// Shared singleton instance.
    static let shared = GoalService()

    private let db = DatabaseService.shared

    private init() {}

    /// Fetches all goals from the database.
    /// - Returns: Array of all goals, or empty array on error.
    func fetchAll() async -> [Goal] {
        do {
            return try db.fetchAllGoals()
        } catch {
            print("GoalService.fetchAll error: \(error)")
            return []
        }
    }

    /// Creates a new goal and saves it to the database.
    /// - Parameters:
    ///   - name: Display name for the goal.
    ///   - targetAmount: Target amount to save in dollars.
    ///   - deadline: Optional deadline for achieving the goal.
    ///   - iconName: SF Symbol name for the goal's icon.
    ///   - description: Optional detailed description.
    func create(name: String, targetAmount: Double, deadline: Date?, iconName: String, description: String?) async throws {
        let goal = Goal(
            name: name,
            targetAmount: targetAmount,
            deadline: deadline,
            iconName: iconName,
            description: description
        )
        try db.insertGoal(goal)
    }

    /// Updates an existing goal in the database.
    /// - Parameter goal: The goal with updated values.
    func update(_ goal: Goal) async throws {
        try db.updateGoal(goal)
    }

    /// Deletes a goal from the database.
    /// - Parameter id: The ID of the goal to delete.
    func delete(id: UUID) async throws {
        try db.deleteGoal(id: id)
    }

    /// Adds a deposit amount to a goal's current amount.
    /// - Parameters:
    ///   - goalId: The ID of the goal to update.
    ///   - amount: The deposit amount to add.
    func addDeposit(goalId: UUID, amount: Double) async throws {
        var goals = try db.fetchAllGoals()
        guard let index = goals.firstIndex(where: { $0.id == goalId }) else { return }
        goals[index].currentAmount += amount
        try db.updateGoal(goals[index])
    }
}
