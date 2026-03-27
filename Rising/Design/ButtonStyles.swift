import SwiftUI

// MARK: - Liquid Glass Button Styles (iOS 26)

/// Primary action button with Liquid Glass aesthetic
struct LiquidGlassPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: RisingRadius.lg)
                    .fill(isEnabled ? Color.risingPrimary : Color.risingTextSecondary)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .accessibilityLabel(configuration.label as? String ?? "Primary button")
    }
}

/// Secondary action button with Liquid Glass aesthetic
struct LiquidGlassSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(isEnabled ? Color.risingPrimary : Color.risingTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: RisingRadius.lg)
                    .stroke(isEnabled ? Color.risingPrimary : Color.risingTextSecondary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Destructive action button
struct LiquidGlassDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: RisingRadius.lg)
                    .fill(isEnabled ? Color.risingError : Color.risingTextSecondary)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Icon button with Liquid Glass aesthetic
struct LiquidGlassIconButtonStyle: ButtonStyle {
    let size: CGFloat
    let backgroundColor: Color

    init(size: CGFloat = 44, backgroundColor: Color = .risingSurface) {
        self.size = size
        self.backgroundColor = backgroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundColor(.risingPrimary)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Card button style for tappable cards
struct LiquidGlassCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions

extension ButtonStyle where Self == LiquidGlassPrimaryButtonStyle {
    static var liquidGlassPrimary: LiquidGlassPrimaryButtonStyle {
        LiquidGlassPrimaryButtonStyle()
    }
}

extension ButtonStyle where Self == LiquidGlassSecondaryButtonStyle {
    static var liquidGlassSecondary: LiquidGlassSecondaryButtonStyle {
        LiquidGlassSecondaryButtonStyle()
    }
}

extension ButtonStyle where Self == LiquidGlassDestructiveButtonStyle {
    static var liquidGlassDestructive: LiquidGlassDestructiveButtonStyle {
        LiquidGlassDestructiveButtonStyle()
    }
}

extension ButtonStyle where Self == LiquidGlassCardButtonStyle {
    static var liquidGlassCard: LiquidGlassCardButtonStyle {
        LiquidGlassCardButtonStyle()
    }
}
