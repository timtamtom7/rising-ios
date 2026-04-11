import Foundation

// MARK: - Goal Model

/// Represents a savings goal for purchasing a property.
struct Goal: Identifiable, Codable, Equatable {
    /// Unique identifier for the goal.
    let id: UUID
    /// Display name for the goal.
    var name: String
    /// Target amount to save in dollars.
    var targetAmount: Double
    /// Current amount saved in dollars.
    var currentAmount: Double
    /// Optional deadline for achieving the goal.
    var deadline: Date?
    /// Date when the goal was created.
    var createdAt: Date
    /// SF Symbol name for the goal's icon.
    var iconName: String
    /// Optional detailed description of the goal.
    var description: String?

    /// Progress toward the goal as a percentage (0.0 to 1.0).
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    /// Amount remaining to reach the target (never negative).
    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }

    /// Number of days until the deadline, or nil if no deadline is set.
    var daysRemaining: Int? {
        guard let deadline = deadline else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day
    }

    /// Whether the goal has been achieved (currentAmount >= targetAmount).
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    /// Creates a new savings goal.
    /// - Parameters:
    ///   - name: Display name for the goal.
    ///   - targetAmount: Target amount to save in dollars.
    ///   - deadline: Optional deadline for achieving the goal.
    ///   - iconName: SF Symbol name for the goal's icon.
    ///   - description: Optional detailed description.
    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        deadline: Date? = nil,
        createdAt: Date = Date(),
        iconName: String = "target",
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.createdAt = createdAt
        self.iconName = iconName
        self.description = description
    }
}
