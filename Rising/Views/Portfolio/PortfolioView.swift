import SwiftUI

// MARK: - R7: Portfolio View

struct PortfolioView: View {
    @State private var portfolios: [InvestmentPortfolio] = []
    @State private var showingAddPortfolio = false
    @State private var showingAddProperty = false
    @State private var selectedPortfolio: InvestmentPortfolio?
    
    var body: some View {
        ZStack {
            Color.risingBackgroundDark.ignoresSafeArea()
            
            if portfolios.isEmpty {
                emptyState
            } else {
                portfolioList
            }
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddPortfolio = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.risingPrimary)
                }
            }
        }
        .sheet(isPresented: $showingAddPortfolio) {
            CreatePortfolioSheet(portfolios: $portfolios)
        }
        .sheet(item: $selectedPortfolio) { portfolio in
            PortfolioDetailSheet(portfolio: portfolio, portfolios: $portfolios)
        }
        .onAppear {
            loadPortfolios()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.columns")
                .font(.system(size: 56))
                .foregroundStyle(Color.risingTextSecondaryDark)
            
            Text("No investment portfolios yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.risingTextPrimaryDark)
            
            Text("Track your investment properties\nand see your total returns.")
                .font(.body)
                .foregroundStyle(Color.risingTextSecondaryDark)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddPortfolio = true
            } label: {
                Text("Create Portfolio")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.risingPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding(32)
    }
    
    private var portfolioList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(portfolios) { portfolio in
                    PortfolioCard(portfolio: portfolio)
                        .onTapGesture {
                            selectedPortfolio = portfolio
                        }
                }
            }
            .padding(16)
        }
        .refreshable {
            loadPortfolios()
        }
    }
    
    private func loadPortfolios() {
        portfolios = (try? UserDefaults.standard.getPortfolio()) ?? []
    }
}

// MARK: - Portfolio Card

struct PortfolioCard: View {
    let portfolio: InvestmentPortfolio
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(portfolio.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimaryDark)
                    
                    Text("\(portfolio.properties.count) properties")
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }
            
            // Summary metrics
            HStack(spacing: 24) {
                metricItem(
                    title: "Total Value",
                    value: "$\(Int(portfolio.totalCurrentValue / 1000))K",
                    color: .risingPrimary
                )
                
                Divider().frame(height: 40)
                
                metricItem(
                    title: "ROI",
                    value: "\(String(format: "%.1f", portfolio.totalROI))%",
                    color: portfolio.totalROI >= 0 ? Color.risingSuccess : Color.risingError
                )
                
                Divider().frame(height: 40)
                
                metricItem(
                    title: "Cash Flow",
                    value: "$\(Int(portfolio.totalGainLoss / 1000))K",
                    color: portfolio.totalGainLoss >= 0 ? Color.risingSuccess : Color.risingError
                )
            }
        }
        .padding(16)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func metricItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.risingTextSecondaryDark)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Create Portfolio Sheet

struct CreatePortfolioSheet: View {
    @Binding var portfolios: [InvestmentPortfolio]
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    TextField("Portfolio Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(Color.risingTextPrimaryDark)
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("New Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let portfolio = InvestmentPortfolio(name: name.isEmpty ? "My Portfolio" : name)
                        portfolios.append(portfolio)
                        savePortfolios()
                        dismiss()
                    }
                    .foregroundStyle(Color.risingPrimary)
                }
            }
        }
    }
    
    private func savePortfolios() {
        try? UserDefaults.standard.savePortfolio(portfolios)
    }
}

// MARK: - Portfolio Detail Sheet

struct PortfolioDetailSheet: View {
    let portfolio: InvestmentPortfolio
    @Binding var portfolios: [InvestmentPortfolio]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overview
                        VStack(spacing: 12) {
                            HStack(spacing: 24) {
                                VStack(spacing: 4) {
                                    Text("$\(Int(portfolio.totalCurrentValue / 1000))K")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.risingTextPrimaryDark)
                                    Text("Total Value")
                                        .font(.caption)
                                        .foregroundStyle(Color.risingTextSecondaryDark)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("\(String(format: "%.1f", portfolio.totalROI))%")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(portfolio.totalROI >= 0 ? Color.risingSuccess : Color.risingError)
                                    Text("Total ROI")
                                        .font(.caption)
                                        .foregroundStyle(Color.risingTextSecondaryDark)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Properties
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Properties (\(portfolio.properties.count))")
                                .font(.headline)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                            
                            if portfolio.properties.isEmpty {
                                Text("No properties in this portfolio yet.")
                                    .font(.body)
                                    .foregroundStyle(Color.risingTextSecondaryDark)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(portfolio.properties) { prop in
                                    PortfolioPropertyRow(property: prop)
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(16)
                }
            }
            .navigationTitle(portfolio.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.risingPrimary)
                }
            }
        }
    }
}

struct PortfolioPropertyRow: View {
    let property: PortfolioProperty
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Property \(property.propertyId.uuidString.prefix(6))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingTextPrimaryDark)
                
                Spacer()
                
                Text("\(String(format: "%.1f", property.cashOnCashReturn))% CoC")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(property.cashOnCashReturn >= 0 ? Color.risingSuccess : Color.risingError)
            }
            
            HStack(spacing: 16) {
                Text("$\(Int(property.purchasePrice / 1000))K purchase")
                    .font(.caption)
                    .foregroundStyle(Color.risingTextSecondaryDark)
                
                Text("$\(Int(property.cashFlow))/mo cash flow")
                    .font(.caption)
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }
        }
        .padding(12)
        .background(Color.risingBackgroundDark)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    private static let portfolioKey = "rising_investment_portfolios"
    
    func getPortfolio() throws -> [InvestmentPortfolio]? {
        guard let data = data(forKey: Self.portfolioKey) else { return nil }
        return try JSONDecoder().decode([InvestmentPortfolio].self, from: data)
    }
    
    func savePortfolio(_ portfolios: [InvestmentPortfolio]) throws {
        let data = try JSONEncoder().encode(portfolios)
        set(data, forKey: Self.portfolioKey)
    }
}

#Preview {
    NavigationStack {
        PortfolioView()
    }
}
