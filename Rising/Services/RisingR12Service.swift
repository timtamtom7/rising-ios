import Foundation

// R12: Social Features — Shared Goals, Homebuyer Community, Challenges
@MainActor
final class RisingR12Service: ObservableObject {
    static let shared = RisingR12Service()

    @Published var sharedGoals: [SharedGoal] = []
    @Published var communityPosts: [CommunityPost] = []
    @Published var savingsChallenges: [SavingsChallenge] = []
    @Published var homeBuyerGroups: [HomeBuyerGroup] = []

    private let storageKey = "risingSocialData"

    private init() {
        loadData()
    }

    // MARK: - Shared Goals

    struct SharedGoal: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var ownerId: String
        var ownerName: String
        var contributorIds: [String]
        var targetAmount: Double
        var currentAmount: Double
        var contributions: [Contribution]
        var isPublic: Bool
        var createdAt: Date

        init(
            id: UUID = UUID(),
            name: String,
            ownerId: String = "local",
            ownerName: String = "You",
            contributorIds: [String] = [],
            targetAmount: Double,
            currentAmount: Double = 0,
            contributions: [Contribution] = [],
            isPublic: Bool = false,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.name = name
            self.ownerId = ownerId
            self.ownerName = ownerName
            self.contributorIds = contributorIds
            self.targetAmount = targetAmount
            self.currentAmount = currentAmount
            self.contributions = contributions
            self.isPublic = isPublic
            self.createdAt = createdAt
        }

        var progress: Double {
            guard targetAmount > 0 else { return 0 }
            return min(currentAmount / targetAmount, 1.0)
        }

        struct Contribution: Identifiable, Codable, Equatable {
            let id: UUID
            var contributorId: String
            var contributorName: String
            var amount: Double
            var note: String?
            var contributedAt: Date

            init(
                id: UUID = UUID(),
                contributorId: String = "local",
                contributorName: String = "You",
                amount: Double,
                note: String? = nil,
                contributedAt: Date = Date()
            ) {
                self.id = id
                self.contributorId = contributorId
                self.contributorName = contributorName
                self.amount = amount
                self.note = note
                self.contributedAt = contributedAt
            }
        }
    }

    func createSharedGoal(name: String, targetAmount: Double, isPublic: Bool = false) -> SharedGoal {
        let goal = SharedGoal(name: name, targetAmount: targetAmount, isPublic: isPublic)
        sharedGoals.append(goal)
        saveData()
        return goal
    }

    func addContribution(to goalId: UUID, amount: Double, note: String? = nil) {
        guard let index = sharedGoals.firstIndex(where: { $0.id == goalId }) else { return }
        let contribution = SharedGoal.Contribution(amount: amount, note: note)
        sharedGoals[index].contributions.append(contribution)
        sharedGoals[index].currentAmount += amount
        saveData()
    }

    func deleteSharedGoal(_ goalId: UUID) {
        sharedGoals.removeAll { $0.id == goalId }
        saveData()
    }

    // MARK: - Community Posts

    struct CommunityPost: Identifiable, Codable, Equatable {
        let id: UUID
        var authorId: String
        var authorName: String
        var isAnonymous: Bool
        var content: String
        var postType: PostType
        var reactions: [Reaction]
        var city: String?
        var createdAt: Date

        enum PostType: String, Codable, CaseIterable {
            case question = "Question"
            case advice = "Advice"
            case celebration = "Celebration"
            case story = "Story"
            case tip = "Tip"
        }

        struct Reaction: Codable, Equatable {
            var type: ReactionType
            var count: Int
            var hasReacted: Bool

            enum ReactionType: String, Codable, CaseIterable {
                case helpful = "👍"
                case celebration = "🎉"
                case love = "❤️"
                case save = "💾"
            }
        }

        init(
            id: UUID = UUID(),
            authorId: String = "local",
            authorName: String = "You",
            isAnonymous: Bool = false,
            content: String,
            postType: PostType = .advice,
            reactions: [Reaction] = [],
            city: String? = nil,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.authorId = authorId
            self.authorName = authorName
            self.isAnonymous = isAnonymous
            self.content = content
            self.postType = postType
            self.reactions = reactions
            self.city = city
            self.createdAt = createdAt
        }

        var displayName: String { isAnonymous ? "Anonymous" : authorName }
    }

    func createPost(content: String, type: CommunityPost.PostType, city: String? = nil, isAnonymous: Bool = false) -> CommunityPost {
        let post = CommunityPost(isAnonymous: isAnonymous, content: content, postType: type, city: city)
        communityPosts.insert(post, at: 0)
        saveData()
        return post
    }

    func reactToPost(_ postId: UUID, reaction: CommunityPost.Reaction.ReactionType) {
        guard let index = communityPosts.firstIndex(where: { $0.id == postId }) else { return }
        if let reactionIndex = communityPosts[index].reactions.firstIndex(where: { $0.type == reaction }) {
            if communityPosts[index].reactions[reactionIndex].hasReacted {
                communityPosts[index].reactions[reactionIndex].count -= 1
                communityPosts[index].reactions[reactionIndex].hasReacted = false
            } else {
                communityPosts[index].reactions[reactionIndex].count += 1
                communityPosts[index].reactions[reactionIndex].hasReacted = true
            }
        } else {
            communityPosts[index].reactions.append(CommunityPost.Reaction(type: reaction, count: 1, hasReacted: true))
        }
        saveData()
    }

    func deletePost(_ postId: UUID) {
        communityPosts.removeAll { $0.id == postId }
        saveData()
    }

    // MARK: - Savings Challenges

    struct SavingsChallenge: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var description: String
        var targetAmount: Double
        var durationDays: Int
        var participantIds: [String]
        var startDate: Date
        var isActive: Bool
        var milestones: [Milestone]

        init(
            id: UUID = UUID(),
            name: String,
            description: String = "",
            targetAmount: Double,
            durationDays: Int = 30,
            participantIds: [String] = ["local"],
            startDate: Date = Date(),
            isActive: Bool = true,
            milestones: [Milestone] = []
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.targetAmount = targetAmount
            self.durationDays = durationDays
            self.participantIds = participantIds
            self.startDate = startDate
            self.isActive = isActive
            self.milestones = milestones
        }

        var endDate: Date {
            Calendar.current.date(byAdding: .day, value: durationDays, to: startDate) ?? startDate
        }

        var daysRemaining: Int {
            let components = Calendar.current.dateComponents([.day], from: Date(), to: endDate)
            return max(0, components.day ?? 0)
        }

        struct Milestone: Identifiable, Codable, Equatable {
            let id: UUID
            var amount: Double
            var achievedAt: Date?
            var isAchieved: Bool

            init(id: UUID = UUID(), amount: Double, achievedAt: Date? = nil, isAchieved: Bool = false) {
                self.id = id
                self.amount = amount
                self.achievedAt = achievedAt
                self.isAchieved = isAchieved
            }
        }
    }

    func createChallenge(name: String, description: String, targetAmount: Double, durationDays: Int) -> SavingsChallenge {
        let challenge = SavingsChallenge(name: name, description: description, targetAmount: targetAmount, durationDays: durationDays)
        savingsChallenges.append(challenge)
        saveData()
        return challenge
    }

    func deleteChallenge(_ challengeId: UUID) {
        savingsChallenges.removeAll { $0.id == challengeId }
        saveData()
    }

    // MARK: - Home Buyer Groups

    struct HomeBuyerGroup: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var city: String
        var memberCount: Int
        var description: String
        var isJoined: Bool
        var createdAt: Date

        init(
            id: UUID = UUID(),
            name: String,
            city: String,
            memberCount: Int = 1,
            description: String = "",
            isJoined: Bool = false,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.name = name
            self.city = city
            self.memberCount = memberCount
            self.description = description
            self.isJoined = isJoined
            self.createdAt = createdAt
        }
    }

    func joinGroup(_ groupId: UUID) {
        guard let index = homeBuyerGroups.firstIndex(where: { $0.id == groupId }) else { return }
        homeBuyerGroups[index].isJoined = true
        homeBuyerGroups[index].memberCount += 1
        saveData()
    }

    func leaveGroup(_ groupId: UUID) {
        guard let index = homeBuyerGroups.firstIndex(where: { $0.id == groupId }) else { return }
        homeBuyerGroups[index].isJoined = false
        homeBuyerGroups[index].memberCount = max(1, homeBuyerGroups[index].memberCount - 1)
        saveData()
    }

    // MARK: - Persistence

    private struct SocialData: Codable {
        var sharedGoals: [SharedGoal]
        var communityPosts: [CommunityPost]
        var savingsChallenges: [SavingsChallenge]
        var homeBuyerGroups: [HomeBuyerGroup]
    }

    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let socialData = try? JSONDecoder().decode(SocialData.self, from: data) else {
            return
        }
        sharedGoals = socialData.sharedGoals
        communityPosts = socialData.communityPosts
        savingsChallenges = socialData.savingsChallenges
        homeBuyerGroups = socialData.homeBuyerGroups
    }

    private func saveData() {
        let socialData = SocialData(
            sharedGoals: sharedGoals,
            communityPosts: communityPosts,
            savingsChallenges: savingsChallenges,
            homeBuyerGroups: homeBuyerGroups
        )
        if let data = try? JSONEncoder().encode(socialData) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Demo Data

    func loadDemoData() {
        guard communityPosts.isEmpty && sharedGoals.isEmpty else { return }

        // Demo community posts
        let posts = [
            CommunityPost(content: "Just closed on my first home in Austin! The process took 4 months but so worth it. Happy to answer any questions from first-time buyers.", postType: .celebration, city: "Austin"),
            CommunityPost(content: "What's the typical earnest money deposit in this market? I'm in the Bay Area and everything feels so competitive.", postType: .question, city: "San Francisco"),
            CommunityPost(content: "Tip: Get a reputable home inspector even if the market is hot. My inspector found foundation issues that saved me $15K in negotiations.", postType: .tip)
        ]
        communityPosts = posts

        // Demo shared goal
        let goal = SharedGoal(name: "Down Payment Fund", targetAmount: 75000, currentAmount: 32000, isPublic: true)
        sharedGoals = [goal]

        // Demo challenges
        let challenge = SavingsChallenge(name: "No-Spend October", description: "Save as much as possible by avoiding discretionary purchases", targetAmount: 5000, durationDays: 30)
        savingsChallenges = [challenge]

        // Demo groups
        let groups = [
            HomeBuyerGroup(name: "First-Time Buyers Austin", city: "Austin", memberCount: 234, description: "Support and advice for first-time homebuyers in Austin", isJoined: true),
            HomeBuyerGroup(name: "Bay Area Buyers", city: "San Francisco", memberCount: 512, description: "Navigating the competitive Bay Area housing market together", isJoined: false)
        ]
        homeBuyerGroups = groups

        saveData()
    }
}
