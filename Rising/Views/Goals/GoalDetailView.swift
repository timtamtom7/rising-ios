import SwiftUI

struct GoalDetailView: View {
    @State private var viewModel: GoalDetailViewModel
    @State private var showAddDeposit = false
    @State private var showEditGoal = false
    @State private var showPropertyList = false
    @State private var showMilestones = false
    @State private var showAgents = false

    init(goal: Goal) {
        _viewModel = State(initialValue: GoalDetailViewModel(goal: goal))
    }

    var body: some View {
        ZStack {
            Color.risingBackgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: RisingSpacing.lg) {
                    // Progress Header
                    progressHeader
                        .padding(.horizontal, RisingSpacing.md)

                    // Quick Actions
                    quickActions
                        .padding(.horizontal, RisingSpacing.md)

                    // Milestones Section
                    milestonesSection
                        .padding(.horizontal, RisingSpacing.md)

                    // Charts Section
                    chartsSection
                        .padding(.horizontal, RisingSpacing.md)

                    // Properties Section
                    propertiesSection
                        .padding(.horizontal, RisingSpacing.md)

                    // Agents Section
                    agentsSection
                        .padding(.horizontal, RisingSpacing.md)

                    // Deposit History
                    depositSection
                        .padding(.horizontal, RisingSpacing.md)

                    Spacer(minLength: RisingSpacing.xl)
                }
                .padding(.top, RisingSpacing.md)
            }
        }
        .navigationTitle(viewModel.goal.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditGoal = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }
        }
        .sheet(isPresented: $showAddDeposit) {
            AddDepositView(goalId: viewModel.goal.id) {
                Task {
                    await viewModel.loadDeposits()
                    await viewModel.refreshGoal()
                }
            }
        }
        .sheet(isPresented: $showEditGoal) {
            EditGoalView(goal: viewModel.goal) {
                Task { await viewModel.refreshGoal() }
            }
        }
        .sheet(isPresented: $showMilestones) {
            NavigationStack {
                MilestoneTrackerView(goalId: viewModel.goal.id, goal: viewModel.goal)
                    .background(Color.risingBackgroundDark)
                    .navigationTitle("Milestones")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showAgents) {
            NavigationStack {
                AgentListView()
                    .background(Color.risingBackgroundDark)
                    .navigationTitle("Agents")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.loadDeposits()
        }
    }

    private var progressHeader: some View {
        VStack(spacing: RisingSpacing.lg) {
            // Large Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.risingCardDark, lineWidth: 12)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: min(viewModel.progress, 1.0))
                    .stroke(
                        Color.risingPrimary,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: viewModel.progress)

                VStack(spacing: RisingSpacing.xxs) {
                    Text("\(Int(viewModel.progress * 100))%")
                        .risingDisplay()
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    Text("saved")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }

            // Stats Row
            HStack(spacing: RisingSpacing.xl) {
                StatItem(
                    title: "Saved",
                    value: formatCurrency(viewModel.goal.currentAmount),
                    color: Color.risingPrimary
                )

                Divider()
                    .frame(height: 40)
                    .background(Color.risingCardDark)

                StatItem(
                    title: "Remaining",
                    value: formatCurrency(viewModel.remainingAmount),
                    color: Color.risingAccent
                )

                if let days = viewModel.daysRemaining {
                    Divider()
                        .frame(height: 40)
                        .background(Color.risingCardDark)

                    StatItem(
                        title: "Days Left",
                        value: "\(days)",
                        color: Color.risingTextSecondaryDark
                    )
                }
            }
            .padding(RisingSpacing.lg)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
        }
    }

    private var quickActions: some View {
        HStack(spacing: RisingSpacing.md) {
            Button {
                showAddDeposit = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Deposit")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, RisingSpacing.md)
                .background(Color.risingPrimary)
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
            }

            Button {
                showMilestones = true
            } label: {
                HStack {
                    Image(systemName: "flag.checkered")
                    Text("Milestones")
                }
                .font(.body.weight(.medium))
                .foregroundStyle(Color.risingTextPrimaryDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, RisingSpacing.md)
                .background(Color.risingSurfaceDark)
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
            }
        }
    }

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            SectionHeader(title: "Milestones", icon: "flag.checkered") {
                showMilestones = true
            }

            MilestonePreviewView(goalId: viewModel.goal.id, goal: viewModel.goal)
        }
    }

    private var chartsSection: some View {
        VStack(spacing: RisingSpacing.md) {
            DepositChartView(deposits: viewModel.deposits, goalTarget: viewModel.goal.targetAmount)
            SavingsProjectionView(deposits: viewModel.deposits, goal: viewModel.goal)
        }
    }

    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            SectionHeader(title: "Properties", icon: "house") {
                showPropertyList = true
            }

            PropertyListView(goal: viewModel.goal)
                .sheet(isPresented: $showPropertyList) {
                    NavigationStack {
                        PropertyListView(goal: viewModel.goal)
                            .background(Color.risingBackgroundDark)
                            .navigationTitle("Properties")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
        }
    }

    private var agentsSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            SectionHeader(title: "Agents", icon: "person.crop.circle") {
                showAgents = true
            }

            AgentListView()
                .sheet(isPresented: $showAgents) {
                    NavigationStack {
                        AgentListView()
                            .background(Color.risingBackgroundDark)
                            .navigationTitle("Agents")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
        }
    }

    private var depositSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.md) {
            Text("Deposit History")
                .risingHeading2()
                .foregroundStyle(Color.risingTextPrimaryDark)

            if viewModel.deposits.isEmpty {
                emptyDeposits
            } else {
                ForEach(viewModel.deposits) { deposit in
                    DepositRowView(deposit: deposit) {
                        Task { await viewModel.deleteDeposit(deposit) }
                    }
                }
            }
        }
    }

    private var emptyDeposits: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "banknote")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("No deposits yet")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("Add your first deposit to see it here.")
                .risingCaption()
                .foregroundStyle(Color.risingTextSecondaryDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RisingSpacing.xl)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.risingPrimary)

            Text(title)
                .risingHeading2()
                .foregroundStyle(Color.risingTextPrimaryDark)

            Spacer()

            Button {
                action()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }
        }
    }
}

// MARK: - Milestone Preview View

struct MilestonePreviewView: View {
    @State private var viewModel: MilestoneTrackerViewModel

    init(goalId: UUID, goal: Goal) {
        _viewModel = State(initialValue: MilestoneTrackerViewModel(goalId: goalId, goal: goal))
    }

    var body: some View {
        VStack(spacing: RisingSpacing.sm) {
            if viewModel.milestones.isEmpty {
                Text("Tap to set up milestones")
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, RisingSpacing.md)
                    .background(Color.risingSurfaceDark)
                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
            } else {
                ForEach(viewModel.milestones.prefix(3)) { milestone in
                    MilestonePreviewRow(milestone: milestone)
                }

                if viewModel.milestones.count > 3 {
                    HStack {
                        Text("+\(viewModel.milestones.count - 3) more")
                            .risingCaption()
                            .foregroundStyle(Color.risingTextSecondaryDark)
                        Spacer()
                    }
                    .padding(.top, RisingSpacing.xxs)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct MilestonePreviewRow: View {
    let milestone: Milestone

    var body: some View {
        HStack(spacing: RisingSpacing.sm) {
            Image(systemName: milestone.status == .completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundStyle(milestone.status == .completed ? Color.risingSuccess : Color.risingCardDark)

            Text(milestone.title.isEmpty ? milestone.type.displayTitle : milestone.title)
                .risingBodySmall()
                .foregroundStyle(
                    milestone.status == .completed
                    ? Color.risingTextSecondaryDark
                    : Color.risingTextPrimaryDark
                )

            Spacer()
        }
        .padding(RisingSpacing.sm)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: RisingSpacing.xxs) {
            Text(value)
                .risingHeading2()
                .foregroundStyle(color)

            Text(title)
                .risingCaption()
                .foregroundStyle(Color.risingTextSecondaryDark)
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: Goal(
            name: "House Down Payment",
            targetAmount: 50000,
            currentAmount: 17500,
            deadline: Calendar.current.date(byAdding: .month, value: 6, to: Date())
        ))
    }
}
