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

    var sortOrder: Int {
        switch self {
        case .preApproval: return 0
        case .saveDownPayment: return 1
        case .makeOffer: return 2
        case .offerAccepted: return 3
        case .inspection: return 4
        case .closing: return 5
        }
    }
}

// MARK: - Milestone Status

enum MilestoneStatus: String, Codable {
    case pending
    case completed
}

// MARK: - Offer Status (R3)

enum OfferStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case rejected
    case countered

    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted ✓"
        case .rejected: return "Rejected ✗"
        case .countered: return "Countered ↔"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "questionmark.circle"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .countered: return "arrow.left.arrow.right.circle.fill"
        }
    }
}

// MARK: - Milestone Model

struct Milestone: Identifiable, Codable, Equatable {
    let id: UUID
    var goalId: UUID
    var title: String
    var type: MilestoneType
    var status: MilestoneStatus
    var completedAt: Date?
    var amount: Double?
    var createdAt: Date

    // R3: Pre-approval fields
    var preApprovalLender: String?
    var preApprovalDate: Date?

    // R3: Offer fields
    var offerAmount: Double?
    var offerStatus: OfferStatus?

    // R3: Closing
    var closingDate: Date?

    init(
        id: UUID = UUID(),
        goalId: UUID,
        title: String,
        type: MilestoneType,
        status: MilestoneStatus = .pending,
        completedAt: Date? = nil,
        amount: Double? = nil,
        createdAt: Date = Date(),
        preApprovalLender: String? = nil,
        preApprovalDate: Date? = nil,
        offerAmount: Double? = nil,
        offerStatus: OfferStatus? = nil,
        closingDate: Date? = nil
    ) {
        self.id = id
        self.goalId = goalId
        self.title = title
        self.type = type
        self.status = status
        self.completedAt = completedAt
        self.amount = amount
        self.createdAt = createdAt
        self.preApprovalLender = preApprovalLender
        self.preApprovalDate = preApprovalDate
        self.offerAmount = offerAmount
        self.offerStatus = offerStatus
        self.closingDate = closingDate
    }
}
