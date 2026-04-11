import Foundation

// MARK: - Property List View Model

@MainActor
@Observable
final class PropertyListViewModel {
    var properties: [Property] = []
    var isLoading = false
    var errorMessage: String?

    let goalId: UUID
    private let propertyService: PropertyServiceProtocol

    init(goalId: UUID, propertyService: PropertyServiceProtocol = PropertyService.shared) {
        self.goalId = goalId
        self.propertyService = propertyService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        properties = await propertyService.fetchAll(forGoalId: goalId)
        isLoading = false
    }

    func delete(_ property: Property) async {
        do {
            try await propertyService.delete(id: property.id)
            properties.removeAll { $0.id == property.id }
        } catch {
            errorMessage = "Failed to delete property."
        }
    }
}
