import Foundation

// MARK: - Property Model (R2)

/// Represents a property being considered for purchase.
struct Property: Identifiable, Codable, Equatable {
    /// Unique identifier for the property.
    let id: UUID
    /// ID of the goal this property is associated with.
    var goalId: UUID
    /// Street address of the property.
    var address: String
    /// Listing price in dollars.
    var price: Double
    /// Optional URL link to the property listing.
    var link: String?
    /// Optional notes about the property.
    var notes: String?
    /// Date when the property was added.
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

    /// Simulated market trend based on address hash for consistent display.
    var marketTrend: MarketTrend {
        // Deterministic trend based on address for consistent display
        let hash = abs(address.hashValue)
        let trends: [MarketTrend] = [.up, .down, .stable]
        return trends[hash % trends.count]
    }

    /// Estimated percentage change in value (-8% to +12%) based on address hash.
    var estimatedValueChange: Double {
        // Deterministic percentage change based on address hash (-8% to +12%)
        let hash = abs(address.hashValue)
        let change = Double(hash % 20) - 8  // -8 to +11
        return Double(change) / 100.0
    }

    /// Formatted price string (e.g., "$500,000").
    var displayPrice: String {
        price.formattedCurrency
    }
}

/// Indicates the direction of market trends for a property.
enum MarketTrend: String {
    /// Market prices are trending upward.
    case up = "up"
    /// Market prices are trending downward.
    case down = "down"
    /// Market prices are stable.
    case stable = "stable"

    /// SF Symbol name representing the trend direction.
    var iconName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    /// Human-readable text describing the trend.
    var displayText: String {
        switch self {
        case .up: return "Trending Up"
        case .down: return "Trending Down"
        case .stable: return "Stable"
        }
    }
}
