import Foundation

// MARK: - Goal Service

@MainActor
final class GoalService {
    static let shared = GoalService()

    private let db = DatabaseService.shared

    private init() {}

    func fetchAll() async -> [Goal] {
        do {
            return try db.fetchAllGoals()
        } catch {
            print("GoalService.fetchAll error: \(error)")
            return []
        }
    }

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

    func update(_ goal: Goal) async throws {
        try db.updateGoal(goal)
    }

    func delete(id: UUID) async throws {
        try db.deleteGoal(id: id)
    }

    func addDeposit(goalId: UUID, amount: Double) async throws {
        var goals = try db.fetchAllGoals()
        guard let index = goals.firstIndex(where: { $0.id == goalId }) else { return }
        goals[index].currentAmount += amount
        try db.updateGoal(goals[index])
    }
}
