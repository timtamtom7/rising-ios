import Foundation

// MARK: - Deposit Service

@MainActor
final class DepositService {
    static let shared = DepositService()

    private let db = DatabaseService.shared

    private init() {}

    func fetchAll(forGoalId goalId: UUID) async -> [Deposit] {
        do {
            return try db.fetchDeposits(forGoalId: goalId)
        } catch {
            print("DepositService.fetchAll error: \(error)")
            return []
        }
    }

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

    func delete(id: UUID) async throws {
        try db.deleteDeposit(id: id)
    }
}
