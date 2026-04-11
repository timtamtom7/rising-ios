import Foundation

// MARK: - Deposit Model

/// Represents a deposit made toward a savings goal.
struct Deposit: Identifiable, Codable, Equatable {
    /// Unique identifier for the deposit.
    let id: UUID
    /// ID of the goal this deposit belongs to.
    let goalId: UUID
    /// Amount deposited in dollars.
    var amount: Double
    /// Date the deposit was made.
    var date: Date
    /// Optional note describing the deposit.
    var note: String?
    /// Date when the deposit was recorded.
    var createdAt: Date

    /// Creates a new deposit.
    /// - Parameters:
    ///   - goalId: ID of the goal this deposit belongs to.
    ///   - amount: Amount deposited in dollars.
    ///   - date: Date the deposit was made.
    ///   - note: Optional note describing the deposit.
    init(
        id: UUID = UUID(),
        goalId: UUID,
        amount: Double,
        date: Date = Date(),
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.amount = amount
        self.date = date
        self.note = note
        self.createdAt = createdAt
    }
}
