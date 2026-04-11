import Foundation

// MARK: - Agent Model (R2)

/// Represents a real estate agent.
struct Agent: Identifiable, Codable, Equatable {
    /// Unique identifier for the agent.
    let id: UUID
    /// Full name of the agent.
    var name: String
    /// Phone number of the agent.
    var phone: String?
    /// Email address of the agent.
    var email: String?
    /// Optional notes about the agent.
    var notes: String?
    /// Date when the agent was added.
    var createdAt: Date

    /// Creates a new agent.
    /// - Parameters:
    ///   - name: Full name of the agent.
    ///   - phone: Phone number of the agent.
    ///   - email: Email address of the agent.
    ///   - notes: Optional notes about the agent.
    init(
        id: UUID = UUID(),
        name: String,
        phone: String? = nil,
        email: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.notes = notes
        self.createdAt = createdAt
    }
}
