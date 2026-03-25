import Foundation

// MARK: - Property Model (R2)

struct Property: Identifiable, Codable, Equatable {
    let id: UUID
    var goalId: UUID
    var address: String
    var price: Double
    var link: String?
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        goalId: UUID,
        address: String,
        price: Double,
        link: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.address = address
        self.price = price
        self.link = link
        self.notes = notes
        self.createdAt = createdAt
    }

    // R5: Simulated market data — based on neighborhood trends seeded by address hash
    var marketTrend: MarketTrend {
        // Deterministic trend based on address for consistent display
        let hash = abs(address.hashValue)
        let trends: [MarketTrend] = [.up, .down, .stable]
        return trends[hash % trends.count]
    }

    var estimatedValueChange: Double {
        // Deterministic percentage change based on address hash (-8% to +12%)
        let hash = abs(address.hashValue)
        let change = Double(hash % 20) - 8  // -8 to +11
        return Double(change) / 100.0
    }

    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$\(Int(price))"
    }
}

// R5: Market trend indicator
enum MarketTrend: String {
    case up = "up"
    case down = "down"
    case stable = "stable"

    var iconName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    var displayText: String {
        switch self {
        case .up: return "Trending Up"
        case .down: return "Trending Down"
        case .stable: return "Stable"
        }
    }
}
