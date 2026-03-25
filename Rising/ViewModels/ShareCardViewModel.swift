import SwiftUI

// MARK: - Share Card View Model

@MainActor
@Observable
final class ShareCardViewModel {
    let goal: Goal

    var cardImage: UIImage?

    init(goal: Goal) {
        self.goal = goal
    }

    func generateCard() {
        // Card is generated via ShareableGoalCard view
    }
}
