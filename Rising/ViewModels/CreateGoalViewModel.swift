import Foundation

// MARK: - Create Goal View Model

@MainActor
@Observable
final class CreateGoalViewModel {
    var name = ""
    var targetAmount = ""
    var deadline: Date = Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date()
    var hasDeadline = false
    var description = ""
    var selectedIcon = "target"

    let iconOptions = [
        "target", "house", "car", "airplane", "gift",
        "graduationcap", "heart", "star", "bag", "creditcard"
    ]

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(targetAmount) ?? 0) > 0
    }

    func save() async throws {
        guard let amount = Double(targetAmount), amount > 0 else {
            throw GoalError.invalidAmount
        }

        try await GoalService.shared.create(
            name: name.trimmingCharacters(in: .whitespaces),
            targetAmount: amount,
            deadline: hasDeadline ? deadline : nil,
            iconName: selectedIcon,
            description: description.isEmpty ? nil : description
        )
    }

    enum GoalError: LocalizedError {
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Please enter a valid target amount greater than zero."
            }
        }
    }
}
