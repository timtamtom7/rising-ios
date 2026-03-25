import Foundation

// MARK: - Add Agent View Model

@MainActor
@Observable
final class AddAgentViewModel {
    var name = ""
    var phone = ""
    var email = ""
    var notes = ""

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save() async throws {
        try await AgentService.shared.create(
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces),
            email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes
        )
    }
}
