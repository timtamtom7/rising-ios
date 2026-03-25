import Foundation

// MARK: - Milestone Service

@MainActor
final class MilestoneService {
    static let shared = MilestoneService()

    private init() {}

    func fetchAll(forGoalId goalId: UUID) async -> [Milestone] {
        return MilestoneStorage.shared.milestones(forGoalId: goalId)
    }

    func create(goalId: UUID, title: String, type: MilestoneType, amount: Double?) async throws {
        let milestone = Milestone(goalId: goalId, title: title, type: type, amount: amount)
        MilestoneStorage.shared.add(milestone)
    }

    func complete(id: UUID) async throws {
        MilestoneStorage.shared.complete(id: id)
    }

    func reset(id: UUID) async throws {
        MilestoneStorage.shared.reset(id: id)
    }

    func delete(id: UUID) async throws {
        MilestoneStorage.shared.delete(id: id)
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
            MilestoneStorage.shared.add(milestone)
        }
    }
}

// MARK: - In-Memory Storage (R2)

@MainActor
final class MilestoneStorage {
    static let shared = MilestoneStorage()

    private var _milestones: [Milestone] = []

    private init() {}

    func milestones(forGoalId goalId: UUID) -> [Milestone] {
        _milestones.filter { $0.goalId == goalId }.sorted { $0.type.sortOrder < $1.type.sortOrder }
    }

    func add(_ milestone: Milestone) {
        _milestones.append(milestone)
    }

    func complete(id: UUID) {
        if let index = _milestones.firstIndex(where: { $0.id == id }) {
            _milestones[index].status = .completed
            _milestones[index].completedAt = Date()
        }
    }

    func reset(id: UUID) {
        if let index = _milestones.firstIndex(where: { $0.id == id }) {
            _milestones[index].status = .pending
            _milestones[index].completedAt = nil
        }
    }

    func delete(id: UUID) {
        _milestones.removeAll { $0.id == id }
    }
}
