import SwiftUI
import Charts

struct MacStatsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MacStatsViewModel

    init(viewModel: MacDashboardViewModel) {
        _viewModel = State(initialValue: MacStatsViewModel(goals: viewModel.goals, deposits: []))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    monthlyChart
                    streakCard
                }
                .padding(24)
            }
        }
        .frame(width: 560, height: 520)
        .background(Color(hex: "1E293B"))
        .task {
            await viewModel.loadAllDeposits()
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundStyle(.risingPrimary)
            Text("Savings Stats")
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

    private var summaryCards: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Total Saved",
                value: formatCurrency(viewModel.totalSaved),
                icon: "dollarsign.circle.fill",
                color: "10B981"
            )
            statCard(
                title: "Avg Monthly",
                value: formatCurrency(viewModel.averageMonthlyDeposit),
                icon: "calendar",
                color: "F59E0B"
            )
            statCard(
                title: "Streak",
                value: "\(viewModel.streak) mo",
                icon: "flame.fill",
                color: "EF4444"
            )
            statCard(
                title: "Goals",
                value: "\(viewModel.goals.count)",
                icon: "target",
                color: "3B82F6"
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color(hex: color))
                Spacer()
            }

            Text(value)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(.risingTextPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "334155"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Monthly Chart

    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Deposits")
                .font(.headline)
                .foregroundStyle(.risingTextPrimary)

            if viewModel.monthlyData.isEmpty {
                Text("No deposit data yet")
                    .font(.body)
                    .foregroundStyle(.risingTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                Chart(viewModel.monthlyData) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color(hex: "10B981").gradient)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color(hex: "94A3B8"))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                            .foregroundStyle(Color(hex: "334155"))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(formatCurrencyCompact(doubleValue))
                                    .foregroundStyle(Color(hex: "94A3B8"))
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(20)
        .background(Color(hex: "334155"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Savings Streak")
                    .font(.headline)
                    .foregroundStyle(.risingTextPrimary)

                Text(streakMessage)
                    .font(.body)
                    .foregroundStyle(.risingTextSecondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color(hex: "334155"), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(CGFloat(viewModel.streak) / 12.0, 1.0))
                    .stroke(
                        Color(hex: "F59E0B"),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(viewModel.streak)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.risingAccent)
            }
            .frame(width: 70, height: 70)
        }
        .padding(20)
        .background(Color(hex: "334155"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var streakMessage: String {
        if viewModel.streak == 0 {
            return "Make deposits this month to start your streak!"
        } else if viewModel.streak >= 6 {
            return "Incredible! \(viewModel.streak) consecutive months of saving."
        } else {
            return "You've saved for \(viewModel.streak) month\(viewModel.streak == 1 ? "" : "s") in a row. Keep going!"
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }

    private func formatCurrencyCompact(_ amount: Double) -> String {
        if amount >= 1000 {
            return "$\(Int(amount / 1000))k"
        }
        return "$\(Int(amount))"
    }
}

// MARK: - Stats ViewModel

struct MonthlyDeposit: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

@MainActor
@Observable
final class MacStatsViewModel {
    var goals: [Goal]
    var deposits: [Deposit]
    var monthlyData: [MonthlyDeposit] = []
    var streak = 0

    init(goals: [Goal], deposits: [Deposit]) {
        self.goals = goals
        self.deposits = deposits
    }

    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    var averageMonthlyDeposit: Double {
        guard !monthlyData.isEmpty else { return 0 }
        let total = monthlyData.reduce(0) { $0 + $1.amount }
        return total / Double(monthlyData.count)
    }

    func loadAllDeposits() async {
        var allDeposits: [Deposit] = []
        for goal in goals {
            let deps = await DepositService.shared.fetchAll(forGoalId: goal.id)
            allDeposits.append(contentsOf: deps)
        }
        self.deposits = allDeposits
        computeMonthlyData()
        computeStreak()
    }

    private func computeMonthlyData() {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        var monthlyTotals: [String: Double] = [:]

        for deposit in deposits {
            let monthKey = formatter.string(from: deposit.date)
            monthlyTotals[monthKey, default: 0] += deposit.amount
        }

        let sortedKeys = monthlyTotals.keys.sorted { key1, key2 in
            let date1 = formatter.date(from: key1) ?? Date()
            let date2 = formatter.date(from: key2) ?? Date()
            return date1 < date2
        }

        monthlyData = sortedKeys.map { key in
            MonthlyDeposit(month: key, amount: monthlyTotals[key] ?? 0)
        }
    }

    private func computeStreak() {
        let calendar = Calendar.current
        var currentMonth = calendar.component(.month, from: Date())
        var currentYear = calendar.component(.year, from: Date())

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        var streakCount = 0
        let sortedDeposits = deposits.sorted { $0.date > $1.date }

        var monthSet = Set<String>()
        for deposit in sortedDeposits {
            let key = formatter.string(from: deposit.date)
            monthSet.insert(key)
        }

        while true {
            let monthKey: String
            if currentMonth < 10 {
                monthKey = "\(currentYear)-0\(currentMonth)"
            } else {
                monthKey = "\(currentYear)-\(currentMonth)"
            }

            if monthSet.contains(monthKey) {
                streakCount += 1
            } else {
                break
            }

            currentMonth -= 1
            if currentMonth == 0 {
                currentMonth = 12
                currentYear -= 1
            }
        }

        streak = streakCount
    }
}
