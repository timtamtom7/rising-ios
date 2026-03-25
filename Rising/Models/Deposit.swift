import Foundation

// MARK: - Deposit Model

struct Deposit: Identifiable, Codable, Equatable {
    let id: UUID
    let goalId: UUID
    var amount: Double
    var date: Date
    var note: String?
    var createdAt: Date

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
