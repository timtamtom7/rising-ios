import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let tier: Tier
    var unlockedAt: Date?
    var progress: Double

    enum Tier: String, Codable, CaseIterable {
        case bronze
        case silver
        case gold
        case platinum

        var color: String {
            switch self {
            case .bronze: return "AchievementBronze"
            case .silver: return "AchievementSilver"
            case .gold: return "AchievementGold"
            case .platinum: return "AchievementPlatinum"
            }
        }
    }

    var isUnlocked: Bool {
        unlockedAt != nil
    }

    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id && lhs.unlockedAt == rhs.unlockedAt && lhs.progress == rhs.progress
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_deposit", title: "First Step", description: "Make your first deposit", icon: "star.fill", tier: .bronze, progress: 0),
        Achievement(id: "deposit_100", title: "Century Club", description: "Save $100 total across all goals", icon: "dollarsign.circle.fill", tier: .bronze, progress: 0),
        Achievement(id: "deposit_1000", title: "Grand Saver", description: "Save $1,000 total across all goals", icon: "banknote.fill", tier: .silver, progress: 0),
        Achievement(id: "deposit_10000", title: "Ten Grand", description: "Save $10,000 total across all goals", icon: "chart.line.uptrend.xyaxis", tier: .gold, progress: 0),
        Achievement(id: "first_goal_complete", title: "Goal Getter", description: "Complete your first savings goal", icon: "checkmark.seal.fill", tier: .bronze, progress: 0),
        Achievement(id: "on_track", title: "On Track", description: "Reach 50% of any goal", icon: "flag.fill", tier: .bronze, progress: 0),
        Achievement(id: "almost_there", title: "Almost There", description: "Reach 90% of any goal", icon: "target", tier: .silver, progress: 0),
        Achievement(id: "streak_3", title: "Consistent", description: "Make deposits 3 months in a row", icon: "flame.fill", tier: .silver, progress: 0),
        Achievement(id: "streak_6", title: "Unstoppable", description: "Make deposits 6 months in a row", icon: "bolt.fill", tier: .gold, progress: 0),
        Achievement(id: "early_bird", title: "Early Bird", description: "Complete a goal before the deadline", icon: "clock.fill", tier: .silver, progress: 0),
        Achievement(id: "three_goals", title: "Diversified", description: "Have 3 active goals at once", icon: "square.stack.3d.up.fill", tier: .bronze, progress: 0),
        Achievement(id: "community_joined", title: "Community", description: "Join the Rising community", icon: "person.3.fill", tier: .bronze, progress: 0),
        Achievement(id: "shared_goal", title: "Sharing Is Caring", description: "Share your first goal", icon: "square.and.arrow.up.fill", tier: .bronze, progress: 0),
        Achievement(id: "premium_sub", title: "Premium Member", description: "Subscribe to Rising Premium", icon: "crown.fill", tier: .gold, progress: 0)
    ]
}
