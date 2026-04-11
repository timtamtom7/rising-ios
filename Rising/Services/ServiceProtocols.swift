import Foundation

/// Protocol for goal-related operations.
protocol GoalServiceProtocol: Sendable {
    /// Fetches all goals.
    func fetchAll() async -> [Goal]
    /// Creates a new goal.
    func create(name: String, targetAmount: Double, deadline: Date?, iconName: String, description: String?) async throws
    /// Updates an existing goal.
    func update(_ goal: Goal) async throws
    /// Deletes a goal by its ID.
    func delete(id: UUID) async throws
    /// Adds a deposit to a goal, updating the goal's current amount.
    func addDeposit(goalId: UUID, amount: Double) async throws
}

/// Protocol for deposit-related operations.
protocol DepositServiceProtocol: Sendable {
    /// Fetches all deposits for a specific goal.
    func fetchAll(forGoalId goalId: UUID) async -> [Deposit]
    /// Fetches all deposits across all goals.
    func fetchAll() async -> [Deposit]
    /// Creates a new deposit for a goal.
    func create(goalId: UUID, amount: Double, date: Date, note: String?) async throws
    /// Deletes a deposit by its ID.
    func delete(id: UUID) async throws
}

/// Protocol for property-related operations.
protocol PropertyServiceProtocol: Sendable {
    /// Fetches all properties for a specific goal.
    func fetchAll(forGoalId goalId: UUID) async -> [Property]
    /// Creates a new property for a goal.
    func create(goalId: UUID, address: String, price: Double, link: String?, notes: String?) async throws
    /// Updates an existing property.
    func update(_ property: Property) async throws
    /// Deletes a property by its ID.
    func delete(id: UUID) async throws
}

/// Protocol for agent-related operations.
protocol AgentServiceProtocol: Sendable {
    /// Fetches all agents.
    func fetchAll() async -> [Agent]
    /// Creates a new agent.
    func create(name: String, phone: String?, email: String?, notes: String?) async throws
    /// Updates an existing agent.
    func update(_ agent: Agent) async throws
    /// Deletes an agent by its ID.
    func delete(id: UUID) async throws
}

/// Protocol for milestone-related operations.
protocol MilestoneServiceProtocol: Sendable {
    /// Fetches all milestones for a specific goal.
    func fetchAll(forGoalId goalId: UUID) async -> [Milestone]
    /// Creates a new milestone for a goal.
    func create(goalId: UUID, title: String, type: MilestoneType, amount: Double?) async throws
    /// Updates an existing milestone.
    func update(_ milestone: Milestone) async throws
    /// Deletes a milestone by its ID.
    func delete(id: UUID) async throws
    /// Creates default milestones for a goal.
    func createDefaultMilestones(forGoalId goalId: UUID) async
}

extension GoalService: GoalServiceProtocol {}
extension DepositService: DepositServiceProtocol {}
extension PropertyService: PropertyServiceProtocol {}
extension AgentService: AgentServiceProtocol {}
extension MilestoneService: MilestoneServiceProtocol {}
