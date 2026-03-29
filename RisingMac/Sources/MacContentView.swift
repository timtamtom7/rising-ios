import SwiftUI

struct MacContentView: View {
    @State private var viewModel = MacDashboardViewModel()
    @State private var selectedGoal: Goal?
    @State private var selectedTab: MacTab = .goals
    @State private var showingAddGoal = false
    @State private var showingStats = false
    @State private var showingSettings = false

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .frame(minWidth: 800, minHeight: 500)
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $showingAddGoal) {
            MacCreateGoalView { goal in
                Task {
                    await viewModel.load()
                }
            }
        }
        .sheet(isPresented: $showingStats) {
            MacStatsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            MacSettingsView()
        }
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: $selectedGoal) {
            Section("Tabs") {
                Button {
                    selectedTab = .goals
                } label: {
                    Label("Goals", systemImage: "target")
                }
                .buttonStyle(.plain)
                .foregroundStyle(selectedTab == .goals ? .risingPrimary : .risingTextSecondary)
                .padding(.vertical, 4)

                Button {
                    showingStats = true
                } label: {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.risingTextSecondary)
                .padding(.vertical, 4)

                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.risingTextSecondary)
                .padding(.vertical, 4)
            }

            if selectedTab == .goals {
                Section("Your Goals") {
                    if viewModel.goals.isEmpty {
                        Text("No goals yet")
                            .foregroundStyle(.risingTextSecondary)
                            .font(.caption)
                    } else {
                        ForEach(viewModel.goals) { goal in
                            Button {
                                selectedGoal = goal
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: goal.iconName)
                                        .foregroundStyle(.risingPrimary)
                                        .frame(width: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(goal.name)
                                            .font(.body)
                                            .foregroundStyle(.risingTextPrimary)
                                        Text(formatCurrency(goal.currentAmount))
                                            .font(.caption)
                                            .foregroundStyle(.risingTextSecondary)
                                    }

                                    Spacer()

                                    Text("\(Int(goal.progress * 100))%")
                                        .font(.caption)
                                        .foregroundStyle(.risingPrimary)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Label("Add Goal", systemImage: "plus.circle.fill")
                            .foregroundStyle(.risingPrimary)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 220)
        .background(Color(hex: "1E293B"))
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailContent: some View {
        if let goal = selectedGoal {
            MacGoalDetailView(goal: goal, onGoalUpdated: {
                Task { await viewModel.load() }
            })
        } else {
            emptyDetailView
        }
    }

    private var emptyDetailView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 56))
                .foregroundStyle(.risingPrimary.opacity(0.4))

            Text("Select a goal to view details")
                .font(.title2)
                .foregroundStyle(.risingTextSecondary)

            Text("Or create a new goal to start tracking your savings")
                .font(.body)
                .foregroundStyle(.risingTextSecondary.opacity(0.7))

            Button {
                showingAddGoal = true
            } label: {
                Label("Create First Goal", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "10B981"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0F172A"))
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Mac Tab

enum MacTab {
    case goals
    case stats
}

// MARK: - Dashboard ViewModel

@MainActor
@Observable
final class MacDashboardViewModel {
    var goals: [Goal] = []
    var isLoading = false
    var errorMessage: String?

    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    var totalTarget: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }

    var overallProgress: Double {
        guard totalTarget > 0 else { return 0 }
        return totalSaved / totalTarget
    }

    var isEmpty: Bool { goals.isEmpty }

    func load() async {
        isLoading = true
        do {
            goals = await GoalService.shared.fetchAll()
        } catch {
            errorMessage = "Failed to load goals."
        }
        isLoading = false
    }

    func deleteGoal(_ goal: Goal) async {
        do {
            try await GoalService.shared.delete(id: goal.id)
            goals.removeAll { $0.id == goal.id }
        } catch {
            errorMessage = "Failed to delete goal."
        }
    }
}

// MARK: - Create Goal View

struct MacCreateGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var targetAmount = ""
    @State private var deadline = Date()
    @State private var hasDeadline = false
    @State private var iconName = "target"
    @State private var description = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let onCreated: (Goal) -> Void

    private let iconOptions = ["target", "house.fill", "car.fill", "airplane", "graduationcap.fill", "heart.fill", "bag.fill", "creditcard.fill"]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    nameSection
                    amountSection
                    deadlineSection
                    iconSection
                    descriptionSection
                }
                .padding(24)
            }
            Divider()
            footer
        }
        .frame(width: 500, height: 560)
        .background(Color(hex: "1E293B"))
    }

    private var header: some View {
        HStack {
            Text("New Savings Goal")
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

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Goal Name")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            TextField("e.g. House Down Payment", text: $name)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(hex: "334155"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.risingTextPrimary)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Target Amount")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            HStack {
                Text("$")
                    .foregroundStyle(.risingTextSecondary)
                    .padding(.leading, 12)
                TextField("50000", text: $targetAmount)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.risingTextPrimary)
            }
            .padding(12)
            .background(Color(hex: "334155"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("Set a deadline", isOn: $hasDeadline)
                .toggleStyle(.switch)
                .foregroundStyle(.risingTextSecondary)
                .tint(.risingPrimary)

            if hasDeadline {
                DatePicker("", selection: $deadline, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.risingPrimary)
                    .padding(8)
                    .background(Color(hex: "334155"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Icon")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        iconName = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(iconName == icon ? .white : .risingTextSecondary)
                            .frame(width: 36, height: 36)
                            .background(iconName == icon ? Color(hex: "10B981") : Color(hex: "334155"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description (optional)")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            TextField("What are you saving for?", text: $description, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(2...4)
                .padding(12)
                .background(Color(hex: "334155"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.risingTextPrimary)
        }
    }

    private var footer: some View {
        HStack {
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.risingError)
            }
            Spacer()
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.risingTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Button {
                save()
            } label: {
                if isSaving {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Create Goal")
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(hex: "10B981"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(isSaving || name.isEmpty || targetAmount.isEmpty)
        }
        .padding(20)
    }

    private func save() {
        guard let amount = Double(targetAmount), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await GoalService.shared.create(
                    name: name,
                    targetAmount: amount,
                    deadline: hasDeadline ? deadline : nil,
                    iconName: iconName,
                    description: description.isEmpty ? nil : description
                )
                dismiss()
            } catch {
                errorMessage = "Failed to create goal."
                isSaving = false
            }
        }
    }
}
