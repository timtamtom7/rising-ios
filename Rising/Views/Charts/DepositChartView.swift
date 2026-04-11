import SwiftUI
import Charts

// MARK: - Deposit Chart View (Monthly History)

struct DepositChartView: View {
    let deposits: [Deposit]
    let goalTarget: Double

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.md) {
            Text("Monthly Deposits")
                .risingHeading2()
                .foregroundStyle(Color.risingTextPrimary)

            if deposits.isEmpty {
                emptyState
            } else {
                chartContent
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }

    private var emptyState: some View {
        VStack(spacing: RisingSpacing.sm) {
            Image(systemName: "chart.bar")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.risingTextSecondary)
                .accessibilityHidden(true)

            Text("No deposits to chart yet")
                .risingCaption()
                .foregroundStyle(Color.risingTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RisingSpacing.lg)
    }

    @ViewBuilder
    private var chartContent: some View {
        if #available(iOS 26.0, *) {
            Chart(monthlyData, id: \.month) { item in
                BarMark(
                    x: .value("Month", item.month, unit: .month),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.risingPrimary.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.risingCard)
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.risingCard)
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCompactCurrency(amount))
                                .foregroundStyle(Color.risingTextSecondary)
                        }
                    }
                }
            }
            .frame(height: 180)
        } else {
            // Fallback for older iOS
            fallbackBars
        }
    }

    private var fallbackBars: some View {
        HStack(alignment: .bottom, spacing: RisingSpacing.xs) {
            ForEach(monthlyData.prefix(6), id: \.month) { item in
                VStack(spacing: RisingSpacing.xxs) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.risingPrimary)
                        .frame(width: 30, height: barHeight(for: item.amount))

                    Text(shortMonth(item.month))
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }
        }
        .frame(height: 180)
    }

    private func barHeight(for amount: Double) -> CGFloat {
        let maxAmount = monthlyData.map(\.amount).max() ?? 1
        let ratio = amount / maxAmount
        return max(ratio * 120, 8)
    }

    private func shortMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func formatCompactCurrency(_ value: Double) -> String {
        if value >= 1000 {
            return "$\(Int(value / 1000))k"
        }
        return "$\(Int(value))"
    }

    private var monthlyData: [MonthlyDeposit] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: deposits) { deposit in
            calendar.date(from: calendar.dateComponents([.year, .month], from: deposit.date)) ?? deposit.date
        }

        return grouped.map { month, deps in
            MonthlyDeposit(month: month, amount: deps.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.month < $1.month }
        .suffix(12)
        .map { $0 }
    }
}

struct MonthlyDeposit: Identifiable {
    let id = UUID()
    let month: Date
    let amount: Double
}

// MARK: - Savings Projection View

struct SavingsProjectionView: View {
    let deposits: [Deposit]
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.md) {
            Text("Savings Projection")
                .risingHeading2()
                .foregroundStyle(Color.risingTextPrimary)

            if deposits.count < 2 {
                VStack(spacing: RisingSpacing.sm) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(Color.risingTextSecondary)
                        .accessibilityHidden(true)

                    Text("Add more deposits to see your projection")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, RisingSpacing.lg)
            } else {
                projectionContent
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }

    private var projectionContent: some View {
        VStack(spacing: RisingSpacing.lg) {
            // Stats
            HStack(spacing: RisingSpacing.xl) {
                StatPill(
                    title: "Avg. Monthly",
                    value: averageMonthlyDeposit.formattedCurrency,
                    color: Color.risingPrimary
                )

                if let projectedDate = estimatedCompletionDate {
                    StatPill(
                        title: "Est. Completion",
                        value: RisingFormatters.monthYear.string(from: projectedDate),
                        color: Color.risingAccent
                    )
                }
            }

            // On track indicator
            HStack(spacing: RisingSpacing.sm) {
                Image(systemName: onTrackIcon)
                    .foregroundStyle(onTrackColor)
                    .accessibilityHidden(true)

                Text(onTrackText)
                    .risingCaption()
                    .foregroundStyle(onTrackColor)

                Spacer()
            }
        }
    }

    private var averageMonthlyDeposit: Double {
        guard !deposits.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sorted = deposits.sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last else { return 0 }

        let months = calendar.dateComponents([.month], from: first.date, to: last.date).month ?? 1
        let total = deposits.reduce(0) { $0 + $1.amount }
        return total / Double(max(months, 1))
    }

    private var estimatedCompletionDate: Date? {
        guard goal.deadline != nil else { return nil }
        let remaining = goal.remainingAmount
        guard averageMonthlyDeposit > 0 else { return nil }

        let monthsNeeded = Int(ceil(remaining / averageMonthlyDeposit))
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: monthsNeeded, to: Date())
    }

    private var onTrackIcon: String {
        guard let deadline = goal.deadline, let projected = estimatedCompletionDate else {
            return "questionmark.circle"
        }
        return projected <= deadline ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }

    private var onTrackColor: Color {
        guard let deadline = goal.deadline, let projected = estimatedCompletionDate else {
            return Color.risingTextSecondary
        }
        return projected <= deadline ? Color.risingSuccess : Color.risingWarning
    }

    private var onTrackText: String {
        guard let deadline = goal.deadline, let projected = estimatedCompletionDate else {
            return "Add more deposits to see your projection"
        }
        if projected <= deadline {
            return "You're on track to meet your goal!"
        } else {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: deadline, to: projected).day ?? 0
            return "~\(days) days past your target date"
        }
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
            Text(title)
                .risingCaption()
                .foregroundStyle(Color.risingTextSecondary)

            Text(value)
                .risingHeading3()
                .foregroundStyle(color)
        }
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    VStack {
        DepositChartView(
            deposits: [],
            goalTarget: 50000
        )

        SavingsProjectionView(
            deposits: [],
            goal: Goal(name: "House", targetAmount: 50000)
        )
    }
    .padding()
    .background(Color.risingBackground)
}
