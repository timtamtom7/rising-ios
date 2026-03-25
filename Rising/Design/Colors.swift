import SwiftUI

// MARK: - App Colors

extension Color {
    // Primary
    static let risingPrimary = Color(hex: "10B981")
    static let risingPrimaryDark = Color(hex: "059669")

    // Accent
    static let risingAccent = Color(hex: "F59E0B")

    // Dark Mode Surfaces
    static let risingBackgroundDark = Color(hex: "0F172A")
    static let risingSurfaceDark = Color(hex: "1E293B")
    static let risingCardDark = Color(hex: "334155")

    // Light Mode Surfaces
    static let risingBackgroundLight = Color(hex: "F8FAFC")
    static let risingSurfaceLight = Color(hex: "F1F5F9")

    // Text
    static let risingTextPrimaryDark = Color(hex: "F8FAFC")
    static let risingTextSecondaryDark = Color(hex: "94A3B8")
    static let risingTextPrimaryLight = Color(hex: "0F172A")
    static let risingTextSecondaryLight = Color(hex: "64748B")

    // Semantic
    static let risingSuccess = Color(hex: "10B981")
    static let risingWarning = Color(hex: "F59E0B")
    static let risingError = Color(hex: "EF4444")

    // MARK: - Adaptive Colors
    static var risingBackground: Color {
        Color("RisingBackground", bundle: nil)
    }

    static var risingSurface: Color {
        Color("RisingSurface", bundle: nil)
    }

    static var risingCard: Color {
        Color("RisingCard", bundle: nil)
    }

    static var risingTextPrimary: Color {
        Color("RisingTextPrimary", bundle: nil)
    }

    static var risingTextSecondary: Color {
        Color("RisingTextSecondary", bundle: nil)
    }

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Color Assets (Fallbacks when asset catalog not available)

extension Color {
    static var risingBackgroundAdaptive: Color {
        Color(hex: "0F172A") // Dark: #0F172A
    }

    static var risingSurfaceAdaptive: Color {
        Color(hex: "1E293B") // Dark: #1E293B
    }

    static var risingCardAdaptive: Color {
        Color(hex: "334155") // Dark: #334155
    }
}
