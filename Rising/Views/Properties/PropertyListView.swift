import SwiftUI

struct PropertyListView: View {
    @State private var viewModel: PropertyListViewModel
    @State private var showAddProperty = false

    let goal: Goal

    init(goal: Goal) {
        self.goal = goal
        _viewModel = State(initialValue: PropertyListViewModel(goalId: goal.id))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.properties.isEmpty {
                emptyState
            } else {
                propertyList
            }
        }
        .padding(.horizontal, RisingSpacing.md)
        .sheet(isPresented: $showAddProperty) {
            AddPropertyView(goalId: goal.id) {
                Task { await viewModel.load() }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var emptyState: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "house")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("No properties yet")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Button {
                showAddProperty = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Property")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, RisingSpacing.lg)
                .padding(.vertical, RisingSpacing.sm)
                .background(Color.risingPrimary)
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RisingSpacing.xl)
    }

    private var propertyList: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.md) {
            HStack {
                Text("Properties")
                    .risingHeading2()
                    .foregroundStyle(Color.risingTextPrimaryDark)

                Spacer()

                Button {
                    showAddProperty = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.risingPrimary)
                }
            }

            ForEach(viewModel.properties) { property in
                PropertyCardView(property: property) {
                    Task { await viewModel.delete(property) }
                }
            }
        }
    }
}

// MARK: - Property Card View

struct PropertyCardView: View {
    let property: Property
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundStyle(Color.risingPrimary)

                Text(property.address)
                    .risingBody()
                    .foregroundStyle(Color.risingTextPrimaryDark)
                    .lineLimit(2)

                Spacer()

                if let link = property.link, !link.isEmpty {
                    Link(destination: URL(string: link) ?? URL(string: "https://example.com")!) {
                        Image(systemName: "link")
                            .foregroundStyle(Color.risingAccent)
                    }
                }
            }

            HStack {
                Text(property.displayPrice)
                    .risingHeading3()
                    .foregroundStyle(Color.risingPrimary)

                // R6: Market trend badge
                let trendColor: Color = {
                    switch property.marketTrend {
                    case .up: return .green
                    case .down: return .red
                    case .stable: return .gray
                    }
                }()
                HStack(spacing: 2) {
                    Image(systemName: property.marketTrend.iconName)
                        .font(.caption2)
                    Text(String(format: "%.1f%%", property.estimatedValueChange * 100))
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(trendColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(trendColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()

                if property.price > 0 {
                    let downPayment = property.price * 0.20
                    Text("20% down: \(formatCurrency(downPayment))")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }

            if let notes = property.notes, !notes.isEmpty {
                Text(notes)
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .lineLimit(2)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    PropertyListView(goal: Goal(name: "House", targetAmount: 50000))
        .background(Color.risingBackgroundDark)
}
