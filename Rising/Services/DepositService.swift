import Foundation

// MARK: - Deposit Service

@MainActor
final class DepositService {
    /// Shared singleton instance.
    static let shared = DepositService()

    private let db = DatabaseService.shared

    private init() {}

    /// Fetches all deposits for a specific goal.
    /// - Parameter goalId: The ID of the goal.
    /// - Returns: Array of deposits for the goal, or empty array on error.
    func fetchAll(forGoalId goalId: UUID) async -> [Deposit] {
        do {
            return try db.fetchDeposits(forGoalId: goalId)
        } catch {
            print("DepositService.fetchAll error: \(error)")
            return []
        }
    }

    /// Fetches all deposits across all goals.
    /// - Returns: Array of all deposits, or empty array on error.
    func fetchAll() async -> [Deposit] {
        do {
            return try db.fetchAllDeposits()
        } catch {
            print("DepositService.fetchAll error: \(error)")
            return []
        }
    }

    /// Creates a new deposit and updates the goal's current amount.
    /// - Parameters:
    ///   - goalId: The ID of the goal to add the deposit to.
    ///   - amount: The deposit amount in dollars.
    ///   - date: The date the deposit was made.
    ///   - note: Optional note describing the deposit.
    func create(goalId: UUID, amount: Double, date: Date, note: String?) async throws {
        let deposit = Deposit(
            goalId: goalId,
            amount: amount,
            date: date,
            note: note
        )
        try db.insertDeposit(deposit)

        // Also update the goal's current amount
        try await GoalService.shared.addDeposit(goalId: goalId, amount: amount)
    }

    /// Deletes a deposit from the database.
    /// - Parameter id: The ID of the deposit to delete.
    func delete(id: UUID) async throws {
        try db.deleteDeposit(id: id)
    }
}
