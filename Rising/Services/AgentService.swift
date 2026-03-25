import Foundation

// MARK: - Agent Service

@MainActor
final class AgentService {
    static let shared = AgentService()

    private let db = DatabaseService.shared

    private init() {}

    // R5: Uses SQLite via DatabaseService (was in-memory in R2)
    func fetchAll() async -> [Agent] {
        do {
            return try db.fetchAllAgents()
        } catch {
            print("AgentService.fetchAll error: \(error)")
            return []
        }
    }

    func create(name: String, phone: String?, email: String?, notes: String?) async throws {
        let agent = Agent(name: name, phone: phone, email: email, notes: notes)
        try db.insertAgent(agent)
    }

    func update(_ agent: Agent) async throws {
        try db.updateAgent(agent)
    }

    func delete(id: UUID) async throws {
        try db.deleteAgent(id: id)
    }
}
