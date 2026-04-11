import SwiftUI

// MARK: - Typography

/// Collection of app typography styles.
struct RisingTypography {
    /// Large display text (34pt bold).
    static let display = Font.system(size: 34, weight: .bold, design: .default)
    /// Primary heading (28pt semibold).
    static let heading1 = Font.system(size: 28, weight: .semibold, design: .default)
    /// Secondary heading (22pt semibold).
    static let heading2 = Font.system(size: 22, weight: .semibold, design: .default)
    /// Tertiary heading (20pt medium).
    static let heading3 = Font.system(size: 20, weight: .medium, design: .default)
    /// Body text (17pt regular).
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    /// Small body text (15pt regular).
    static let bodySmall = Font.system(size: 15, weight: .regular, design: .default)
    /// Caption text (13pt regular).
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
    /// Label text (12pt medium).
    static let label = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Font Modifiers

extension View {
    /// Applies display typography style.
    func risingDisplay() -> some View {
        self.font(RisingTypography.display)
    }

    /// Applies heading1 typography style.
    func risingHeading1() -> some View {
        self.font(RisingTypography.heading1)
    }

    /// Applies heading2 typography style.
    func risingHeading2() -> some View {
        self.font(RisingTypography.heading2)
    }

    /// Applies heading3 typography style.
    func risingHeading3() -> some View {
        self.font(RisingTypography.heading3)
    }

    /// Applies body typography style.
    func risingBody() -> some View {
        self.font(RisingTypography.body)
    }

    /// Applies bodySmall typography style.
    func risingBodySmall() -> some View {
        self.font(RisingTypography.bodySmall)
    }

    /// Applies caption typography style.
    func risingCaption() -> some View {
        self.font(RisingTypography.caption)
    }

    /// Applies label typography style.
    func risingLabel() -> some View {
        self.font(RisingTypography.label)
    }
}
