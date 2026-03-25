import Foundation

// MARK: - Milestone Type

enum MilestoneType: String, Codable, CaseIterable {
    case preApproval = "pre_approval"
    case saveDownPayment = "save_down_payment"
    case makeOffer = "make_offer"
    case offerAccepted = "offer_accepted"
    case inspection = "inspection"
    case closing = "closing"

    var displayTitle: String {
        switch self {
        case .preApproval: return "Get Pre-Approved"
        case .saveDownPayment: return "Save Down Payment"
        case .makeOffer: return "Make Offer"
        case .offerAccepted: return "Offer Accepted"
        case .inspection: return "Home Inspection"
        case .closing: return "Close"
        }
    }

    var iconName: String {
        switch self {
        case .preApproval: return "doc.text"
        case .saveDownPayment: return "banknote"
        case .makeOffer: return "tag"
        case .offerAccepted: return "checkmark.seal"
        case .inspection: return "house"
        case .closing: return "key"
        }
    }
}

// MARK: - Milestone Status

enum MilestoneStatus: String, Codable {
    case pending
    case completed
}

// MARK: - Milestone Model (R2)

struct Milestone: Identifiable, Codable, Equatable {
    let id: UUID
    var goalId: UUID
    var title: String
    var type: MilestoneType
    var status: MilestoneStatus
    var completedAt: Date?
    var amount: Double?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        goalId: UUID,
        title: String,
        type: MilestoneType,
        status: MilestoneStatus = .pending,
        completedAt: Date? = nil,
        amount: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.title = title
        self.type = type
        self.status = status
        self.completedAt = completedAt
        self.amount = amount
        self.createdAt = createdAt
    }
}
