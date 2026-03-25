import Foundation

// MARK: - Property Service

@MainActor
final class PropertyService {
    static let shared = PropertyService()

    private let db = DatabaseService.shared

    private init() {}

    // R5: Uses SQLite via DatabaseService (was in-memory in R2)
    func fetchAll(forGoalId goalId: UUID) async -> [Property] {
        do {
            return try db.fetchProperties(forGoalId: goalId)
        } catch {
            print("PropertyService.fetchAll error: \(error)")
            return []
        }
    }

    func create(goalId: UUID, address: String, price: Double, link: String?, notes: String?) async throws {
        let property = Property(goalId: goalId, address: address, price: price, link: link, notes: notes)
        try db.insertProperty(property)
    }

    func update(_ property: Property) async throws {
        try db.updateProperty(property)
    }

    func delete(id: UUID) async throws {
        try db.deleteProperty(id: id)
    }
}
