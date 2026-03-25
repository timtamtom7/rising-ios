import SwiftUI

struct MilestoneTrackerView: View {
    @State private var viewModel: MilestoneTrackerViewModel

    init(goalId: UUID, goal: Goal) {
        _viewModel = State(initialValue: MilestoneTrackerViewModel(goalId: goalId, goal: goal))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            progressHeader

            // Milestones List
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .tint(Color.risingPrimary)
                Spacer()
            } else {
                milestonesList
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var progressHeader: some View {
        VStack(spacing: RisingSpacing.md) {
            HStack {
                Text("Milestones")
                    .risingHeading2()
                    .foregroundStyle(Color.risingTextPrimaryDark)

                Spacer()

                Text("\(viewModel.completedCount)/\(viewModel.milestones.count)")
                    .risingLabel()
                    .foregroundStyle(Color.risingPrimary)
                    .padding(.horizontal, RisingSpacing.sm)
                    .padding(.vertical, RisingSpacing.xxs)
                    .background(Color.risingPrimary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.full))
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingCardDark)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingPrimary)
                        .frame(width: geometry.size.width * viewModel.progress, height: 6)
                        .animation(.easeOut(duration: 0.6), value: viewModel.progress)
                }
            }
            .frame(height: 6)
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }

    private var milestonesList: some View {
        ScrollView {
            VStack(spacing: RisingSpacing.sm) {
                ForEach(viewModel.milestones) { milestone in
                    MilestoneRowView(milestone: milestone) {
                        Task { await viewModel.toggleComplete(milestone) }
                    }
                }
            }
            .padding(.top, RisingSpacing.md)
        }
    }
}

// MARK: - Milestone Row View

struct MilestoneRowView: View {
    let milestone: Milestone
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: RisingSpacing.md) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    if milestone.status == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(statusColor)
                    } else {
                        Image(systemName: milestone.type.iconName)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                    Text(milestone.title.isEmpty ? milestone.type.displayTitle : milestone.title)
                        .risingBody()
                        .foregroundStyle(
                            milestone.status == .completed
                            ? Color.risingTextSecondaryDark
                            : Color.risingTextPrimaryDark
                        )
                        .strikethrough(milestone.status == .completed, color: Color.risingTextSecondaryDark)

                    if let amount = milestone.amount {
                        Text(formatCurrency(amount))
                            .risingCaption()
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }

                    if milestone.status == .completed, let completedAt = milestone.completedAt {
                        Text("Completed \(formatDate(completedAt))")
                            .risingCaption()
                            .foregroundStyle(Color.risingSuccess)
                    }
                }

                Spacer()

                // Checkbox
                Image(systemName: milestone.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(milestone.status == .completed ? Color.risingPrimary : Color.risingCardDark)
            }
            .padding(RisingSpacing.md)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        milestone.status == .completed ? Color.risingSuccess : Color.risingTextSecondaryDark
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MilestoneTrackerView(
        goalId: UUID(),
        goal: Goal(name: "House", targetAmount: 50000)
    )
    .background(Color.risingBackgroundDark)
}
