import Foundation

// MARK: - Property Service

@MainActor
final class PropertyService {
    static let shared = PropertyService()

    private init() {}

    func fetchAll(forGoalId goalId: UUID) async -> [Property] {
        // In R2 we store in memory; will be persisted in R3
        return PropertyStorage.shared.properties(forGoalId: goalId)
    }

    func create(goalId: UUID, address: String, price: Double, link: String?, notes: String?) async throws {
        let property = Property(goalId: goalId, address: address, price: price, link: link, notes: notes)
        PropertyStorage.shared.add(property)
    }

    func update(_ property: Property) async throws {
        PropertyStorage.shared.update(property)
    }

    func delete(id: UUID) async throws {
        PropertyStorage.shared.delete(id: id)
    }
}

// MARK: - In-Memory Storage (R2, SQLite in R3)

@MainActor
final class PropertyStorage {
    static let shared = PropertyStorage()

    private var _properties: [Property] = []

    private init() {}

    func properties(forGoalId goalId: UUID) -> [Property] {
        _properties.filter { $0.goalId == goalId }
    }

    func add(_ property: Property) {
        _properties.append(property)
    }

    func update(_ property: Property) {
        if let index = _properties.firstIndex(where: { $0.id == property.id }) {
            _properties[index] = property
        }
    }

    func delete(id: UUID) {
        _properties.removeAll { $0.id == id }
    }
}
