import SwiftUI
import UniformTypeIdentifiers

struct MacSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("depositReminders") private var depositReminders = true
    @State private var showingExportSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    notificationsSection
                    dataSection
                    aboutSection
                }
                .padding(24)
            }
        }
        .frame(width: 480, height: 420)
        .background(Color(hex: "1E293B"))
    }

    private var header: some View {
        HStack {
            Image(systemName: "gear")
                .foregroundStyle(.risingPrimary)
            Text("Settings")
                .font(.headline)
                .foregroundStyle(.risingTextPrimary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.risingTextSecondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.headline)
                .foregroundStyle(.risingTextPrimary)

            VStack(spacing: 0) {
                settingsRow(
                    title: "Enable Notifications",
                    subtitle: "Receive reminders and milestone alerts",
                    toggle: $notificationsEnabled
                )

                Divider()
                    .background(Color(hex: "334155"))

                settingsRow(
                    title: "Deposit Reminders",
                    subtitle: "Get reminded to log your savings",
                    toggle: $depositReminders
                )
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1 : 0.5)
            }
            .background(Color(hex: "334155"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func settingsRow(title: String, subtitle: String, toggle: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.risingTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.risingTextSecondary)
            }
            Spacer()
            Toggle("", isOn: toggle)
                .toggleStyle(.switch)
                .tint(.risingPrimary)
                .labelsHidden()
        }
        .padding(14)
    }

    // MARK: - Data Section

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.headline)
                .foregroundStyle(.risingTextPrimary)

            VStack(spacing: 0) {
                Button {
                    exportData()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.risingPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Export Data")
                                .font(.body)
                                .foregroundStyle(.risingTextPrimary)
                            Text("Download all your goals and deposits as JSON")
                                .font(.caption)
                                .foregroundStyle(.risingTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.risingTextSecondary)
                    }
                    .padding(14)
                }
                .buttonStyle(.plain)
            }
            .background(Color(hex: "334155"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                Group {
                    if showingExportSuccess {
                        Text("✓ Exported!")
                            .font(.caption)
                            .foregroundStyle(.risingPrimary)
                            .padding(.trailing, 14)
                    }
                },
                alignment: .trailing
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
                .foregroundStyle(.risingTextPrimary)

            VStack(spacing: 0) {
                aboutRow(title: "Version", value: "1.0.0")
                Divider().background(Color(hex: "334155"))
                aboutRow(title: "Built with", value: "SwiftUI + Charts")
                Divider().background(Color(hex: "334155"))
                aboutRow(title: "Platform", value: "macOS 15+")
            }
            .background(Color(hex: "334155"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundStyle(.risingTextPrimary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(.risingTextSecondary)
        }
        .padding(14)
    }

    // MARK: - Actions

    private func exportData() {
        Task {
            let goals = await GoalService.shared.fetchAll()
            var allDeposits: [Deposit] = []
            for goal in goals {
                let deps = await DepositService.shared.fetchAll(forGoalId: goal.id)
                allDeposits.append(contentsOf: deps)
            }

            let exportData: [String: Any] = [
                "exportDate": ISO8601DateFormatter().string(from: Date()),
                "goals": goals.map { goal -> [String: Any] in
                    [
                        "id": goal.id.uuidString,
                        "name": goal.name,
                        "targetAmount": goal.targetAmount,
                        "currentAmount": goal.currentAmount,
                        "deadline": goal.deadline?.ISO8601Format() ?? "",
                        "createdAt": goal.createdAt.ISO8601Format(),
                        "iconName": goal.iconName,
                        "description": goal.description ?? ""
                    ]
                },
                "deposits": allDeposits.map { dep -> [String: Any] in
                    [
                        "id": dep.id.uuidString,
                        "goalId": dep.goalId.uuidString,
                        "amount": dep.amount,
                        "date": dep.date.ISO8601Format(),
                        "note": dep.note ?? ""
                    ]
                }
            ]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("RisingExport.json")
                try jsonData.write(to: tempURL)

                let panel = NSSavePanel()
                panel.nameFieldStringValue = "RisingExport.json"
                panel.allowedContentTypes = [UTType.json]
                panel.canCreateDirectories = true

                if panel.runModal() == .OK, let url = panel.url {
                    try jsonData.write(to: url)
                    showingExportSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingExportSuccess = false
                    }
                }
            } catch {
                print("Export error: \(error)")
            }
        }
    }
}
