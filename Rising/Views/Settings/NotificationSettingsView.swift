import SwiftUI

// MARK: - Notification Settings View

struct NotificationSettingsView: View {
    @State private var notificationsEnabled = false
    @State private var depositReminders = true
    @State private var goalProgress = true
    @State private var milestoneReminders = true
    @State private var weeklySummary = false
    @State private var showAuthAlert = false
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: RisingSpacing.lg) {
            // Master Toggle
            Toggle(isOn: $notificationsEnabled) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(notificationsEnabled ? Color.risingPrimary : Color.risingTextSecondaryDark)
                    Text("Enable Notifications")
                        .risingBody()
                        .foregroundStyle(Color.risingTextPrimaryDark)
                }
            }
            .tint(Color.risingPrimary)
            .padding(RisingSpacing.md)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
            .onChange(of: notificationsEnabled) { _, newValue in
                if newValue {
                    requestAuth()
                } else {
                    NotificationService.shared.cancelAllNotifications()
                }
            }

            if notificationsEnabled {
                // Notification Types
                VStack(spacing: RisingSpacing.sm) {
                    NotificationToggle(
                        title: "Deposit Reminders",
                        subtitle: "Weekly reminder to add deposits",
                        icon: "banknote",
                        isOn: $depositReminders
                    )

                    NotificationToggle(
                        title: "Goal Progress",
                        subtitle: "Updates when you hit milestones",
                        icon: "chart.line.uptrend.xyaxis",
                        isOn: $goalProgress
                    )

                    NotificationToggle(
                        title: "Milestone Reminders",
                        subtitle: "Follow-up reminders for open milestones",
                        icon: "flag.checkered",
                        isOn: $milestoneReminders
                    )

                    NotificationToggle(
                        title: "Weekly Summary",
                        subtitle: "Your weekly savings summary",
                        icon: "calendar",
                        isOn: $weeklySummary
                    )
                }
            }

            Spacer()
        }
        .padding(RisingSpacing.lg)
        .onAppear {
            checkAuthStatus()
        }
        .alert("Enable Notifications", isPresented: $showAuthAlert) {
            Button("Cancel", role: .cancel) {
                notificationsEnabled = false
            }
            Button("Enable") {
                Task { await requestAuth() }
            }
        } message: {
            Text("Rising needs notification permission to remind you about your savings goals. You can change this anytime in Settings.")
        }
    }

    private func checkAuthStatus() {
        Task {
            notificationsEnabled = await NotificationService.shared.checkAuthorization()
        }
    }

    private func requestAuth() {
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            notificationsEnabled = granted
            if !granted {
                showAuthAlert = true
            }
        }
    }
}

// MARK: - Notification Toggle Row

struct NotificationToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.risingPrimary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .risingBody()
                    .foregroundStyle(Color.risingTextPrimaryDark)

                Text(subtitle)
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color.risingPrimary)
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
    }
}

#Preview {
    NotificationSettingsView()
        .background(Color.risingBackgroundDark)
}
