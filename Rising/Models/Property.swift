import Foundation

// MARK: - Property Model (R2)

struct Property: Identifiable, Codable, Equatable {
    let id: UUID
    var goalId: UUID
    var address: String
    var price: Double
    var link: String?
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        goalId: UUID,
        address: String,
        price: Double,
        link: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.address = address
        self.price = price
        self.link = link
        self.notes = notes
        self.createdAt = createdAt
    }
}
