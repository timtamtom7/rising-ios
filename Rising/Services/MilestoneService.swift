import Foundation

// MARK: - Milestone Service

@MainActor
final class MilestoneService {
    static let shared = MilestoneService()

    private let db = DatabaseService.shared

    private init() {}

    // R5: Uses SQLite via DatabaseService (was in-memory in R2)
    func fetchAll(forGoalId goalId: UUID) async -> [Milestone] {
        do {
            return try db.fetchMilestones(forGoalId: goalId)
        } catch {
            print("MilestoneService.fetchAll error: \(error)")
            return []
        }
    }

    func create(goalId: UUID, title: String, type: MilestoneType, amount: Double?) async throws {
        let milestone = Milestone(goalId: goalId, title: title, type: type, amount: amount)
        try db.insertMilestone(milestone)
    }

    func complete(id: UUID) async throws {
        // ViewModel should use update() directly for milestone toggles
        // This method kept for API compatibility but deprecated
    }

    func reset(id: UUID) async throws {
        // ViewModel should use update() directly for milestone toggles
        // This method kept for API compatibility but deprecated
    }

    func update(_ milestone: Milestone) async throws {
        try db.updateMilestone(milestone)
    }

    func delete(id: UUID) async throws {
        try db.deleteMilestone(id: id)
    }

    func createDefaultMilestones(forGoalId goalId: UUID) async {
        let defaults: [(MilestoneType, String)] = [
            (.preApproval, "Get Pre-Approved"),
            (.saveDownPayment, "Save Down Payment"),
            (.makeOffer, "Make Offer"),
            (.offerAccepted, "Offer Accepted"),
            (.inspection, "Home Inspection"),
            (.closing, "Close")
        ]

        for (type, title) in defaults {
            let milestone = Milestone(goalId: goalId, title: title, type: type)
            try? db.insertMilestone(milestone)
        }
    }
}
