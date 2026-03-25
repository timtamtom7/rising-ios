import SwiftUI

// MARK: - Typography

struct RisingTypography {
    static let display = Font.system(size: 34, weight: .bold, design: .default)
    static let heading1 = Font.system(size: 28, weight: .semibold, design: .default)
    static let heading2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let heading3 = Font.system(size: 20, weight: .medium, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
    static let label = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Font Modifiers

extension View {
    func risingDisplay() -> some View {
        self.font(RisingTypography.display)
    }

    func risingHeading1() -> some View {
        self.font(RisingTypography.heading1)
    }

    func risingHeading2() -> some View {
        self.font(RisingTypography.heading2)
    }

    func risingHeading3() -> some View {
        self.font(RisingTypography.heading3)
    }

    func risingBody() -> some View {
        self.font(RisingTypography.body)
    }

    func risingBodySmall() -> some View {
        self.font(RisingTypography.bodySmall)
    }

    func risingCaption() -> some View {
        self.font(RisingTypography.caption)
    }

    func risingLabel() -> some View {
        self.font(RisingTypography.label)
    }
}
