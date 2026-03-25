import Foundation
import SQLite

// MARK: - Database Service

@MainActor
final class DatabaseService {
    static let shared = DatabaseService()

    private var db: Connection?

    // MARK: - Tables

    private let goals = Table("goals")
    private let deposits = Table("deposits")

    // MARK: - Goal Columns

    private let goalId = SQLite.Expression<String>("id")
    private let goalName = SQLite.Expression<String>("name")
    private let goalTargetAmount = SQLite.Expression<Double>("target_amount")
    private let goalCurrentAmount = SQLite.Expression<Double>("current_amount")
    private let goalDeadline = SQLite.Expression<Date?>("deadline")
    private let goalCreatedAt = SQLite.Expression<Date>("created_at")
    private let goalIconName = SQLite.Expression<String>("icon_name")
    private let goalDescription = SQLite.Expression<String?>("description")

    // MARK: - Deposit Columns

    private let depositId = SQLite.Expression<String>("id")
    private let depositGoalId = SQLite.Expression<String>("goal_id")
    private let depositAmount = SQLite.Expression<Double>("amount")
    private let depositDate = SQLite.Expression<Date>("date")
    private let depositNote = SQLite.Expression<String?>("note")
    private let depositCreatedAt = SQLite.Expression<Date>("created_at")

    // MARK: - Init

    private init() {
        do {
            let path = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("rising.sqlite3")
                .path

            db = try Connection(path)
            try createTables()
        } catch {
            print("DatabaseService init error: \(error)")
        }
    }

    // MARK: - Schema

    private func createTables() throws {
        guard let db = db else { return }

        try db.run(goals.create(ifNotExists: true) { t in
            t.column(goalId, primaryKey: true)
            t.column(goalName)
            t.column(goalTargetAmount)
            t.column(goalCurrentAmount)
            t.column(goalDeadline)
            t.column(goalCreatedAt)
            t.column(goalIconName)
            t.column(goalDescription)
        })

        try db.run(deposits.create(ifNotExists: true) { t in
            t.column(depositId, primaryKey: true)
            t.column(depositGoalId)
            t.column(depositAmount)
            t.column(depositDate)
            t.column(depositNote)
            t.column(depositCreatedAt)
        })
    }

    // MARK: - Goal CRUD

    func fetchAllGoals() throws -> [Goal] {
        guard let db = db else { return [] }

        var result: [Goal] = []
        for row in try db.prepare(goals.order(goalCreatedAt.desc)) {
            let goal = Goal(
                id: UUID(uuidString: row[goalId]) ?? UUID(),
                name: row[goalName],
                targetAmount: row[goalTargetAmount],
                currentAmount: row[goalCurrentAmount],
                deadline: row[goalDeadline],
                createdAt: row[goalCreatedAt],
                iconName: row[goalIconName],
                description: row[goalDescription]
            )
            result.append(goal)
        }
        return result
    }

    func insertGoal(_ goal: Goal) throws {
        guard let db = db else { return }

        try db.run(goals.insert(
            goalId <- goal.id.uuidString,
            goalName <- goal.name,
            goalTargetAmount <- goal.targetAmount,
            goalCurrentAmount <- goal.currentAmount,
            goalDeadline <- goal.deadline,
            goalCreatedAt <- goal.createdAt,
            goalIconName <- goal.iconName,
            goalDescription <- goal.description
        ))
    }

    func updateGoal(_ goal: Goal) throws {
        guard let db = db else { return }

        let target = goals.filter(goalId == goal.id.uuidString)
        try db.run(target.update(
            goalName <- goal.name,
            goalTargetAmount <- goal.targetAmount,
            goalCurrentAmount <- goal.currentAmount,
            goalDeadline <- goal.deadline,
            goalIconName <- goal.iconName,
            goalDescription <- goal.description
        ))
    }

    func deleteGoal(id: UUID) throws {
        guard let db = db else { return }

        let target = goals.filter(goalId == id.uuidString)
        try db.run(target.delete())

        // Also delete associated deposits
        let associatedDeposits = deposits.filter(depositGoalId == id.uuidString)
        try db.run(associatedDeposits.delete())
    }

    // MARK: - Deposit CRUD

    func fetchDeposits(forGoalId id: UUID) throws -> [Deposit] {
        guard let db = db else { return [] }

        let query = deposits.filter(depositGoalId == id.uuidString).order(depositDate.desc)
        var result: [Deposit] = []
        for row in try db.prepare(query) {
            let deposit = Deposit(
                id: UUID(uuidString: row[depositId]) ?? UUID(),
                goalId: UUID(uuidString: row[depositGoalId]) ?? UUID(),
                amount: row[depositAmount],
                date: row[depositDate],
                note: row[depositNote],
                createdAt: row[depositCreatedAt]
            )
            result.append(deposit)
        }
        return result
    }

    func insertDeposit(_ deposit: Deposit) throws {
        guard let db = db else { return }

        try db.run(deposits.insert(
            depositId <- deposit.id.uuidString,
            depositGoalId <- deposit.goalId.uuidString,
            depositAmount <- deposit.amount,
            depositDate <- deposit.date,
            depositNote <- deposit.note,
            depositCreatedAt <- deposit.createdAt
        ))
    }

    func deleteDeposit(id: UUID) throws {
        guard let db = db else { return }

        let target = deposits.filter(depositId == id.uuidString)
        try db.run(target.delete())
    }

    // MARK: - Analytics

    func totalSaved() throws -> Double {
        guard let db = db else { return 0 }

        let total = try db.scalar(goals.select(goalCurrentAmount.sum)) ?? 0
        return total
    }
}
