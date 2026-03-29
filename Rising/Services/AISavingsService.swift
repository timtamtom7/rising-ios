import Foundation

// MARK: - AI Savings Intelligence Service
// R11: AI-powered savings prediction and completion date forecasting

final class AISavingsService {
    static let shared = AISavingsService()

    private init() {}

    // MARK: - Date Prediction

    struct DatePrediction: Equatable {
        let predictedDate: Date
        let confidence: Double // 0.0 - 1.0
        let daysNeeded: Int
        let averageMonthlyDeposit: Double
        let suggestedMonthlyAmount: Double
        let isOnTrack: Bool
        let riskFactors: [RiskFactor]

        enum RiskFactor: String, Equatable {
            case inconsistentDeposits = "Inconsistent deposit pattern"
            case belowTargetRate = "Below target savings rate"
            case noRecentActivity = "No recent deposits"
            case deadlineApproaching = "Deadline approaching fast"
            case highVariance = "High spending variance detected"
        }
    }

    // MARK: - Prediction

    func predictCompletionDate(for goal: Goal, deposits: [Deposit]) -> DatePrediction {
        let goalDeposits = deposits
            .filter { $0.goalId == goal.id }
            .sorted { $0.date < $1.date }

        guard !goalDeposits.isEmpty else {
            return buildNoDataPrediction(for: goal)
        }

        let totalDeposited = goalDeposits.reduce(0) { $0 + $1.amount }
        let remaining = goal.remainingAmount

        guard remaining > 0 else {
            return DatePrediction(
                predictedDate: Date(),
                confidence: 1.0,
                daysNeeded: 0,
                averageMonthlyDeposit: 0,
                suggestedMonthlyAmount: 0,
                isOnTrack: true,
                riskFactors: []
            )
        }

        // Analyze deposit patterns
        let monthlyAverage = calculateMonthlyAverage(deposits: goalDeposits)
        let depositFrequency = calculateFrequency(deposits: goalDeposits)
        let variance = calculateVariance(deposits: goalDeposits)
        let trend = calculateTrend(deposits: goalDeposits)
        let recentActivity = hasRecentActivity(deposits: goalDeposits)

        // Predict completion
        let (predictedDate, confidence, daysNeeded) = computePrediction(
            remaining: remaining,
            monthlyAverage: monthlyAverage,
            depositFrequency: depositFrequency,
            trend: trend
        )

        // Determine risk factors
        var riskFactors: [DatePrediction.RiskFactor] = []
        if variance > 0.5 { riskFactors.append(.highVariance) }
        if !recentActivity { riskFactors.append(.noRecentActivity) }
        if trend < 0 { riskFactors.append(.inconsistentDeposits) }
        if monthlyAverage * depositFrequency < goal.targetAmount * 0.1 {
            riskFactors.append(.belowTargetRate)
        }
        if let daysLeft = goal.daysRemaining, daysLeft < 30 && daysNeeded > daysLeft {
            riskFactors.append(.deadlineApproaching)
        }

        // Calculate suggested monthly amount
        let monthsRemaining: Double
        if let deadline = goal.deadline {
            monthsRemaining = max(Date().distance(to: deadline) / 30.0, 1.0)
        } else {
            monthsRemaining = 12.0
        }
        let suggestedMonthlyAmount = remaining / monthsRemaining

        let isOnTrack = riskFactors.isEmpty || (riskFactors.count == 1 && riskFactors.first == .belowTargetRate)

        return DatePrediction(
            predictedDate: predictedDate,
            confidence: confidence,
            daysNeeded: daysNeeded,
            averageMonthlyDeposit: monthlyAverage,
            suggestedMonthlyAmount: suggestedMonthlyAmount,
            isOnTrack: isOnTrack,
            riskFactors: riskFactors
        )
    }

    // MARK: - Private Helpers

    private func buildNoDataPrediction(for goal: Goal) -> DatePrediction {
        let suggestedMonthly = goal.remainingAmount / 12.0
        return DatePrediction(
            predictedDate: Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date(),
            confidence: 0.1,
            daysNeeded: 365,
            averageMonthlyDeposit: 0,
            suggestedMonthlyAmount: suggestedMonthly,
            isOnTrack: false,
            riskFactors: [.noRecentActivity, .belowTargetRate]
        )
    }

    private func calculateMonthlyAverage(deposits: [Deposit]) -> Double {
        guard deposits.count >= 2 else { return deposits.first?.amount ?? 0 }

        let sorted = deposits.sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last else { return 0 }

        let monthSpan = max(first.date.distance(to: last.date) / (30.0 * 24 * 60 * 60), 1.0)
        let total = deposits.reduce(0) { $0 + $1.amount }
        return total / monthSpan
    }

    private func calculateFrequency(deposits: [Deposit]) -> Double {
        // Deposits per month
        guard deposits.count >= 2 else { return 1.0 }

        let sorted = deposits.sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last else { return 1.0 }

        let monthSpan = max(first.date.distance(to: last.date) / (30.0 * 24 * 60 * 60), 1.0)
        return Double(deposits.count) / monthSpan
    }

    private func calculateVariance(deposits: [Deposit]) -> Double {
        guard deposits.count >= 2 else { return 0 }

        let amounts = deposits.map { $0.amount }
        let mean = amounts.reduce(0, +) / Double(amounts.count)
        let squaredDiffs = amounts.map { pow($0 - mean, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(amounts.count)

        return mean > 0 ? sqrt(variance) / mean : 0
    }

    private func calculateTrend(deposits: [Deposit]) -> Double {
        // Positive = increasing savings rate, negative = decreasing
        guard deposits.count >= 3 else { return 0 }

        let sorted = deposits.sorted { $0.date < $1.date }
        let midpoint = sorted.count / 2

        let firstHalf = Array(sorted.prefix(midpoint))
        let secondHalf = Array(sorted.suffix(midpoint))

        let firstAvg = firstHalf.reduce(0) { $0 + $1.amount } / Double(max(firstHalf.count, 1))
        let secondAvg = secondHalf.reduce(0) { $0 + $1.amount } / Double(max(secondHalf.count, 1))

        guard firstAvg > 0 else { return secondAvg > 0 ? 1.0 : 0.0 }
        return (secondAvg - firstAvg) / firstAvg
    }

    private func hasRecentActivity(deposits: [Deposit]) -> Bool {
        guard let last = deposits.sorted(by: { $0.date > $1.date }).first else { return false }
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return last.date >= thirtyDaysAgo
    }

    private func computePrediction(
        remaining: Double,
        monthlyAverage: Double,
        depositFrequency: Double,
        trend: Double
    ) -> (Date, Double, Int) {
        guard monthlyAverage > 0 else {
            let fallbackDate = Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date()
            return (fallbackDate, 0.2, 365)
        }

        // Adjust for frequency and trend
        let effectiveMonthly = monthlyAverage * min(depositFrequency, 2.0) * (1 + trend * 0.5)
        let monthsNeeded = remaining / max(effectiveMonthly, 1)

        let daysNeeded = Int(monthsNeeded * 30)
        let predictedDate = Calendar.current.date(byAdding: .day, value: daysNeeded, to: Date()) ?? Date()

        // Confidence based on data quality
        let confidence = min(0.95, max(0.3, 0.5 + depositFrequency * 0.1))

        return (predictedDate, confidence, daysNeeded)
    }
}
