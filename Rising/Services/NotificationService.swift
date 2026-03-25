import Foundation
import UserNotifications

// MARK: - Notification Service

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    enum NotificationType: String, CaseIterable {
        case depositReminder = "deposit_reminder"
        case goalProgress = "goal_progress"
        case milestoneCompleted = "milestone_completed"
        case deadlineApproaching = "deadline_approaching"
        case weeklySummary = "weekly_summary"

        var title: String {
            switch self {
            case .depositReminder: return "Time to save!"
            case .goalProgress: return "Goal Update"
            case .milestoneCompleted: return "Milestone Reached!"
            case .deadlineApproaching: return "Deadline Approaching"
            case .weeklySummary: return "Weekly Summary"
            }
        }

        var body: String {
            switch self {
            case .depositReminder: return "Add a deposit to keep your goal on track!"
            case .goalProgress: return "You're making great progress toward your goal."
            case .milestoneCompleted: return "You completed a milestone. Keep going!"
            case .deadlineApproaching: return "Your goal deadline is coming up. Are you on track?"
            case .weeklySummary: return "Here's your weekly savings summary."
            }
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorization() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func scheduleDepositReminder(goalName: String, goalId: UUID) async {
        guard await checkAuthorization() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to save!"
        content.body = "Add a deposit toward your \(goalName) goal today."
        content.sound = .default
        content.categoryIdentifier = "DEPOSIT_REMINDER"
        content.userInfo = ["goalId": goalId.uuidString]

        // Schedule for 7 days from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7 * 24 * 60 * 60, repeats: true)

        let request = UNNotificationRequest(
            identifier: "deposit_reminder_\(goalId.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule deposit reminder: \(error)")
        }
    }

    func scheduleGoalProgressNotification(goal: Goal) async {
        guard await checkAuthorization() else { return }

        let percent = Int(goal.progress * 100)
        guard percent > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Goal Update"
        content.body = "You're \(percent)% toward your \(goal.name). Keep it up!"
        content.sound = .default
        content.categoryIdentifier = "GOAL_PROGRESS"
        content.userInfo = ["goalId": goal.id.uuidString]

        // One-time notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "goal_progress_\(goal.id.uuidString)_\(percent)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule progress notification: \(error)")
        }
    }

    func scheduleMilestoneReminder(goalName: String, milestoneTitle: String, goalId: UUID) async {
        guard await checkAuthorization() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Follow up on \(milestoneTitle)"
        content.body = "Time to check in on your \(goalName) progress."
        content.sound = .default
        content.categoryIdentifier = "MILESTONE_REMINDER"
        content.userInfo = ["goalId": goalId.uuidString]

        // Schedule for 3 days from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: false)

        let request = UNNotificationRequest(
            identifier: "milestone_reminder_\(goalId.uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule milestone reminder: \(error)")
        }
    }

    func cancelNotifications(forGoalId goalId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                "deposit_reminder_\(goalId.uuidString)",
                "milestone_reminder_\(goalId.uuidString)"
            ]
        )
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
