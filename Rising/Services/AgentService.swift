import Foundation

// MARK: - Agent Service

@MainActor
final class AgentService {
    static let shared = AgentService()

    private init() {}

    func fetchAll() async -> [Agent] {
        return AgentStorage.shared.agents
    }

    func create(name: String, phone: String?, email: String?, notes: String?) async throws {
        let agent = Agent(name: name, phone: phone, email: email, notes: notes)
        AgentStorage.shared.add(agent)
    }

    func update(_ agent: Agent) async throws {
        AgentStorage.shared.update(agent)
    }

    func delete(id: UUID) async throws {
        AgentStorage.shared.delete(id: id)
    }
}

// MARK: - In-Memory Storage (R2)

@MainActor
final class AgentStorage {
    static let shared = AgentStorage()

    private var _agents: [Agent] = []

    var agents: [Agent] { _agents }

    private init() {}

    func add(_ agent: Agent) {
        _agents.append(agent)
    }

    func update(_ agent: Agent) {
        if let index = _agents.firstIndex(where: { $0.id == agent.id }) {
            _agents[index] = agent
        }
    }

    func delete(id: UUID) {
        _agents.removeAll { $0.id == id }
    }
}
