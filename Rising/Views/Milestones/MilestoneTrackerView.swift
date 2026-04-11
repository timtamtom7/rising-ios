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
                    .foregroundStyle(Color.risingTextPrimary)

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
                        .fill(Color.risingCard)
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
        .background(Color.risingSurface)
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
                            .accessibilityHidden(true)
                    } else {
                        Image(systemName: milestone.type.iconName)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.risingTextSecondary)
                            .accessibilityHidden(true)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                    Text(milestone.title.isEmpty ? milestone.type.displayTitle : milestone.title)
                        .risingBody()
                        .foregroundStyle(
                            milestone.status == .completed
                            ? Color.risingTextSecondary
                            : Color.risingTextPrimary
                        )
                        .strikethrough(milestone.status == .completed, color: Color.risingTextSecondary)

                    if let amount = milestone.amount {
                        Text(amount.formattedCurrency)
                            .risingCaption()
                            .foregroundStyle(Color.risingTextSecondary)
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
                    .foregroundStyle(milestone.status == .completed ? Color.risingPrimary : Color.risingCard)
            }
            .padding(RisingSpacing.md)
            .background(Color.risingSurface)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityDescription)
    }

    private var statusColor: Color {
        milestone.status == .completed ? Color.risingSuccess : Color.risingTextSecondary
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var accessibilityDescription: String {
        let title = milestone.title.isEmpty ? milestone.type.displayTitle : milestone.title
        let status = milestone.status == .completed ? "Completed" : "Not completed"
        let amountText = milestone.amount.map { " - \($0.formattedCurrency)" } ?? ""
        return "\(title)\(amountText) - \(status)"
    }
}

#Preview {
    MilestoneTrackerView(
        goalId: UUID(),
        goal: Goal(name: "House", targetAmount: 50000)
    )
    .background(Color.risingBackground)
}
