import SwiftUI
import UIKit

// MARK: - App Colors

extension Color {
    // MARK: - Primary Colors
    /// Primary brand color (emerald green).
    static let risingPrimary = Color(hex: "10B981")
    /// Dark variant of primary brand color.
    static let risingPrimaryDark = Color(hex: "059669")

    // MARK: - Accent
    /// Accent color (amber) for highlights and calls-to-action.
    static let risingAccent = Color(hex: "F59E0B")

    // MARK: - Dark Mode Surfaces
    /// Dark mode background color.
    static let risingBackgroundDark = Color(hex: "0F172A")
    /// Dark mode surface color for cards and elevated elements.
    static let risingSurfaceDark = Color(hex: "1E293B")
    /// Dark mode card background color.
    static let risingCardDark = Color(hex: "334155")

    // MARK: - Light Mode Surfaces
    /// Light mode background color.
    static let risingBackgroundLight = Color(hex: "F8FAFC")
    /// Light mode surface color.
    static let risingSurfaceLight = Color(hex: "F1F5F9")

    // MARK: - Text Colors (Dark Mode)
    /// Primary text color for dark mode.
    static let risingTextPrimaryDark = Color(hex: "F8FAFC")
    /// Secondary text color for dark mode.
    static let risingTextSecondaryDark = Color(hex: "94A3B8")

    // MARK: - Text Colors (Light Mode)
    /// Primary text color for light mode.
    static let risingTextPrimaryLight = Color(hex: "0F172A")
    /// Secondary text color for light mode.
    static let risingTextSecondaryLight = Color(hex: "64748B")

    // MARK: - Semantic Colors
    /// Success state color (emerald green).
    static let risingSuccess = Color(hex: "10B981")
    /// Warning state color (amber).
    static let risingWarning = Color(hex: "F59E0B")
    /// Error state color (red).
    static let risingError = Color(hex: "EF4444")

    // MARK: - Adaptive Colors
    /// Background color that adapts to light/dark mode.
    static var risingBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0)
                : UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1.0)
        })
    }

    /// Surface color that adapts to light/dark mode.
    static var risingSurface: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.118, green: 0.161, blue: 0.231, alpha: 1.0)
                : UIColor(red: 0.945, green: 0.961, blue: 0.976, alpha: 1.0)
        })
    }

    static var risingCard: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.200, green: 0.255, blue: 0.333, alpha: 1.0)
                : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        })
    }

    static var risingTextPrimary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1.0)
                : UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0)
        })
    }

    static var risingTextSecondary: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.580, green: 0.639, blue: 0.722, alpha: 1.0)
                : UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0)
        })
    }

    // MARK: - Hex Initializer
    /// Creates a color from a hexadecimal string.
    /// - Parameter hex: Hex color string (e.g., "10B981" or "#10B981").
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

// MARK: - ShapeStyle Extensions

extension ShapeStyle where Self == Color {
    /// Primary brand color as a ShapeStyle.
    static var risingPrimary: Color { Color.risingPrimary }
    /// Dark primary brand color as a ShapeStyle.
    static var risingPrimaryDark: Color { Color.risingPrimaryDark }
    /// Accent color as a ShapeStyle.
    static var risingAccent: Color { Color.risingAccent }
    /// Adaptive background color as a ShapeStyle.
    static var risingBackground: Color { Color.risingBackground }
    /// Adaptive surface color as a ShapeStyle.
    static var risingSurface: Color { Color.risingSurface }
    /// Adaptive card color as a ShapeStyle.
    static var risingCard: Color { Color.risingCard }
    /// Adaptive primary text color as a ShapeStyle.
    static var risingTextPrimary: Color { Color.risingTextPrimary }
    /// Adaptive secondary text color as a ShapeStyle.
    static var risingTextSecondary: Color { Color.risingTextSecondary }
    /// Success color as a ShapeStyle.
    static var risingSuccess: Color { Color.risingSuccess }
    /// Warning color as a ShapeStyle.
    static var risingWarning: Color { Color.risingWarning }
    /// Error color as a ShapeStyle.
    static var risingError: Color { Color.risingError }
}
