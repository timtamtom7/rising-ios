import Foundation

// MARK: - Mortgage Calculator Service

@MainActor
final class MortgageCalculatorService {

    struct MortgageResult {
        let monthlyPayment: Double
        let totalInterest: Double
        let totalPayment: Double
        let principal: Double
        let interest: Double
        let tax: Double
        let insurance: Double
    }

    /// Calculate estimated monthly mortgage payment
    /// - Parameters:
    ///   - homePrice: Total home price
    ///   - downPaymentPercent: Down payment as percentage (e.g., 20 for 20%)
    ///   - interestRate: Annual interest rate as percentage (e.g., 6.5 for 6.5%)
    ///   - loanTermYears: Loan term in years (default 30)
    ///   - annualPropertyTax: Annual property tax amount
    ///   - annualInsurance: Annual home insurance amount
    /// - Returns: MortgageResult with payment breakdown
    func calculate(
        homePrice: Double,
        downPaymentPercent: Double,
        interestRate: Double,
        loanTermYears: Int = 30,
        annualPropertyTax: Double? = nil,
        annualInsurance: Double? = nil
    ) -> MortgageResult {
        let downPayment = homePrice * (downPaymentPercent / 100.0)
        let loanAmount = homePrice - downPayment
        let monthlyRate = (interestRate / 100.0) / 12.0
        let numberOfPayments = Double(loanTermYears * 12)

        // Monthly principal & interest (standard amortization formula)
        let monthlyPI: Double
        if monthlyRate > 0 {
            let factor = pow(1 + monthlyRate, numberOfPayments)
            monthlyPI = loanAmount * (monthlyRate * factor) / (factor - 1)
        } else {
            monthlyPI = loanAmount / numberOfPayments
        }

        let monthlyTax = (annualPropertyTax ?? (homePrice * 0.0125)) / 12.0 // ~1.25% default tax rate
        let monthlyInsurance = (annualInsurance ?? (homePrice * 0.004)) / 12.0 // ~0.4% default insurance
        let totalMonthly = monthlyPI + monthlyTax + monthlyInsurance
        let totalPayment = totalMonthly * numberOfPayments
        let totalInterest = (monthlyPI * numberOfPayments) - loanAmount

        return MortgageResult(
            monthlyPayment: totalMonthly,
            totalInterest: totalInterest,
            totalPayment: totalPayment,
            principal: loanAmount,
            interest: totalInterest,
            tax: monthlyTax,
            insurance: monthlyInsurance
        )
    }

    /// Calculate how much house you can afford based on monthly budget
    func affordableHomePrice(
        monthlyBudget: Double,
        downPaymentPercent: Double,
        interestRate: Double,
        loanTermYears: Int = 30
    ) -> Double {
        let monthlyRate = (interestRate / 100.0) / 12.0
        let numberOfPayments = Double(loanTermYears * 12)

        // Approximate: budget covers P&I, taxes (~1.25%), insurance (~0.4%)
        // So P&I portion ≈ budget * 0.70 (rough estimate)
        let monthlyPIBudget = monthlyBudget * 0.70
        let downPaymentFraction = downPaymentPercent / 100.0

        let loanAmount: Double
        if monthlyRate > 0 {
            let factor = pow(1 + monthlyRate, numberOfPayments)
            let monthlyPI = monthlyPIBudget
            loanAmount = monthlyPI * (factor - 1) / (monthlyRate * factor)
        } else {
            loanAmount = monthlyPIBudget * numberOfPayments
        }

        // homePrice = loanAmount / (1 - downPaymentPercent)
        return loanAmount / (1.0 - downPaymentFraction)
    }
}
