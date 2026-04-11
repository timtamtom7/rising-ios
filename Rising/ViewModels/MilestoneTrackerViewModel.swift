import Foundation

// MARK: - Milestone Tracker View Model

@MainActor
@Observable
final class MilestoneTrackerViewModel {
    var milestones: [Milestone] = []
    var isLoading = false

    let goalId: UUID
    let goal: Goal
    private let milestoneService: MilestoneServiceProtocol

    init(goalId: UUID, goal: Goal, milestoneService: MilestoneServiceProtocol = MilestoneService.shared) {
        self.goalId = goalId
        self.goal = goal
        self.milestoneService = milestoneService
    }

    var completedCount: Int {
        milestones.filter { $0.status == .completed }.count
    }

    var progress: Double {
        guard !milestones.isEmpty else { return 0 }
        return Double(completedCount) / Double(milestones.count)
    }

    var nextMilestone: Milestone? {
        milestones.first { $0.status == .pending }
    }

    func load() async {
        isLoading = true
        milestones = await milestoneService.fetchAll(forGoalId: goalId)

        // Auto-create defaults if empty
        if milestones.isEmpty {
            await milestoneService.createDefaultMilestones(forGoalId: goalId)
            milestones = await milestoneService.fetchAll(forGoalId: goalId)
        }

        isLoading = false
    }

    func toggleComplete(_ milestone: Milestone) async {
        var updated = milestone
        if milestone.status == .completed {
            updated.status = .pending
            updated.completedAt = nil
        } else {
            updated.status = .completed
            updated.completedAt = Date()
        }
        try? await milestoneService.update(updated)
        await load()
    }
}
