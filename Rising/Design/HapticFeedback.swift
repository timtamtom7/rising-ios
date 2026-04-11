import SwiftUI

@MainActor
func triggerHaptic(_ style: HapticStyle) {
    HapticsService.shared.trigger(style)
}

struct HapticButtonStyle: ButtonStyle {
    let style: HapticStyle

    @MainActor
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticsService.shared.trigger(style)
                }
            }
    }
}

extension ButtonStyle where Self == HapticButtonStyle {
    static func haptic(_ style: HapticStyle = .light) -> HapticButtonStyle {
        HapticButtonStyle(style: style)
    }
}

extension View {
    func hapticTap(_ style: HapticStyle = .light) -> some View {
        self.onTapGesture {
            HapticsService.shared.trigger(style)
        }
    }
}

struct HapticModifier: ViewModifier {
    let style: HapticStyle

    func body(content: Content) -> some View {
        content.onAppear {
            HapticsService.shared.trigger(style)
        }
    }
}

extension View {
    func triggerHaptic(_ style: HapticStyle) -> some View {
        modifier(HapticModifier(style: style))
    }
}