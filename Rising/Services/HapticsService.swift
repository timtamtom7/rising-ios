import UIKit
import SwiftUI

// MARK: - Haptics Service (iOS 26 Liquid Glass)

@MainActor
final class HapticsService {
    static let shared = HapticsService()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact Haptics

    func impactLight() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }

    func impactMedium() {
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    func impactHeavy() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    func impactSoft() {
        softGenerator.impactOccurred()
        softGenerator.prepare()
    }

    func impactRigid() {
        rigidGenerator.impactOccurred()
        rigidGenerator.prepare()
    }

    func impact(intensity: CGFloat) {
        mediumGenerator.impactOccurred(intensity: intensity)
        mediumGenerator.prepare()
    }

    // MARK: - Selection Haptic

    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // MARK: - Notification Haptics

    func notificationSuccess() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    func notificationWarning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    func notificationError() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    // MARK: - Trigger by Style

    func trigger(_ style: HapticStyle) {
        switch style {
        case .light:
            impactLight()
        case .medium:
            impactMedium()
        case .heavy:
            impactHeavy()
        case .soft:
            impactSoft()
        case .rigid:
            impactRigid()
        case .selection:
            selection()
        case .success:
            notificationSuccess()
        case .warning:
            notificationWarning()
        case .error:
            notificationError()
        }
    }
}

// MARK: - Haptic Style

enum HapticStyle {
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    case success
    case warning
    case error
}
