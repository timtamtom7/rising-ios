import Foundation

// MARK: - Investment Portfolio Model

struct InvestmentPortfolio: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var properties: [PortfolioProperty]
    var createdAt: Date
    var totalInvestment: Double
    var totalCurrentValue: Double

    var totalROI: Double {
        guard totalInvestment > 0 else { return 0 }
        return ((totalCurrentValue - totalInvestment) / totalInvestment) * 100
    }

    var totalGainLoss: Double {
        totalCurrentValue - totalInvestment
    }

    var annualizedReturn: Double {
        guard totalROI > 0 else { return 0 }
        return (pow(1 + totalROI / 100, 1.0 / 5.0) - 1) * 100
    }

    init(
        id: UUID = UUID(),
        name: String = "My Portfolio",
        properties: [PortfolioProperty] = [],
        createdAt: Date = Date(),
        totalInvestment: Double = 0,
        totalCurrentValue: Double = 0
    ) {
        self.id = id
        self.name = name
        self.properties = properties
        self.createdAt = createdAt
        self.totalInvestment = totalInvestment
        self.totalCurrentValue = totalCurrentValue
    }
}

struct PortfolioProperty: Identifiable, Codable, Equatable {
    let id: UUID
    var propertyId: UUID
    var purchasePrice: Double
    var downPayment: Double
    var purchaseDate: Date
    var monthlyRent: Double
    var monthlyExpenses: Double
    var notes: String?

    init(
        id: UUID = UUID(),
        propertyId: UUID,
        purchasePrice: Double,
        downPayment: Double,
        purchaseDate: Date = Date(),
        monthlyRent: Double = 0,
        monthlyExpenses: Double = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.propertyId = propertyId
        self.purchasePrice = purchasePrice
        self.downPayment = downPayment
        self.purchaseDate = purchaseDate
        self.monthlyRent = monthlyRent
        self.monthlyExpenses = monthlyExpenses
        self.notes = notes
    }

    var cashFlow: Double {
        monthlyRent - monthlyExpenses
    }

    var annualCashFlow: Double {
        cashFlow * 12
    }

    var capRate: Double {
        guard purchasePrice > 0 else { return 0 }
        return (annualCashFlow / purchasePrice) * 100
    }

    var cashOnCashReturn: Double {
        guard downPayment > 0 else { return 0 }
        return (annualCashFlow / downPayment) * 100
    }
}