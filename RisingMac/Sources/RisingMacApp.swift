import SwiftUI

@main
struct RisingMacApp: App {
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarContentView()
        } label: {
            MenuBarLabelView()
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - Menu Bar Label

struct MenuBarLabelView: View {
    @State private var topGoal: Goal?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundStyle(.risingPrimary)

            if let goal = topGoal {
                Text("\(Int(goal.progress * 100))%")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(.risingTextPrimary)
            } else {
                Text("Rising")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.risingTextPrimary)
            }
        }
        .task {
            let goals = await GoalService.shared.fetchAll()
            topGoal = goals.first
        }
    }
}

// MARK: - Menu Bar Content

struct MenuBarContentView: View {
    @State private var goals: [Goal] = []
    @State private var showingDepositSheet = false
    @State private var selectedGoalId: UUID?
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            topGoalSection
            Divider()
            quickAddSection
            Divider()
            openQuitSection
        }
        .task {
            await loadGoals()
        }
        .sheet(isPresented: $showingDepositSheet) {
            if let goalId = selectedGoalId {
                MacDepositSheet(goalId: goalId) {
                    Task { await loadGoals() }
                }
            }
        }
    }

    @ViewBuilder
    private var topGoalSection: some View {
        if let topGoal = goals.first {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: topGoal.iconName)
                        .foregroundStyle(.risingPrimary)
                    Text(topGoal.name)
                        .font(.headline)
                        .foregroundStyle(.risingTextPrimary)
                }

                HStack {
                    Text(formatCurrency(topGoal.currentAmount))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.risingPrimary)
                    Text("/")
                        .foregroundStyle(.risingTextSecondary)
                    Text(formatCurrency(topGoal.targetAmount))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.risingTextSecondary)
                }

                ProgressView(value: topGoal.progress)
                    .tint(.risingPrimary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
        } else {
            Text("No goals — create one in the app")
                .foregroundStyle(.risingTextSecondary)
                .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private var quickAddSection: some View {
        if goals.isEmpty {
            Text("Open the app to get started")
                .foregroundStyle(.risingTextSecondary)
                .padding(.vertical, 4)
        } else {
            Menu {
                ForEach(goals.prefix(5)) { goal in
                    Button {
                        selectedGoalId = goal.id
                        showingDepositSheet = true
                    } label: {
                        Label("Add to \(goal.name)", systemImage: "plus.circle")
                    }
                }
            } label: {
                Label("Quick Add Deposit", systemImage: "plus.circle.fill")
                    .foregroundStyle(.risingPrimary)
            }
        }
    }

    private var openQuitSection: some View {
        Group {
            Button {
                openWindow(id: "main")
            } label: {
                Label("Open Rising", systemImage: "arrow.up.forward.app")
                    .foregroundStyle(.risingTextPrimary)
            }

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Rising", systemImage: "power")
                    .foregroundStyle(.risingError)
            }
        }
    }

    private func loadGoals() async {
        goals = await GoalService.shared.fetchAll()
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
