import Foundation

// MARK: - Add Deposit View Model

@MainActor
@Observable
final class AddDepositViewModel {
    var amount = ""
    var date = Date()
    var note = ""

    let goalId: UUID

    var isValid: Bool {
        guard let value = Double(amount) else { return false }
        return value > 0
    }

    init(goalId: UUID) {
        self.goalId = goalId
    }

    func save() async throws {
        guard let depositAmount = Double(amount) else {
            throw DepositError.invalidAmount
        }

        try await DepositService.shared.create(
            goalId: goalId,
            amount: depositAmount,
            date: date,
            note: note.isEmpty ? nil : note
        )
    }

    enum DepositError: LocalizedError {
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Please enter a valid amount greater than zero."
            }
        }
    }
}
