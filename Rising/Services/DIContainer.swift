import Foundation

/// Dependency injection container providing access to all app services.
/// Use `DIContainer.shared` to access service instances.
@MainActor
final class DIContainer {
    /// Shared singleton instance.
    static let shared = DIContainer()

    /// Service for goal-related operations.
    let goalService: GoalServiceProtocol = GoalService.shared
    /// Service for deposit-related operations.
    let depositService: DepositServiceProtocol = DepositService.shared
    /// Service for property-related operations.
    let propertyService: PropertyServiceProtocol = PropertyService.shared
    /// Service for agent-related operations.
    let agentService: AgentServiceProtocol = AgentService.shared
    /// Service for milestone-related operations.
    let milestoneService: MilestoneServiceProtocol = MilestoneService.shared

    private init() {}
}
