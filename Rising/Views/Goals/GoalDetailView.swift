import SwiftUI

struct GoalDetailView: View {
    @State private var viewModel: GoalDetailViewModel
    @State private var showAddDeposit = false
    @State private var showEditGoal = false

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
