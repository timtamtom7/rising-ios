import Foundation

@MainActor
@Observable
final class AchievementService {
    static let shared = AchievementService()

    private(set) var achievements: [Achievement] = []
    private let userDefaults = UserDefaults.standard
    private let storageKey = "AchievementService.achievements"

    private init() {
        loadAchievements()
    }

    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }.sorted { ($0.unlockedAt ?? .distantPast) > ($1.unlockedAt ?? .distantPast) }
    }

    var recentAchievements: [Achievement] {
        Array(unlockedAchievements.prefix(3))
    }

    var unlockedCount: Int { unlockedAchievements.count }
    var totalCount: Int { achievements.count }

    func checkAndUpdate(deposits: [Deposit], goals: [Goal], hasJoinedCommunity: Bool, isSubscribed: Bool) {
        let totalSaved = goals.reduce(0) { $0 + $1.currentAmount }
        let activeGoalCount = goals.count

        for i in achievements.indices {
            var updated = false

            switch achievements[i].id {
            case "first_deposit":
                if deposits.count >= 1 && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }

            case "deposit_100":
                if totalSaved >= 100 && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                achievements[i].progress = min(totalSaved / 100, 1.0)

            case "deposit_1000":
                if totalSaved >= 1_000 && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                achievements[i].progress = min(totalSaved / 1_000, 1.0)

            case "deposit_10000":
                if totalSaved >= 10_000 && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                achievements[i].progress = min(totalSaved / 10_000, 1.0)

            case "first_goal_complete":
                if goals.contains(where: { $0.currentAmount >= $0.targetAmount }) && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }

            case "on_track":
                if goals.contains(where: { $0.targetAmount > 0 && ($0.currentAmount / $0.targetAmount) >= 0.5 }) && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                let maxProgress = goals.map { min(($0.currentAmount / max($0.targetAmount, 1)), 1.0) }.max() ?? 0
                achievements[i].progress = maxProgress

            case "almost_there":
                if goals.contains(where: { $0.targetAmount > 0 && ($0.currentAmount / $0.targetAmount) >= 0.9 }) && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                let maxProgress = goals.map { min(($0.currentAmount / max($0.targetAmount, 1)), 1.0) }.max() ?? 0
                achievements[i].progress = maxProgress

            case "streak_3", "streak_6":
                let streak = calculateDepositStreak(deposits)
                let target = achievements[i].id == "streak_3" ? 3 : 6
                if achievements[i].unlockedAt == nil && streak >= target {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                achievements[i].progress = min(Double(streak) / Double(target), 1.0)

            case "early_bird":
                if goals.contains(where: { goal in
                    guard let deadline = goal.deadline else { return false }
                    return goal.currentAmount >= goal.targetAmount && Date() < deadline
                }) && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }

            case "three_goals":
                if activeGoalCount >= 3 && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }
                achievements[i].progress = min(Double(activeGoalCount) / 3.0, 1.0)

            case "community_joined":
                if hasJoinedCommunity && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }

            case "premium_sub":
                if isSubscribed && achievements[i].unlockedAt == nil {
                    achievements[i].unlockedAt = Date()
                    updated = true
                }

            default:
                break
            }

            if updated {
                saveAchievements()
            }
        }
    }

    private func calculateDepositStreak(_ deposits: [Deposit]) -> Int {
        let calendar = Calendar.current
        let sortedDates = deposits.map { calendar.startOfDay(for: $0.date) }.sorted(by: >)
        guard !sortedDates.isEmpty else { return 0 }

        var streak = 1
        var currentMonth = calendar.component(.month, from: sortedDates[0])
        var currentYear = calendar.component(.year, from: sortedDates[0])

        for i in 1..<sortedDates.count {
            let month = calendar.component(.month, from: sortedDates[i])
            let year = calendar.component(.year, from: sortedDates[i])

            let monthsDiff = (currentYear - year) * 12 + (currentMonth - month)
            if monthsDiff == 1 {
                streak += 1
                currentMonth = month
                currentYear = year
            } else if monthsDiff > 1 {
                break
            }
        }

        return streak
    }

    private func loadAchievements() {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = Achievement.allAchievements
        }
    }

    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }

    func resetAll() {
        achievements = Achievement.allAchievements
        saveAchievements()
    }
}
