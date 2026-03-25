import Foundation

// MARK: - Theme Service

@MainActor
final class ThemeService {
    static let shared = ThemeService()

    private let userDefaults = UserDefaults.standard

    enum ThemeMode: String, CaseIterable {
        case dark
        case light
        case system
    }

    private enum Keys {
        static let themeMode = "themeMode"
    }

    var themeMode: ThemeMode {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.themeMode),
                  let mode = ThemeMode(rawValue: rawValue) else {
                return .system
            }
            return mode
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.themeMode)
        }
    }

    private init() {}
}
