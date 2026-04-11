import Foundation

@MainActor
@Observable
final class CommunityViewModel {
    var sharedGoals: [RisingR12Service.SharedGoal] = []
    var communityPosts: [RisingR12Service.CommunityPost] = []
    var savingsChallenges: [RisingR12Service.SavingsChallenge] = []
    var homeBuyerGroups: [RisingR12Service.HomeBuyerGroup] = []

    private let service: RisingR12Service

    init(service: RisingR12Service = RisingR12Service.shared) {
        self.service = service
    }

    func load() {
        service.loadDemoData()
        syncFromService()
    }

    func createPost(content: String, type: RisingR12Service.CommunityPost.PostType, city: String?, isAnonymous: Bool) {
        _ = service.createPost(content: content, type: type, city: city, isAnonymous: isAnonymous)
        syncFromService()
    }

    func reactToPost(_ postId: UUID, reaction: RisingR12Service.CommunityPost.Reaction.ReactionType) {
        service.reactToPost(postId, reaction: reaction)
        syncFromService()
    }

    func deletePost(_ postId: UUID) {
        service.deletePost(postId)
        syncFromService()
    }

    func createSharedGoal(name: String, targetAmount: Double, isPublic: Bool) {
        _ = service.createSharedGoal(name: name, targetAmount: targetAmount, isPublic: isPublic)
        syncFromService()
    }

    func addContribution(to goalId: UUID, amount: Double, note: String?) {
        service.addContribution(to: goalId, amount: amount, note: note)
        syncFromService()
    }

    func deleteSharedGoal(_ goalId: UUID) {
        service.deleteSharedGoal(goalId)
        syncFromService()
    }

    func createChallenge(name: String, description: String, targetAmount: Double, durationDays: Int) {
        _ = service.createChallenge(name: name, description: description, targetAmount: targetAmount, durationDays: durationDays)
        syncFromService()
    }

    func deleteChallenge(_ challengeId: UUID) {
        service.deleteChallenge(challengeId)
        syncFromService()
    }

    func joinGroup(_ groupId: UUID) {
        service.joinGroup(groupId)
        syncFromService()
    }

    func leaveGroup(_ groupId: UUID) {
        service.leaveGroup(groupId)
        syncFromService()
    }

    private func syncFromService() {
        sharedGoals = service.sharedGoals
        communityPosts = service.communityPosts
        savingsChallenges = service.savingsChallenges
        homeBuyerGroups = service.homeBuyerGroups
    }
}
