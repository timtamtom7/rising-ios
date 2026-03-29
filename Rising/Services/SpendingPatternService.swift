import Foundation

// MARK: - Spending Pattern Service
// R11: Detect recurring expenses, "found money" savings opportunities

@MainActor
final class SpendingPatternService {
    static let shared = SpendingPatternService()

    private init() {}

    // MARK: - Found Money Event

    struct FoundMoneyEvent: Identifiable, Equatable {
        let id: UUID
        let description: String
        let amount: Double
        let category: Category
        let detectedAt: Date
        let source: Source
        var isSaved: Bool

        enum Category: String, CaseIterable, Equatable {
            case taxRefund = "Tax Refund"
            case bonus = "Bonus"
            case cashback = "Cashback"
            case refund = "Refund"
            case gift = "Gift"
            case selling = "Selling"
            case rebate = "Rebate"
            case other = "Other"
        }

        enum Source: String, Equatable {
            case bankTransaction = "Bank Transaction"
            case recurringExpense = "Recurring Expense"
            case subscriptionEnd = "Subscription Ended"
            case priceDrop = "Price Drop"
            case manualEntry = "Manual Entry"
        }
    }

    // MARK: - Recurring Expense

    struct RecurringExpense: Identifiable, Equatable {
        let id: UUID
        let merchantName: String
        let amount: Double
        let frequency: Frequency
        let category: String
        var potentialSavings: Double
        var lastDetected: Date

        enum Frequency: String, CaseIterable, Equatable {
            case weekly = "Weekly"
            case biweekly = "Bi-weekly"
            case monthly = "Monthly"
            case quarterly = "Quarterly"
            case yearly = "Yearly"

            var monthlyMultiplier: Double {
                switch self {
                case .weekly: return 4.33
                case .biweekly: return 2.17
                case .monthly: return 1.0
                case .quarterly: return 0.33
                case .yearly: return 0.083
                }
            }
        }
    }

    // MARK: - Spending Insight

    struct SpendingInsight: Identifiable, Equatable {
        let id: UUID
        let title: String
        let description: String
        let type: InsightType
        let potentialSavings: Double
        var isActionable: Bool

        enum InsightType: Equatable {
            case foundMoney(FoundMoneyEvent)
            case recurringSpending(RecurringExpense)
            case subscriptionOpportunity(String)
            case savingsSuggestion(String)
        }
    }

    // MARK: - Analysis Results

    struct SpendingAnalysis: Equatable {
        let foundMoneyEvents: [FoundMoneyEvent]
        let recurringExpenses: [RecurringExpense]
        let insights: [SpendingInsight]
        let totalFoundMoney: Double
        let totalPotentialSavings: Double
        let analyzedTransactions: Int
    }

    // MARK: - Public API

    /// Analyze transactions to detect spending patterns and found money
    func analyzeTransactions(
        transactions: [TransactionEntry],
        goals: [Goal],
        deposits: [Deposit]
    ) -> SpendingAnalysis {
        let foundMoney = detectFoundMoney(transactions: transactions, deposits: deposits)
        let recurring = detectRecurringExpenses(transactions: transactions)
        let insights = generateInsights(
            foundMoney: foundMoney,
            recurring: recurring,
            goals: goals
        )

        let totalFoundMoney = foundMoney.reduce(0) { $0 + $1.amount }
        let totalSavings = recurring.reduce(0) { $0 + $1.potentialSavings } + insights.reduce(0) {
            guard case .foundMoney(let event) = $1.type else { return $0 }
            return $0 + event.amount
        }

        return SpendingAnalysis(
            foundMoneyEvents: foundMoney,
            recurringExpenses: recurring,
            insights: insights,
            totalFoundMoney: totalFoundMoney,
            totalPotentialSavings: totalSavings,
            analyzedTransactions: transactions.count
        )
    }

    /// Detect one-time windfalls that could be saved
    func detectFoundMoney(transactions: [TransactionEntry], deposits: [Deposit]) -> [FoundMoneyEvent] {
        var events: [FoundMoneyEvent] = []

        // Check for refunds, cashback, and credits
        for transaction in transactions {
            if transaction.amount > 0 && transaction.category.lowercased().contains("refund") {
                events.append(FoundMoneyEvent(
                    id: UUID(),
                    description: "\(transaction.merchant ?? "Unknown") refund",
                    amount: transaction.amount,
                    category: .refund,
                    detectedAt: transaction.date,
                    source: .bankTransaction,
                    isSaved: false
                ))
            }

            if transaction.amount > 0 && transaction.category.lowercased().contains("cashback") {
                events.append(FoundMoneyEvent(
                    id: UUID(),
                    description: "\(transaction.merchant ?? "Credit") cashback",
                    amount: transaction.amount,
                    category: .cashback,
                    detectedAt: transaction.date,
                    source: .bankTransaction,
                    isSaved: false
                ))
            }

            if transaction.amount > 0 && transaction.category.lowercased().contains("credit") {
                events.append(FoundMoneyEvent(
                    id: UUID(),
                    description: "\(transaction.merchant ?? "Credit") received",
                    amount: transaction.amount,
                    category: .other,
                    detectedAt: transaction.date,
                    source: .bankTransaction,
                    isSaved: false
                ))
            }
        }

        // Detect tax refund patterns
        let taxRelated = transactions.filter {
            $0.merchant?.lowercased().contains("irs") == true ||
            $0.merchant?.lowercased().contains("tax") == true ||
            $0.description.lowercased().contains("tax refund")
        }
        for taxTx in taxRelated where taxTx.amount > 0 {
            events.append(FoundMoneyEvent(
                id: UUID(),
                description: "Tax refund",
                amount: taxTx.amount,
                category: .taxRefund,
                detectedAt: taxTx.date,
                source: .bankTransaction,
                isSaved: deposits.contains { $0.note?.contains("Tax") == true }
            ))
        }

        // Detect bonus income
        let bonusKeywords = ["bonus", "commission", "incentive", "profit sharing"]
        for tx in transactions {
            let desc = (tx.merchant ?? "").lowercased() + " " + tx.description.lowercased()
            if tx.amount > 0 && bonusKeywords.contains(where: { desc.contains($0) }) {
                events.append(FoundMoneyEvent(
                    id: UUID(),
                    description: "\(tx.merchant ?? "Employer") bonus",
                    amount: tx.amount,
                    category: .bonus,
                    detectedAt: tx.date,
                    source: .bankTransaction,
                    isSaved: false
                ))
            }
        }

        return events.sorted { $0.detectedAt > $1.detectedAt }
    }

    /// Detect recurring expenses that could be reduced or canceled
    func detectRecurringExpenses(transactions: [TransactionEntry]) -> [RecurringExpense] {
        var merchantTotals: [String: [TransactionEntry]] = [:]

        for tx in transactions where tx.amount < 0 {
            let key = tx.merchant ?? "Unknown"
            if merchantTotals[key] == nil {
                merchantTotals[key] = []
            }
            merchantTotals[key]?.append(tx)
        }

        var recurring: [RecurringExpense] = []

        for (merchant, txs) in merchantTotals {
            guard txs.count >= 2 else { continue }

            let sorted = txs.sorted { $0.date < $1.date }
            let intervals = zip(sorted, sorted.dropFirst()).map {
                $0.1.date.distance(to: $0.0.date)
            }

            let avgInterval = abs(intervals.reduce(0, +)) / Double(max(intervals.count, 1))
            let avgAmount = abs(txs.reduce(0) { $0 + $1.amount }) / Double(txs.count)

            // Check if interval is consistent (within 20% variance)
            let isConsistent = intervals.allSatisfy { interval in
                abs(abs(interval) - avgInterval) / avgInterval < 0.2
            }

            guard isConsistent else { continue }

            let frequency = detectFrequency(from: avgInterval)
            let category = categorizeMerchant(merchant)

            // Calculate potential savings (suggest 20% reduction as starting point)
            let potentialSavings = avgAmount * frequency.monthlyMultiplier * 0.2

            recurring.append(RecurringExpense(
                id: UUID(),
                merchantName: merchant,
                amount: avgAmount,
                frequency: frequency,
                category: category,
                potentialSavings: potentialSavings,
                lastDetected: sorted.last?.date ?? Date()
            ))
        }

        return recurring.sorted { $0.potentialSavings > $1.potentialSavings }
    }

    // MARK: - Private Helpers

    private func generateInsights(
        foundMoney: [FoundMoneyEvent],
        recurring: [RecurringExpense],
        goals: [Goal]
    ) -> [SpendingInsight] {
        var insights: [SpendingInsight] = []

        // Found money insights
        for event in foundMoney.prefix(5) where !event.isSaved {
            insights.append(SpendingInsight(
                id: UUID(),
                title: "Unclaimed \(event.category.rawValue)",
                description: "You received \(formatCurrency(event.amount)) from \(event.description). Consider putting it toward a savings goal!",
                type: .foundMoney(event),
                potentialSavings: event.amount,
                isActionable: true
            ))
        }

        // Top recurring expenses insight
        if let top = recurring.first {
            insights.append(SpendingInsight(
                id: UUID(),
                title: "Your biggest recurring expense",
                description: "\(top.merchantName) costs \(formatCurrency(top.amount)) \(top.frequency.rawValue.lowercased()). Potential monthly savings: \(formatCurrency(top.potentialSavings))",
                type: .recurringSpending(top),
                potentialSavings: top.potentialSavings,
                isActionable: true
            ))
        }

        // Suggest subscription audit if many small recurring
        let monthlyTotal = recurring
            .filter { $0.frequency == .monthly }
            .reduce(0) { $0 + $1.amount }

        if recurring.count >= 3 && monthlyTotal > 100 {
            insights.append(SpendingInsight(
                id: UUID(),
                title: "Subscription audit recommended",
                description: "You have \(recurring.count) recurring expenses totaling ~\(formatCurrency(monthlyTotal))/month. Reviewing subscriptions could save \(formatCurrency(monthlyTotal * 0.25))+/month.",
                type: .subscriptionOpportunity("Multiple subscriptions detected"),
                potentialSavings: monthlyTotal * 0.25,
                isActionable: true
            ))
        }

        // Suggest found money allocation if goals exist
        if !goals.isEmpty && !foundMoney.isEmpty {
            let totalUnclaimed = foundMoney.filter { !$0.isSaved }.reduce(0) { $0 + $1.amount }
            if totalUnclaimed > 50 {
                let topGoal = goals.max { $0.remainingAmount < $1.remainingAmount }
                if let goal = topGoal {
                    insights.append(SpendingInsight(
                        id: UUID(),
                        title: "Boost your \(goal.name) goal",
                        description: "You have \(formatCurrency(totalUnclaimed)) in unclaimed found money. Applying it to '\(goal.name)' would bring you \(formatCurrency(min(totalUnclaimed, goal.remainingAmount))) closer!",
                        type: .savingsSuggestion("Found money allocation"),
                        potentialSavings: min(totalUnclaimed, goal.remainingAmount),
                        isActionable: true
                    ))
                }
            }
        }

        return insights
    }

    private func detectFrequency(from intervalDays: Double) -> RecurringExpense.Frequency {
        switch intervalDays {
        case 5...9: return .weekly
        case 10...18: return .biweekly
        case 25...35: return .monthly
        case 80...100: return .quarterly
        case 350...380: return .yearly
        default: return .monthly
        }
    }

    private func categorizeMerchant(_ merchant: String) -> String {
        let lower = merchant.lowercased()
        if lower.contains("netflix") || lower.contains("spotify") || lower.contains("hulu") {
            return "Entertainment"
        }
        if lower.contains("gym") || lower.contains("fitness") {
            return "Health & Fitness"
        }
        if lower.contains("insurance") {
            return "Insurance"
        }
        if lower.contains("electric") || lower.contains("water") || lower.contains("gas") {
            return "Utilities"
        }
        return "General"
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}

// MARK: - Transaction Entry (minimal transaction model for analysis)

struct TransactionEntry: Equatable {
    let id: UUID
    let merchant: String?
    let description: String
    let amount: Double // Negative = expense, Positive = income
    let date: Date
    let category: String

    init(
        id: UUID = UUID(),
        merchant: String? = nil,
        description: String,
        amount: Double,
        date: Date = Date(),
        category: String = "General"
    ) {
        self.id = id
        self.merchant = merchant
        self.description = description
        self.amount = amount
        self.date = date
        self.category = category
    }
}
