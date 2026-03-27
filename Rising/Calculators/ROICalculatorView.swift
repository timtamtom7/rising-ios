import SwiftUI

struct ROICalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Property info
    @State private var propertyAddress = ""
    @State private var purchasePrice = ""
    @State private var downPayment = ""
    @State private var closingCosts = ""
    @State private var renovationCosts = ""
    
    // Income
    @State private var monthlyRent = ""
    @State private var monthlyMortgage = ""
    
    // Expenses
    @State private var propertyTax = ""
    @State private var insurance = ""
    @State private var maintenance = ""
    @State private var vacancyRate = "5"
    
    // Assumptions
    @State private var appreciationRate = "3"
    @State private var holdingYears = "5"
    
    // Results
    @State private var showingResults = false
    @State private var analysis: ROIAnalysis?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        propertySection
                        incomeSection
                        expensesSection
                        assumptionsSection
                        calculateButton
                    }
                    .padding(16)
                }
            }
            .navigationTitle("ROI Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.risingPrimary)
                }
            }
            .sheet(isPresented: $showingResults) {
                if let analysis = analysis {
                    ROIResultsView(analysis: analysis)
                }
            }
        }
    }
    
    private var propertySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Property Details", icon: "house")
            
            textField(label: "Property Address", text: $propertyAddress, placeholder: "123 Main St, City, State")
            
            HStack(spacing: 12) {
                textField(label: "Purchase Price", text: $purchasePrice, placeholder: "$350,000", keyboard: .numberPad, prefix: "$")
                textField(label: "Down Payment", text: $downPayment, placeholder: "$70,000", keyboard: .numberPad, prefix: "$")
            }
            
            HStack(spacing: 12) {
                textField(label: "Closing Costs", text: $closingCosts, placeholder: "$10,000", keyboard: .numberPad, prefix: "$")
                textField(label: "Renovation", text: $renovationCosts, placeholder: "$15,000", keyboard: .numberPad, prefix: "$")
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Monthly Income", icon: "arrow.down.circle")
            
            HStack(spacing: 12) {
                textField(label: "Monthly Rent", text: $monthlyRent, placeholder: "$2,500", keyboard: .numberPad, prefix: "$")
                textField(label: "Mortgage (P&I)", text: $monthlyMortgage, placeholder: "$1,800", keyboard: .numberPad, prefix: "$")
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Annual Expenses", icon: "arrow.up.circle")
            
            HStack(spacing: 12) {
                textField(label: "Property Tax/yr", text: $propertyTax, placeholder: "$4,200", keyboard: .numberPad, prefix: "$")
                textField(label: "Insurance/yr", text: $insurance, placeholder: "$1,500", keyboard: .numberPad, prefix: "$")
            }
            
            HStack(spacing: 12) {
                textField(label: "Maintenance/yr", text: $maintenance, placeholder: "$2,000", keyboard: .numberPad, prefix: "$")
                textField(label: "Vacancy Rate", text: $vacancyRate, placeholder: "5", keyboard: .decimalPad, suffix: "%")
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var assumptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Assumptions", icon: "slider.horizontal.3")
            
            HStack(spacing: 12) {
                textField(label: "Appreciation Rate", text: $appreciationRate, placeholder: "3", keyboard: .decimalPad, suffix: "%/yr")
                textField(label: "Holding Period", text: $holdingYears, placeholder: "5", keyboard: .numberPad, suffix: "yrs")
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var calculateButton: some View {
        Button {
            calculate()
        } label: {
            Text("Calculate ROI")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.risingBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canCalculate ? Color.risingPrimary : Color.risingTextSecondary)
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        }
        .disabled(!canCalculate)
    }
    
    private var canCalculate: Bool {
        !purchasePrice.isEmpty && !downPayment.isEmpty && !monthlyRent.isEmpty && !monthlyMortgage.isEmpty
    }
    
    private func calculate() {
        let analysis = ROIAnalysis(
            propertyAddress: propertyAddress,
            purchasePrice: Double(purchasePrice) ?? 0,
            downPayment: Double(downPayment) ?? 0,
            closingCosts: Double(closingCosts) ?? 0,
            renovationCosts: Double(renovationCosts) ?? 0,
            monthlyRent: Double(monthlyRent) ?? 0,
            monthlyMortgage: Double(monthlyMortgage) ?? 0,
            propertyTax: Double(propertyTax) ?? 0,
            insurance: Double(insurance) ?? 0,
            maintenance: Double(maintenance) ?? 0,
            vacancyRate: (Double(vacancyRate) ?? 5) / 100,
            appreciationRate: (Double(appreciationRate) ?? 3) / 100,
            holdingYears: Int(holdingYears) ?? 5
        )
        self.analysis = analysis
        showingResults = true
    }
    
    @ViewBuilder
    private func textField(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default, prefix: String = "", suffix: String = "") -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.risingTextSecondary)
            
            HStack {
                if !prefix.isEmpty {
                    Text(prefix)
                        .foregroundColor(.risingTextSecondary)
                }
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .foregroundColor(.risingTextPrimary)
                if !suffix.isEmpty {
                    Text(suffix)
                        .foregroundColor(.risingTextSecondary)
                }
            }
            .padding(12)
            .background(Color.risingBackground)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
        }
    }
    
    @ViewBuilder
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.risingPrimary)
            Text(title)
                .font(.headline)
                .foregroundColor(.risingTextPrimary)
        }
    }
}

struct ROIResultsView: View {
    let analysis: ROIAnalysis
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        roiOverviewCard
                        cashFlowCard
                        returnsCard
                        metricsCard
                        breakdownCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("ROI Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.risingPrimary)
                }
            }
        }
    }
    
    private var roiOverviewCard: some View {
        VStack(spacing: 16) {
            Text("\(String(format: "%.1f", analysis.roiPercentage))%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(analysis.roiPercentage >= 0 ? .risingPrimary : .risingError)
            
            Text("Total ROI over \(analysis.holdingYears) years")
                .font(.subheadline)
                .foregroundColor(.risingTextSecondary)
            
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("$\(Int(analysis.totalReturn))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.risingTextPrimary)
                    Text("Total Return")
                        .font(.caption)
                        .foregroundColor(.risingTextSecondary)
                }
                
                Divider().frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("$\(Int(analysis.totalCashInvested))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.risingTextPrimary)
                    Text("Cash Invested")
                        .font(.caption)
                        .foregroundColor(.risingTextSecondary)
                }
                
                Divider().frame(height: 40)
                
                VStack(spacing: 4) {
                    Text("\(Int(analysis.breakEvenMonths))mo")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.risingTextPrimary)
                    Text("Break Even")
                        .font(.caption)
                        .foregroundColor(.risingTextSecondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var cashFlowCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.risingPrimary)
                Text("Cash Flow")
                    .font(.headline)
                    .foregroundColor(.risingTextPrimary)
            }
            
            HStack(spacing: 16) {
                metricItem(title: "Monthly", value: "$\(Int(analysis.monthlyCashFlow))", color: analysis.monthlyCashFlow >= 0 ? .risingPrimary : .risingError)
                metricItem(title: "Annual", value: "$\(Int(analysis.annualCashFlow))", color: analysis.annualCashFlow >= 0 ? .risingPrimary : .risingError)
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var returnsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.risingPrimary)
                Text("Returns")
                    .font(.headline)
                    .foregroundColor(.risingTextPrimary)
            }
            
            HStack(spacing: 16) {
                metricItem(title: "Cash-on-Cash", value: "\(String(format: "%.1f", analysis.cashOnCashReturn))%", color: .risingTextPrimary)
                metricItem(title: "Cap Rate", value: "\(String(format: "%.2f", analysis.capRate))%", color: .risingTextPrimary)
                metricItem(title: "Ann. ROI", value: "\(String(format: "%.1f", analysis.annualizedROI))%", color: analysis.annualizedROI >= 0 ? .risingPrimary : .risingError)
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var metricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .foregroundColor(.risingPrimary)
                Text("Metrics")
                    .font(.headline)
                    .foregroundColor(.risingTextPrimary)
            }
            
            HStack(spacing: 16) {
                metricItem(title: "DSCR", value: String(format: "%.2f", analysis.debtServiceCoverageRatio), color: analysis.debtServiceCoverageRatio >= 1 ? .risingPrimary : .risingWarning)
                metricItem(title: "Future Value", value: "$\(Int(analysis.futurePropertyValue / 1000))K", color: .risingTextPrimary)
                metricItem(title: "Appr. Gain", value: "$\(Int(analysis.appreciationGain / 1000))K", color: .risingPrimary)
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.risingPrimary)
                Text("Investment Breakdown")
                    .font(.headline)
                    .foregroundColor(.risingTextPrimary)
            }
            
            VStack(spacing: 8) {
                breakdownRow(label: "Down Payment", value: analysis.downPayment)
                breakdownRow(label: "Closing Costs", value: analysis.closingCosts)
                breakdownRow(label: "Renovation", value: analysis.renovationCosts)
                breakdownRow(label: "Selling Costs (est.)", value: analysis.sellingCosts)
                Divider().background(Color.risingTextSecondary)
                breakdownRow(label: "Total Investment", value: analysis.totalCashInvested, bold: true)
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }
    
    private func metricItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.risingTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func breakdownRow(label: String, value: Double, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(bold ? .semibold : .regular)
                .foregroundColor(.risingTextPrimary)
            Spacer()
            Text("$\(Int(value).formatted())")
                .font(.caption)
                .fontWeight(bold ? .semibold : .regular)
                .foregroundColor(.risingTextPrimary)
        }
    }
}

#Preview {
    ROICalculatorView()
}
