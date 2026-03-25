import Foundation

// MARK: - Add Property View Model

@MainActor
@Observable
final class AddPropertyViewModel {
    var address = ""
    var price = ""
    var link = ""
    var notes = ""

    let goalId: UUID

    var isValid: Bool {
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(price) ?? 0) > 0
    }

    init(goalId: UUID) {
        self.goalId = goalId
    }

    func save() async throws {
        guard let priceValue = Double(price), priceValue > 0 else {
            throw PropertyError.invalidPrice
        }

        try await PropertyService.shared.create(
            goalId: goalId,
            address: address.trimmingCharacters(in: .whitespaces),
            price: priceValue,
            link: link.isEmpty ? nil : link.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes
        )
    }

    enum PropertyError: LocalizedError {
        case invalidPrice

        var errorDescription: String? {
            switch self {
            case .invalidPrice:
                return "Please enter a valid price greater than zero."
            }
        }
    }
}
