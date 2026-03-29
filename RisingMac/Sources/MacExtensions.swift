import Foundation

// MARK: - Goal: Hashable conformance for macOS

extension Goal: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
