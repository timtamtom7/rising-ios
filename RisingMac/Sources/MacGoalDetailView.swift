import SwiftUI

struct MacGoalDetailView: View {
    @State private var viewModel: MacGoalDetailViewModel
    @State private var showingAddDeposit = false
    @State private var showingEditGoal = false

    let onGoalUpdated: () -> Void

    init(goal: Goal, onGoalUpdated: @escaping () -> Void) {
        _viewModel = State(initialValue: MacGoalDetailViewModel(goal: goal))
        self.onGoalUpdated = onGoalUpdated
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard
                aiInsightCard
                progressSection
                depositsSection
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.risingBackgroundDark)
        .task {
            await viewModel.loadDeposits()
        }
        .sheet(isPresented: $showingAddDeposit) {
            MacDepositSheet(goalId: viewModel.goal.id) {
                Task {
                    await viewModel.loadDeposits()
                    await viewModel.refreshGoal()
                    onGoalUpdated()
                }
            }
        }
        .sheet(isPresented: $showingEditGoal) {
            MacEditGoalView(goal: viewModel.goal) {
                Task {
                    await viewModel.refreshGoal()
                    onGoalUpdated()
                }
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.goal.iconName)
                        .font(.title2)
                        .foregroundStyle(.risingPrimary)
                    Text(viewModel.goal.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.risingTextPrimary)
                }

                if let description = viewModel.goal.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.risingTextSecondary)
                }

                HStack(spacing: 16) {
                    if let days = viewModel.daysRemaining {
                        Label("\(days) days left", systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.risingTextSecondary)
                    }

                    Label(formatCurrency(viewModel.goal.targetAmount), systemImage: "target")
                        .font(.caption)
                        .foregroundStyle(.risingTextSecondary)
                }

                Button {
                    showingEditGoal = true
                } label: {
                    Label("Edit Goal", systemImage: "pencil")
                        .font(.caption)
                        .foregroundStyle(.risingPrimary)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .accessibilityLabel("Edit goal")
                .accessibilityHint("Modify goal name, target, deadline, or icon")
            }

            Spacer()

            progressRing
        }
        .padding(20)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.risingCardDark, lineWidth: 12)

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    Color.risingPrimary,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: viewModel.progress)

            // Pattern overlay for colorblind accessibility (dashed arc)
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    Color.risingTextPrimary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash: [4, 3])
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: viewModel.progress)

            VStack(spacing: 2) {
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(.risingTextPrimary)
                Text("funded")
                    .font(.caption2)
                    .foregroundStyle(.risingTextSecondary)
            }
        }
        .frame(width: 120, height: 120)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(viewModel.progress * 100)) percent funded")
        .accessibilityValue("Target: \(formatCurrency(viewModel.goal.targetAmount)), Saved: \(formatCurrency(viewModel.goal.currentAmount))")
    }

    // MARK: - AI Insight Card

    private var aiInsightCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title3)
                .foregroundStyle(.risingAccent)

            VStack(alignment: .leading, spacing: 4) {
                Text("AI Insight")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.risingAccent)

                Text(aiInsightText)
                    .font(.body)
                    .foregroundStyle(.risingTextPrimary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.risingAccent.opacity(0.15), Color.risingSurfaceDark],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.risingAccent.opacity(0.3), lineWidth: 1)
        )
    }

    private var aiInsightText: String {
        let goal = viewModel.goal
        if goal.isCompleted {
            return "🎉 Congratulations! You've reached your \(goal.name) goal!"
        }

        let remaining = goal.remainingAmount
        if remaining <= 0 { return "" }

        if let days = goal.daysRemaining, days > 0 {
            let perDay = remaining / Double(days)
            return "At your current pace, you'll reach this goal in about \(Int(ceil(remaining / max(perDay, 1)))) days. Keep it up!"
        } else if let days = goal.daysRemaining, days <= 0 {
            return "This goal is past its deadline. Consider extending it or adjusting the target."
        }

        let avgDeposit = viewModel.deposits.isEmpty ? 0 : viewModel.deposits.reduce(0) { $0 + $1.amount } / Double(viewModel.deposits.count)
        if avgDeposit > 0 {
            let monthsNeeded = Int(ceil(remaining / avgDeposit))
            return "Based on your average deposit of \(formatCurrency(avgDeposit)), you'll reach this goal in about \(monthsNeeded) month\(monthsNeeded == 1 ? "" : "s")."
        }

        return "You're \(Int(viewModel.progress * 100))% of the way there. Keep making deposits!"
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .foregroundStyle(.risingTextPrimary)

                Spacer()

                Button {
                    showingAddDeposit = true
                } label: {
                    Label("Add Deposit", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.risingPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add deposit")
                .accessibilityHint("Log a new savings deposit for this goal")
            }

            HStack(spacing: 20) {
                amountCard(title: "Saved", amount: viewModel.goal.currentAmount, color: "10B981")
                amountCard(title: "Target", amount: viewModel.goal.targetAmount, color: "F59E0B")
                amountCard(title: "Remaining", amount: viewModel.goal.remainingAmount, color: "94A3B8")
            }

            // Milestone markers
            milestoneMarkers
        }
        .padding(20)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func amountCard(title: String, amount: Double, color: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            HStack(spacing: 6) {
                Text(formatCurrency(amount))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: color))
                // Colorblind-safe: icon indicator supplements color
                Image(systemName: color == "10B981" ? "arrow.up.circle.fill" : color == "F59E0B" ? "target" : "minus.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: color).opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.risingCardDark)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityLabel("\(title): \(formatCurrency(amount))")
    }

    private var milestoneMarkers: some View {
        let milestones = [
            ("25%", 0.25, "quarter"),
            ("50%", 0.50, "half"),
            ("75%", 0.75, "three-quarter"),
            ("100%", 1.0, "complete")
        ]

        return VStack(alignment: .leading, spacing: 8) {
            Text("Milestones")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)

            HStack(spacing: 0) {
                ForEach(milestones, id: \.0) { milestone in
                    let reached = viewModel.progress >= milestone.1

                    VStack(spacing: 4) {
                        // Colorblind-safe: use checkmark + filled circle for reached, empty for not reached
                        ZStack {
                            Circle()
                                .fill(reached ? Color.risingPrimary : Color.risingCardDark)
                                .frame(width: 12, height: 12)
                            if reached {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Circle()
                                    .stroke(Color.risingTextSecondary.opacity(0.5), lineWidth: 1)
                                    .frame(width: 12, height: 12)
                            }
                        }
                        .accessibilityLabel("\(milestone.0) milestone: \(reached ? "reached" : "not reached")")

                        Text(milestone.0)
                            .font(.caption2)
                            .foregroundStyle(reached ? .risingPrimary : .risingTextSecondary)
                    }
                    .frame(maxWidth: .infinity)

                    if milestone.0 != "100%" {
                        // Colorblind-safe: use different dash patterns for reached vs not
                        Rectangle()
                            .fill(
                                viewModel.progress >= milestone.1
                                    ? Color.risingPrimary
                                    : Color.risingCardDark
                            )
                            .frame(height: 2)
                            .frame(maxWidth: 30)
                            .overlay(
                                // Add dash pattern overlay for colorblind distinction
                                viewModel.progress < milestone.1
                                    ? nil
                                    : AnyView(
                                        Rectangle()
                                            .fill(Color.risingTextPrimary.opacity(0.3))
                                            .frame(height: 2)
                                            .frame(width: 30)
                                            .mask(
                                                HStack(spacing: 3) {
                                                    ForEach(0..<5, id: \.self) { _ in
                                                        Rectangle().frame(width: 4)
                                                    }
                                                }
                                            )
                                    )
                            )
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Deposits Section

    private var depositsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Deposit History")
                    .font(.headline)
                    .foregroundStyle(.risingTextPrimary)

                Spacer()

                Text("\(viewModel.deposits.count) deposits")
                    .font(.caption)
                    .foregroundStyle(.risingTextSecondary)
            }

            if viewModel.deposits.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title)
                        .foregroundStyle(.risingTextSecondary.opacity(0.5))
                    Text("No deposits yet")
                        .font(.body)
                        .foregroundStyle(.risingTextSecondary)
                    Text("Click 'Add Deposit' to log your first savings")
                        .font(.caption)
                        .foregroundStyle(.risingTextSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.deposits) { deposit in
                        depositRow(deposit)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func depositRow(_ deposit: Deposit) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.risingPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text("+\(formatCurrency(deposit.amount))")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundStyle(.risingPrimary)

                if let note = deposit.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.risingTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(formatDate(deposit.date))
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)

            Button {
                Task {
                    await viewModel.deleteDeposit(deposit)
                    onGoalUpdated()
                }
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.risingError.opacity(0.7))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete deposit")
            .accessibilityHint("Remove this deposit from the history")
        }
        .padding(12)
        .background(Color.risingCardDark)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Goal Detail ViewModel

@MainActor
@Observable
final class MacGoalDetailViewModel {
    var goal: Goal
    var deposits: [Deposit] = []
    var isLoading = false
    var errorMessage: String?

    init(goal: Goal) {
        self.goal = goal
    }

    var progress: Double { goal.progress }
    var remainingAmount: Double { goal.remainingAmount }
    var daysRemaining: Int? { goal.daysRemaining }

    func loadDeposits() async {
        isLoading = true
        do {
            deposits = await DepositService.shared.fetchAll(forGoalId: goal.id)
        } catch {
            errorMessage = "Failed to load deposits."
        }
        isLoading = false
    }

    func deleteDeposit(_ deposit: Deposit) async {
        do {
            deposits.removeAll { $0.id == deposit.id }
            goal.currentAmount = max(goal.currentAmount - deposit.amount, 0)
            try await GoalService.shared.update(goal)
            try await DepositService.shared.delete(id: deposit.id)
        } catch {
            errorMessage = "Failed to delete deposit."
        }
    }

    func refreshGoal() async {
        let allGoals = await GoalService.shared.fetchAll()
        if let updated = allGoals.first(where: { $0.id == goal.id }) {
            goal = updated
        }
    }
}
