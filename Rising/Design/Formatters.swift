import Foundation

/// Collection of formatting utilities for display.
enum RisingFormatters {
    /// Currency formatter for USD with no decimal places.
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Decimal formatter with no decimal places.
    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    /// Date formatter for medium date style (e.g., "Jan 1, 2024").
    static let dateMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    /// Date formatter for short month format (e.g., "Jan").
    static let shortMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()

    /// Date formatter for month and year (e.g., "Jan 2024").
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
}

/// Extension for formatting Double values.
extension Double {
    /// Returns the value formatted as USD currency (e.g., "$500,000").
    var formattedCurrency: String {
        RisingFormatters.currency.string(from: NSNumber(value: self)) ?? "$0"
    }

    /// Returns the value formatted as a decimal string (e.g., "500,000").
    var formattedDecimal: String {
        RisingFormatters.decimal.string(from: NSNumber(value: self)) ?? "0"
    }
}
