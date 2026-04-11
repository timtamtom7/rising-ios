import Foundation

// MARK: - Add Deposit View Model

@MainActor
@Observable
final class AddDepositViewModel {
    var amount = ""
    var date = Date()
    var note = ""

    let goalId: UUID
    private let depositService: DepositServiceProtocol

    init(goalId: UUID, depositService: DepositServiceProtocol = DepositService.shared) {
        self.goalId = goalId
        self.depositService = depositService
    }

    var isValid: Bool {
        guard let value = Double(amount) else { return false }
        return value > 0
    }

    func save() async throws {
        guard let depositAmount = Double(amount) else {
            throw DepositError.invalidAmount
        }

        try await depositService.create(
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
