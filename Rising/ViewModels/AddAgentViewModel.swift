import Foundation

// MARK: - Add Agent View Model

@MainActor
@Observable
final class AddAgentViewModel {
    var name = ""
    var phone = ""
    var email = ""
    var notes = ""

    private let agentService: AgentServiceProtocol

    init(agentService: AgentServiceProtocol = AgentService.shared) {
        self.agentService = agentService
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save() async throws {
        try await agentService.create(
            name: name.trimmingCharacters(in: .whitespaces),
            phone: phone.isEmpty ? nil : phone.trimmingCharacters(in: .whitespaces),
            email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes
        )
    }
}
