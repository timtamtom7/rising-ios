import Foundation

// MARK: - Agent Model (R2)

struct Agent: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var phone: String?
    var email: String?
    var notes: String?
    var createdAt: Date

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
