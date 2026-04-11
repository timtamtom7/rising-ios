import Foundation

// MARK: - Market Comparison

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
    var event: String

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