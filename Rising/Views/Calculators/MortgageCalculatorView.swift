import SwiftUI

struct MortgageCalculatorView: View {
    @State private var homePrice = ""
    @State private var downPaymentPercent = "20"
    @State private var interestRate = "6.5"
    @State private var loanTerm = 30
    @State private var result: MortgageCalculatorService.MortgageResult?
    @State private var showResult = false

    private let calculator = MortgageCalculatorService()

    let propertyPrice: Double?
    let onApplyPrice: ((Double) -> Void)?

    init(propertyPrice: Double? = nil, onApplyPrice: ((Double) -> Void)? = nil) {
        self.propertyPrice = propertyPrice
        self.onApplyPrice = onApplyPrice
        if let price = propertyPrice {
            _homePrice = State(initialValue: String(format: "%.0f", price))
        }
    }

    var body: some View {
        ZStack {
            Color.risingBackgroundDark
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: RisingSpacing.lg) {
                    // Header
                    VStack(spacing: RisingSpacing.xs) {
                        Image(systemName: "house.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.risingPrimary)

                        Text("Mortgage Calculator")
                            .risingHeading1()
                            .foregroundStyle(Color.risingTextPrimaryDark)

                        Text("Estimate your monthly payment")
                            .risingBody()
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                    .padding(.top, RisingSpacing.md)

                    // Inputs
                    VStack(spacing: RisingSpacing.md) {
                        // Home Price
                        InputField(
                            label: "Home Price",
                            value: $homePrice,
                            prefix: "$",
                            placeholder: "350,000",
                            keyboard: .numberPad
                        )

                        // Down Payment
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            HStack {
                                Text("Down Payment")
                                    .risingLabel()
                                    .foregroundStyle(Color.risingTextSecondaryDark)
                                Spacer()
                                Text("\(downPaymentPercent)%")
                                    .risingBody()
                                    .foregroundStyle(Color.risingPrimary)
                            }

                            Slider(
                                value: Binding(
                                    get: { Double(downPaymentPercent) ?? 20 },
                                    set: { downPaymentPercent = String(format: "%.0f", $0) }
                                ),
                                in: 3...50,
                                step: 1
                            )
                            .tint(Color.risingPrimary)

                            HStack {
                                Text("$\(formatNumber(calculatedDownPayment))")
                                    .risingCaption()
                                    .foregroundStyle(Color.risingTextSecondaryDark)
                                Spacer()
                            }
                        }
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                        // Interest Rate
                        InputField(
                            label: "Interest Rate",
                            value: $interestRate,
                            suffix: "%",
                            placeholder: "6.5",
                            keyboard: .decimalPad
                        )

                        // Loan Term
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Loan Term")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            Picker("Loan Term", selection: $loanTerm) {
                                Text("15 years").tag(15)
                                Text("20 years").tag(20)
                                Text("30 years").tag(30)
                            }
                            .pickerStyle(.segmented)
                            .tint(Color.risingPrimary)
                        }
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }
                    .padding(.horizontal, RisingSpacing.md)

                    // Calculate Button
                    Button {
                        calculate()
                    } label: {
                        HStack {
                            Image(systemName: "equal.circle.fill")
                            Text("Calculate")
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, RisingSpacing.md)
                        .background(Color.risingPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                    }
                    .padding(.horizontal, RisingSpacing.md)

                    // Results
                    if showResult, let result = result {
                        resultsSection(result)
                    }

                    Spacer(minLength: RisingSpacing.xl)
                }
            }
        }
    }

    private func resultsSection(_ result: MortgageCalculatorService.MortgageResult) -> some View {
        VStack(spacing: RisingSpacing.md) {
            // Monthly Payment Highlight
            VStack(spacing: RisingSpacing.xs) {
                Text("Estimated Monthly Payment")
                    .risingLabel()
                    .foregroundStyle(Color.risingTextSecondaryDark)

                Text(formatCurrency(result.monthlyPayment))
                    .risingDisplay()
                    .foregroundStyle(Color.risingPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RisingSpacing.lg)
            .background(Color.risingPrimary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))

            // Breakdown
            VStack(spacing: RisingSpacing.sm) {
                BreakdownRow(title: "Principal & Interest", value: formatCurrency(result.monthlyPayment - result.tax - result.insurance))
                Divider().background(Color.risingCardDark)
                BreakdownRow(title: "Property Tax (monthly)", value: formatCurrency(result.tax))
                Divider().background(Color.risingCardDark)
                BreakdownRow(title: "Home Insurance (monthly)", value: formatCurrency(result.insurance))
                Divider().background(Color.risingCardDark)
                BreakdownRow(title: "Loan Amount", value: formatCurrency(result.principal))
                Divider().background(Color.risingCardDark)
                BreakdownRow(title: "Total Interest", value: formatCurrency(result.totalInterest))
                Divider().background(Color.risingCardDark)
                BreakdownRow(title: "Total Payment", value: formatCurrency(result.totalPayment), isBold: true)
            }
            .padding(RisingSpacing.md)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))

            // Affordability Note
            let affordable = calculator.affordableHomePrice(
                monthlyBudget: result.monthlyPayment,
                downPaymentPercent: Double(downPaymentPercent) ?? 20,
                interestRate: Double(interestRate) ?? 6.5,
                loanTermYears: loanTerm
            )
            if affordable > (Double(homePrice) ?? 0) {
                HStack(spacing: RisingSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.risingSuccess)
                    Text("This home is within your budget!")
                        .risingCaption()
                        .foregroundStyle(Color.risingSuccess)
                }
                .padding(RisingSpacing.md)
                .background(Color.risingSuccess.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
            } else {
                HStack(spacing: RisingSpacing.sm) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(Color.risingWarning)
                    Text("Consider a \u{201C}need\u{201D} of \(formatCurrency(affordable)) with this payment.")
                        .risingCaption()
                        .foregroundStyle(Color.risingWarning)
                }
                .padding(RisingSpacing.md)
                .background(Color.risingWarning.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
            }
        }
        .padding(.horizontal, RisingSpacing.md)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private var calculatedDownPayment: Double {
        let price = Double(homePrice) ?? 0
        let percent = Double(downPaymentPercent) ?? 20
        return price * (percent / 100)
    }

    private func calculate() {
        guard let price = Double(homePrice), price > 0,
              let rate = Double(interestRate), rate > 0 else { return }

        result = calculator.calculate(
            homePrice: price,
            downPaymentPercent: Double(downPaymentPercent) ?? 20,
            interestRate: rate,
            loanTermYears: loanTerm
        )

        withAnimation(.easeOut(duration: 0.4)) {
            showResult = true
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

// MARK: - Input Field

struct InputField: View {
    let label: String
    @Binding var value: String
    var prefix: String? = nil
    var suffix: String? = nil
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
            Text(label)
                .risingLabel()
                .foregroundStyle(Color.risingTextSecondaryDark)

            HStack {
                if let prefix = prefix {
                    Text(prefix)
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }

                TextField(placeholder, text: $value)
                    .font(.body)
                    .foregroundStyle(Color.risingTextPrimaryDark)
                    .keyboardType(keyboard)
                    .tint(Color.risingPrimary)

                if let suffix = suffix {
                    Text(suffix)
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }
            .padding(RisingSpacing.md)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
        }
    }
}

// MARK: - Breakdown Row

struct BreakdownRow: View {
    let title: String
    let value: String
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(isBold ? .body.weight(.semibold) : .body)
                .foregroundStyle(isBold ? Color.risingTextPrimaryDark : Color.risingTextSecondaryDark)

            Spacer()

            Text(value)
                .font(isBold ? .body.weight(.semibold) : .body)
                .foregroundStyle(isBold ? Color.risingPrimary : Color.risingTextPrimaryDark)
        }
    }
}

#Preview {
    MortgageCalculatorView()
}
