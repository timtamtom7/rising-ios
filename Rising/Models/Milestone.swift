import Foundation

// MARK: - Milestone Type

/// Types of milestones in the home buying process.
enum MilestoneType: String, Codable, CaseIterable {
    case preApproval = "pre_approval"
    case saveDownPayment = "save_down_payment"
    case makeOffer = "make_offer"
    case offerAccepted = "offer_accepted"
    case inspection = "inspection"
    case closing = "closing"

    /// Human-readable title for the milestone.
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

    /// Order of this milestone in the home buying sequence.
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

/// Status of a milestone in the home buying process.
enum MilestoneStatus: String, Codable {
    /// Milestone has not been completed yet.
    case pending
    /// Milestone has been completed.
    case completed
}

// MARK: - Offer Status (R3)

/// Status of an offer made on a property.
enum OfferStatus: String, Codable, CaseIterable {
    /// Offer has been submitted and is awaiting response.
    case pending
    /// Offer was accepted by the seller.
    case accepted
    /// Offer was rejected by the seller.
    case rejected
    /// Seller countered with different terms.
    case countered

    /// Human-readable text describing the offer status.
    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted ✓"
        case .rejected: return "Rejected ✗"
        case .countered: return "Countered ↔"
        }
    }

    /// SF Symbol name for the offer status icon.
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

/// Represents a milestone in the home buying process.
struct Milestone: Identifiable, Codable, Equatable {
    /// Unique identifier for the milestone.
    let id: UUID
    /// ID of the goal this milestone belongs to.
    var goalId: UUID
    /// Custom title for the milestone.
    var title: String
    /// Type of milestone (pre-approval, closing, etc.).
    var type: MilestoneType
    /// Current status of the milestone.
    var status: MilestoneStatus
    /// Date when the milestone was completed, if applicable.
    var completedAt: Date?
    /// Optional amount associated with the milestone.
    var amount: Double?
    /// Date when the milestone was created.
    var createdAt: Date

    /// Lender name for pre-approval milestone.
    var preApprovalLender: String?
    /// Date of pre-approval milestone.
    var preApprovalDate: Date?

    /// Offer amount for make-offer milestone.
    var offerAmount: Double?
    /// Status of the offer.
    var offerStatus: OfferStatus?

    /// Closing date for closing milestone.
    var closingDate: Date?

    /// Creates a new milestone.
    /// - Parameters:
    ///   - goalId: ID of the goal this milestone belongs to.
    ///   - title: Custom title for the milestone.
    ///   - type: Type of milestone.
    ///   - amount: Optional amount associated with the milestone.
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
