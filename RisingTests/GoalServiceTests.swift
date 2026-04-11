import XCTest
@testable import Rising

final class GoalServiceTests: XCTestCase {
    func testGoalProgress() async {
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 1000,
            currentAmount: 500,
            deadline: nil
        )
        XCTAssertEqual(goal.progress, 0.5)
        XCTAssertEqual(goal.remainingAmount, 500)
    }
    
    func testGoalCompletion() async {
        let goal = Goal(
            name: "Completed Goal",
            targetAmount: 1000,
            currentAmount: 1000,
            deadline: nil
        )
        XCTAssertTrue(goal.isCompleted)
    }
}
