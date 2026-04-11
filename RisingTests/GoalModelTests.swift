import XCTest
@testable import Rising

final class FormattersTests: XCTestCase {
    func testCurrencyFormatter() {
        let value: Double = 1234.56
        let formatted = value.formattedCurrency
        XCTAssertTrue(formatted.contains("1,235"), "Expected formatted currency to contain '1,235', got: \(formatted)")
    }

    func testCurrencyFormatterZero() {
        let value: Double = 0
        let formatted = value.formattedCurrency
        XCTAssertTrue(formatted.contains("0"), "Expected formatted currency to contain '0', got: \(formatted)")
    }

    func testCurrencyFormatterLarge() {
        let value: Double = 50000
        let formatted = value.formattedCurrency
        XCTAssertTrue(formatted.contains("50,000"), "Expected formatted currency to contain '50,000', got: \(formatted)")
    }

    func testDecimalFormatter() {
        let value: Double = 1234.56
        let formatted = value.formattedDecimal
        XCTAssertTrue(formatted.contains("1,235"), "Expected formatted decimal to contain '1,235', got: \(formatted)")
    }
}

final class GoalModelTests: XCTestCase {
    func testProgressHalfway() {
        let goal = Goal(name: "Test Goal", targetAmount: 1000, currentAmount: 500)
        XCTAssertEqual(goal.progress, 0.5)
    }

    func testProgressZero() {
        let goal = Goal(name: "Empty", targetAmount: 1000, currentAmount: 0)
        XCTAssertEqual(goal.progress, 0)
    }

    func testProgressFull() {
        let goal = Goal(name: "Done", targetAmount: 1000, currentAmount: 1000)
        XCTAssertEqual(goal.progress, 1.0)
    }

    func testRemainingAmount() {
        let goal = Goal(name: "Test", targetAmount: 1000, currentAmount: 250)
        XCTAssertEqual(goal.remainingAmount, 750)
    }

    func testRemainingAmountOverflow() {
        let goal = Goal(name: "Over", targetAmount: 1000, currentAmount: 1500)
        XCTAssertEqual(goal.remainingAmount, 0)
    }

    func testIsCompleted() {
        let goal = Goal(name: "Complete", targetAmount: 500, currentAmount: 500)
        XCTAssertTrue(goal.isCompleted)
    }

    func testIsNotCompleted() {
        let goal = Goal(name: "Incomplete", targetAmount: 500, currentAmount: 499)
        XCTAssertFalse(goal.isCompleted)
    }

    func testFormattedProgress() {
        let goal = Goal(name: "Test", targetAmount: 1000, currentAmount: 500)
        let percentage = Int(goal.progress * 100)
        XCTAssertEqual("\(percentage)%", "50%")
    }
}

final class DepositModelTests: XCTestCase {
    func testDepositCreation() {
        let deposit = Deposit(goalId: UUID(), amount: 100, date: Date(), note: nil)
        XCTAssertEqual(deposit.amount, 100)
        XCTAssertNil(deposit.note)
    }

    func testDepositWithNote() {
        let deposit = Deposit(goalId: UUID(), amount: 250, date: Date(), note: "Weekly deposit")
        XCTAssertEqual(deposit.note, "Weekly deposit")
    }
}