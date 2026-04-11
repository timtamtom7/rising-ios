import Foundation

// MARK: - ROI Analysis

struct ROIAnalysis: Identifiable, Codable {
    let id: UUID
    var propertyAddress: String
    var purchasePrice: Double
    var downPayment: Double
    var closingCosts: Double
    var renovationCosts: Double
    var monthlyRent: Double
    var monthlyMortgage: Double
    var propertyTax: Double
    var insurance: Double
    var maintenance: Double
    var vacancyRate: Double
    var appreciationRate: Double
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

    var totalCashInvested: Double {
        downPayment + closingCosts + renovationCosts
    }

    var totalMonthlyExpenses: Double {
        monthlyMortgage + (propertyTax / 12) + (insurance / 12) + (maintenance / 12)
    }

    var effectiveMonthlyRent: Double {
        monthlyRent * (1 - vacancyRate)
    }

    var monthlyCashFlow: Double {
        effectiveMonthlyRent - totalMonthlyExpenses
    }

    var annualCashFlow: Double {
        monthlyCashFlow * 12
    }

    var cashOnCashReturn: Double {
        guard totalCashInvested > 0 else { return 0 }
        return (annualCashFlow / totalCashInvested) * 100
    }

    var capRate: Double {
        guard purchasePrice > 0 else { return 0 }
        return (annualCashFlow / purchasePrice) * 100
    }

    var futurePropertyValue: Double {
        purchasePrice * pow(1 + appreciationRate, Double(holdingYears))
    }

    var appreciationGain: Double {
        futurePropertyValue - purchasePrice
    }

    var estimatedLoanPayoff: Double {
        let totalPayments = monthlyMortgage * Double(holdingYears) * 12
        let interestPortion = totalPayments * 0.65
        return purchasePrice - downPayment - interestPortion
    }

    var sellingCosts: Double {
        futurePropertyValue * 0.06
    }

    var totalReturn: Double {
        let cashFlowTotal = annualCashFlow * Double(holdingYears)
        let equityGain = futurePropertyValue - purchasePrice - estimatedLoanPayoff
        return cashFlowTotal + equityGain - closingCosts - renovationCosts - sellingCosts
    }

    var roiPercentage: Double {
        guard totalCashInvested > 0 else { return 0 }
        return (totalReturn / totalCashInvested) * 100
    }

    var annualizedROI: Double {
        guard holdingYears > 0 else { return 0 }
        return (pow(totalCashInvested + totalReturn, 1.0 / Double(holdingYears)) / totalCashInvested - 1) * 100
    }

    var breakEvenMonths: Int {
        guard annualCashFlow > 0 else { return Int.max }
        return Int(totalCashInvested / annualCashFlow * 12)
    }

    var debtServiceCoverageRatio: Double {
        guard monthlyMortgage > 0 else { return 0 }
        return effectiveMonthlyRent / monthlyMortgage
    }
}

// MARK: - Portfolio Summary

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