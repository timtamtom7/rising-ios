import Foundation

// MARK: - Agent List View Model

@MainActor
@Observable
final class AgentListViewModel {
    var agents: [Agent] = []
    var isLoading = false
    var errorMessage: String?

    private let agentService: AgentServiceProtocol

    init(agentService: AgentServiceProtocol = AgentService.shared) {
        self.agentService = agentService
    }

    func load() async {
        isLoading = true
        agents = await agentService.fetchAll()
        isLoading = false
    }

    func delete(_ agent: Agent) async {
        do {
            try await agentService.delete(id: agent.id)
            agents.removeAll { $0.id == agent.id }
        } catch {
            errorMessage = "Failed to delete agent."
        }
    }
}
