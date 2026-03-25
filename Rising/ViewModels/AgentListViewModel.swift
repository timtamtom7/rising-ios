import Foundation

// MARK: - Agent List View Model

@MainActor
@Observable
final class AgentListViewModel {
    var agents: [Agent] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        agents = await AgentService.shared.fetchAll()
        isLoading = false
    }

    func delete(_ agent: Agent) async {
        do {
            try await AgentService.shared.delete(id: agent.id)
            agents.removeAll { $0.id == agent.id }
        } catch {
            errorMessage = "Failed to delete agent."
        }
    }
}
