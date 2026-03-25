import Foundation

// MARK: - Property List View Model

@MainActor
@Observable
final class PropertyListViewModel {
    var properties: [Property] = []
    var isLoading = false
    var errorMessage: String?

    let goalId: UUID

    init(goalId: UUID) {
        self.goalId = goalId
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        properties = await PropertyService.shared.fetchAll(forGoalId: goalId)
        isLoading = false
    }

    func delete(_ property: Property) async {
        do {
            try await PropertyService.shared.delete(id: property.id)
            properties.removeAll { $0.id == property.id }
        } catch {
            errorMessage = "Failed to delete property."
        }
    }
}
