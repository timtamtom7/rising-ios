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
    private let properties = Table("properties")  // R5: SQLite persistence
    private let agents = Table("agents")          // R5: SQLite persistence
    private let milestones = Table("milestones")  // R5: SQLite persistence

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

    // MARK: - Property Columns (R5)

    private let propertyId = SQLite.Expression<String>("id")
    private let propertyGoalId = SQLite.Expression<String>("goal_id")
    private let propertyAddress = SQLite.Expression<String>("address")
    private let propertyPrice = SQLite.Expression<Double>("price")
    private let propertyLink = SQLite.Expression<String?>("link")
    private let propertyNotes = SQLite.Expression<String?>("notes")
    private let propertyCreatedAt = SQLite.Expression<Date>("created_at")

    // MARK: - Agent Columns (R5)

    private let agentId = SQLite.Expression<String>("id")
    private let agentName = SQLite.Expression<String>("name")
    private let agentPhone = SQLite.Expression<String?>("phone")
    private let agentEmail = SQLite.Expression<String?>("email")
    private let agentNotes = SQLite.Expression<String?>("notes")
    private let agentCreatedAt = SQLite.Expression<Date>("created_at")

    // MARK: - Milestone Columns (R5)

    private let milestoneId = SQLite.Expression<String>("id")
    private let milestoneGoalId = SQLite.Expression<String>("goal_id")
    private let milestoneTitle = SQLite.Expression<String>("title")
    private let milestoneType = SQLite.Expression<String>("type")
    private let milestoneStatus = SQLite.Expression<String>("status")
    private let milestoneCompletedAt = SQLite.Expression<Date?>("completed_at")
    private let milestoneAmount = SQLite.Expression<Double?>("amount")
    private let milestoneCreatedAt = SQLite.Expression<Date>("created_at")
    private let milestonePreApprovalLender = SQLite.Expression<String?>("pre_approval_lender")
    private let milestonePreApprovalDate = SQLite.Expression<Date?>("pre_approval_date")
    private let milestoneOfferAmount = SQLite.Expression<Double?>("offer_amount")
    private let milestoneOfferStatus = SQLite.Expression<String?>("offer_status")
    private let milestoneClosingDate = SQLite.Expression<Date?>("closing_date")

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

        // R5: Properties table
        try db.run(properties.create(ifNotExists: true) { t in
            t.column(propertyId, primaryKey: true)
            t.column(propertyGoalId)
            t.column(propertyAddress)
            t.column(propertyPrice)
            t.column(propertyLink)
            t.column(propertyNotes)
            t.column(propertyCreatedAt)
        })

        // R5: Agents table
        try db.run(agents.create(ifNotExists: true) { t in
            t.column(agentId, primaryKey: true)
            t.column(agentName)
            t.column(agentPhone)
            t.column(agentEmail)
            t.column(agentNotes)
            t.column(agentCreatedAt)
        })

        // R5: Milestones table
        try db.run(milestones.create(ifNotExists: true) { t in
            t.column(milestoneId, primaryKey: true)
            t.column(milestoneGoalId)
            t.column(milestoneTitle)
            t.column(milestoneType)
            t.column(milestoneStatus)
            t.column(milestoneCompletedAt)
            t.column(milestoneAmount)
            t.column(milestoneCreatedAt)
            t.column(milestonePreApprovalLender)
            t.column(milestonePreApprovalDate)
            t.column(milestoneOfferAmount)
            t.column(milestoneOfferStatus)
            t.column(milestoneClosingDate)
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

        // R5: Delete associated properties
        let associatedProperties = properties.filter(propertyGoalId == id.uuidString)
        try db.run(associatedProperties.delete())

        // R5: Delete associated milestones
        let associatedMilestones = milestones.filter(milestoneGoalId == id.uuidString)
        try db.run(associatedMilestones.delete())
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

    // MARK: - Property CRUD (R5)

    func fetchAllProperties() throws -> [Property] {
        guard let db = db else { return [] }

        var result: [Property] = []
        for row in try db.prepare(properties.order(propertyCreatedAt.desc)) {
            let property = Property(
                id: UUID(uuidString: row[propertyId]) ?? UUID(),
                goalId: UUID(uuidString: row[propertyGoalId]) ?? UUID(),
                address: row[propertyAddress],
                price: row[propertyPrice],
                link: row[propertyLink],
                notes: row[propertyNotes],
                createdAt: row[propertyCreatedAt]
            )
            result.append(property)
        }
        return result
    }

    func fetchProperties(forGoalId id: UUID) throws -> [Property] {
        guard let db = db else { return [] }

        let query = properties.filter(propertyGoalId == id.uuidString).order(propertyCreatedAt.desc)
        var result: [Property] = []
        for row in try db.prepare(query) {
            let property = Property(
                id: UUID(uuidString: row[propertyId]) ?? UUID(),
                goalId: UUID(uuidString: row[propertyGoalId]) ?? UUID(),
                address: row[propertyAddress],
                price: row[propertyPrice],
                link: row[propertyLink],
                notes: row[propertyNotes],
                createdAt: row[propertyCreatedAt]
            )
            result.append(property)
        }
        return result
    }

    func insertProperty(_ property: Property) throws {
        guard let db = db else { return }

        try db.run(properties.insert(
            propertyId <- property.id.uuidString,
            propertyGoalId <- property.goalId.uuidString,
            propertyAddress <- property.address,
            propertyPrice <- property.price,
            propertyLink <- property.link,
            propertyNotes <- property.notes,
            propertyCreatedAt <- property.createdAt
        ))
    }

    func updateProperty(_ property: Property) throws {
        guard let db = db else { return }

        let target = properties.filter(propertyId == property.id.uuidString)
        try db.run(target.update(
            propertyAddress <- property.address,
            propertyPrice <- property.price,
            propertyLink <- property.link,
            propertyNotes <- property.notes
        ))
    }

    func deleteProperty(id: UUID) throws {
        guard let db = db else { return }

        let target = properties.filter(propertyId == id.uuidString)
        try db.run(target.delete())
    }

    // MARK: - Agent CRUD (R5)

    func fetchAllAgents() throws -> [Agent] {
        guard let db = db else { return [] }

        var result: [Agent] = []
        for row in try db.prepare(agents.order(agentCreatedAt.desc)) {
            let agent = Agent(
                id: UUID(uuidString: row[agentId]) ?? UUID(),
                name: row[agentName],
                phone: row[agentPhone],
                email: row[agentEmail],
                notes: row[agentNotes],
                createdAt: row[agentCreatedAt]
            )
            result.append(agent)
        }
        return result
    }

    func insertAgent(_ agent: Agent) throws {
        guard let db = db else { return }

        try db.run(agents.insert(
            agentId <- agent.id.uuidString,
            agentName <- agent.name,
            agentPhone <- agent.phone,
            agentEmail <- agent.email,
            agentNotes <- agent.notes,
            agentCreatedAt <- agent.createdAt
        ))
    }

    func updateAgent(_ agent: Agent) throws {
        guard let db = db else { return }

        let target = agents.filter(agentId == agent.id.uuidString)
        try db.run(target.update(
            agentName <- agent.name,
            agentPhone <- agent.phone,
            agentEmail <- agent.email,
            agentNotes <- agent.notes
        ))
    }

    func deleteAgent(id: UUID) throws {
        guard let db = db else { return }

        let target = agents.filter(agentId == id.uuidString)
        try db.run(target.delete())
    }

    // MARK: - Milestone CRUD (R5)

    func fetchMilestones(forGoalId id: UUID) throws -> [Milestone] {
        guard let db = db else { return [] }

        let query = milestones.filter(milestoneGoalId == id.uuidString).order(milestoneCreatedAt.asc)
        var result: [Milestone] = []
        for row in try db.prepare(query) {
            let milestone = Milestone(
                id: UUID(uuidString: row[milestoneId]) ?? UUID(),
                goalId: UUID(uuidString: row[milestoneGoalId]) ?? UUID(),
                title: row[milestoneTitle],
                type: MilestoneType(rawValue: row[milestoneType]) ?? .preApproval,
                status: MilestoneStatus(rawValue: row[milestoneStatus]) ?? .pending,
                completedAt: row[milestoneCompletedAt],
                amount: row[milestoneAmount],
                createdAt: row[milestoneCreatedAt],
                preApprovalLender: row[milestonePreApprovalLender],
                preApprovalDate: row[milestonePreApprovalDate],
                offerAmount: row[milestoneOfferAmount],
                offerStatus: row[milestoneOfferStatus].flatMap { OfferStatus(rawValue: $0) },
                closingDate: row[milestoneClosingDate]
            )
            result.append(milestone)
        }
        return result
    }

    func insertMilestone(_ milestone: Milestone) throws {
        guard let db = db else { return }

        try db.run(milestones.insert(
            milestoneId <- milestone.id.uuidString,
            milestoneGoalId <- milestone.goalId.uuidString,
            milestoneTitle <- milestone.title,
            milestoneType <- milestone.type.rawValue,
            milestoneStatus <- milestone.status.rawValue,
            milestoneCompletedAt <- milestone.completedAt,
            milestoneAmount <- milestone.amount,
            milestoneCreatedAt <- milestone.createdAt,
            milestonePreApprovalLender <- milestone.preApprovalLender,
            milestonePreApprovalDate <- milestone.preApprovalDate,
            milestoneOfferAmount <- milestone.offerAmount,
            milestoneOfferStatus <- milestone.offerStatus?.rawValue,
            milestoneClosingDate <- milestone.closingDate
        ))
    }

    func updateMilestone(_ milestone: Milestone) throws {
        guard let db = db else { return }

        let target = milestones.filter(milestoneId == milestone.id.uuidString)
        try db.run(target.update(
            milestoneTitle <- milestone.title,
            milestoneStatus <- milestone.status.rawValue,
            milestoneCompletedAt <- milestone.completedAt,
            milestoneAmount <- milestone.amount,
            milestonePreApprovalLender <- milestone.preApprovalLender,
            milestonePreApprovalDate <- milestone.preApprovalDate,
            milestoneOfferAmount <- milestone.offerAmount,
            milestoneOfferStatus <- milestone.offerStatus?.rawValue,
            milestoneClosingDate <- milestone.closingDate
        ))
    }

    func deleteMilestone(id: UUID) throws {
        guard let db = db else { return }

        let target = milestones.filter(milestoneId == id.uuidString)
        try db.run(target.delete())
    }

    // MARK: - Analytics

    func totalSaved() throws -> Double {
        guard let db = db else { return 0 }

        let total = try db.scalar(goals.select(goalCurrentAmount.sum)) ?? 0
        return total
    }
}
