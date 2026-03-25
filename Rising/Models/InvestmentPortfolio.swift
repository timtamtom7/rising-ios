import Foundation

// MARK: - R7: Investment Portfolio Model

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
        // Simplified: assume 5-year average holding period
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
    var monthlyExpenses: Double  // mortgage, taxes, insurance, maintenance
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

// MARK: - R7: ROI Analysis

struct ROIAnalysis: Identifiable, Codable {
    let id: UUID
    var propertyAddress: String
    var purchasePrice: Double
    var downPayment: Double
    var closingCosts: Double
    var renovationCosts: Double
    var monthlyRent: Double
    var monthlyMortgage: Double
    var propertyTax: Double  // annual
    var insurance: Double  // annual
    var maintenance: Double  // annual estimate
    var vacancyRate: Double  // 0.0 to 1.0
    var appreciationRate: Double  // annual % estimate
    var holdingYears: Int
    var analysisDate: Date
    
    init(
        id: UUID = UUID(),
        propertyAddress: String,
        purchasePrice: Double,
        downPayment: Double,
        closingCosts: Double = 0,
        renovationCosts: Double = 0,
        monthlyRent: Double,
        monthlyMortgage: Double,
        propertyTax: Double = 0,
        insurance: Double = 0,
        maintenance: Double = 0,
        vacancyRate: Double = 0.05,
        appreciationRate: Double = 0.03,
        holdingYears: Int = 5,
        analysisDate: Date = Date()
    ) {
        self.id = id
        self.propertyAddress = propertyAddress
        self.purchasePrice = purchasePrice
        self.downPayment = downPayment
        self.closingCosts = closingCosts
        self.renovationCosts = renovationCosts
        self.monthlyRent = monthlyRent
        self.monthlyMortgage = monthlyMortgage
        self.propertyTax = propertyTax
        self.insurance = insurance
        self.maintenance = maintenance
        self.vacancyRate = vacancyRate
        self.appreciationRate = appreciationRate
        self.holdingYears = holdingYears
        self.analysisDate = analysisDate
    }
    
    // Total cash invested upfront
    var totalCashInvested: Double {
        downPayment + closingCosts + renovationCosts
    }
    
    // Monthly expenses (excluding mortgage principal paydown)
    var totalMonthlyExpenses: Double {
        monthlyMortgage + (propertyTax / 12) + (insurance / 12) + (maintenance / 12)
    }
    
    // Effective monthly rent accounting for vacancy
    var effectiveMonthlyRent: Double {
        monthlyRent * (1 - vacancyRate)
    }
    
    // Monthly cash flow
    var monthlyCashFlow: Double {
        effectiveMonthlyRent - totalMonthlyExpenses
    }
    
    // Annual cash flow
    var annualCashFlow: Double {
        monthlyCashFlow * 12
    }
    
    // Cash-on-cash return
    var cashOnCashReturn: Double {
        guard totalCashInvested > 0 else { return 0 }
        return (annualCashFlow / totalCashInvested) * 100
    }
    
    // Capitalization rate
    var capRate: Double {
        guard purchasePrice > 0 else { return 0 }
        return (annualCashFlow / purchasePrice) * 100
    }
    
    // Future value after appreciation
    var futurePropertyValue: Double {
        purchasePrice * pow(1 + appreciationRate, Double(holdingYears))
    }
    
    // Total appreciation gain
    var appreciationGain: Double {
        futurePropertyValue - purchasePrice
    }
    
    // Loan payoff amount over holding period (simplified)
    var estimatedLoanPayoff: Double {
        let totalPayments = monthlyMortgage * Double(holdingYears) * 12
        let interestPortion = totalPayments * 0.65  // rough estimate
        return purchasePrice - downPayment - interestPortion
    }
    
    // Estimated selling costs (6% typical)
    var sellingCosts: Double {
        futurePropertyValue * 0.06
    }
    
    // Total return over holding period
    var totalReturn: Double {
        let cashFlowTotal = annualCashFlow * Double(holdingYears)
        let equityGain = futurePropertyValue - purchasePrice - estimatedLoanPayoff
        return cashFlowTotal + equityGain - closingCosts - renovationCosts - sellingCosts
    }
    
    // ROI percentage over holding period
    var roiPercentage: Double {
        guard totalCashInvested > 0 else { return 0 }
        return (totalReturn / totalCashInvested) * 100
    }
    
    // Annualized ROI
    var annualizedROI: Double {
        guard holdingYears > 0 else { return 0 }
        return (pow(totalCashInvested + totalReturn, 1.0 / Double(holdingYears)) / totalCashInvested - 1) * 100
    }
    
    // Break-even months (how long until cash flow covers initial investment)
    var breakEvenMonths: Int {
        guard annualCashFlow > 0 else { return Int.max }
        return Int(totalCashInvested / annualCashFlow * 12)
    }
    
    // Debt service coverage ratio
    var debtServiceCoverageRatio: Double {
        guard monthlyMortgage > 0 else { return 0 }
        return effectiveMonthlyRent / monthlyMortgage
    }
}

// MARK: - R7: Market Comparison

struct MarketComparison: Identifiable, Codable {
    let id: UUID
    var propertyAddress: String
    var zestimate: Double?
    var rentZestimate: Double?
    var priceHistory: [PriceHistoryEntry]
    var rentHistory: [RentHistoryEntry]
    var neighborhood: String?
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        propertyAddress: String,
        zestimate: Double? = nil,
        rentZestimate: Double? = nil,
        priceHistory: [PriceHistoryEntry] = [],
        rentHistory: [RentHistoryEntry] = [],
        neighborhood: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.propertyAddress = propertyAddress
        self.zestimate = zestimate
        self.rentZestimate = rentZestimate
        self.priceHistory = priceHistory
        self.rentHistory = rentHistory
        self.neighborhood = neighborhood
        self.updatedAt = updatedAt
    }
}

struct PriceHistoryEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var price: Double
    var event: String  // "Listed", "Sold", "Price Change"
    
    init(id: UUID = UUID(), date: Date, price: Double, event: String) {
        self.id = id
        self.date = date
        self.price = price
        self.event = event
    }
}

struct RentHistoryEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var rent: Double
    
    init(id: UUID = UUID(), date: Date, rent: Double) {
        self.id = id
        self.date = date
        self.rent = rent
    }
}

// MARK: - R7: Portfolio Summary

struct PortfolioSummary: Codable {
    var totalProperties: Int
    var totalInvestment: Double
    var totalCurrentValue: Double
    var totalEquity: Double
    var totalMonthlyCashFlow: Double
    var averageCashOnCashReturn: Double
    var averageCapRate: Double
    var bestPerformingProperty: String?
    var worstPerformingProperty: String?
    
    var totalROI: Double {
        guard totalInvestment > 0 else { return 0 }
        return ((totalCurrentValue - totalInvestment) / totalInvestment) * 100
    }
}
