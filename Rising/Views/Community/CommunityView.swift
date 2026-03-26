import SwiftUI

// R12: Community & Social Features View
struct CommunityView: View {
    @State private var socialService = RisingR12Service.shared
    @State private var selectedTab: CommunityTab = .feed
    @State private var showingNewPost = false
    @State private var showingNewGoal = false
    @State private var showingNewChallenge = false

    enum CommunityTab: String, CaseIterable {
        case feed = "Feed"
        case goals = "Goals"
        case challenges = "Challenges"
        case groups = "Groups"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        ForEach(CommunityTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, RisingSpacing.md)
                    .padding(.vertical, RisingSpacing.sm)

                    ScrollView {
                        switch selectedTab {
                        case .feed:
                            feedView
                        case .goals:
                            goalsView
                        case .challenges:
                            challengesView
                        case .groups:
                            groupsView
                        }
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingNewPost = true
                        } label: {
                            Label("New Post", systemImage: "bubble.left")
                        }
                        Button {
                            showingNewGoal = true
                        } label: {
                            Label("Shared Goal", systemImage: "target")
                        }
                        Button {
                            showingNewChallenge = true
                        } label: {
                            Label("New Challenge", systemImage: "flame")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.risingPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                NewCommunityPostSheet(socialService: socialService)
            }
            .sheet(isPresented: $showingNewGoal) {
                NewSharedGoalSheet(socialService: socialService)
            }
            .sheet(isPresented: $showingNewChallenge) {
                NewChallengeSheet(socialService: socialService)
            }
            .onAppear {
                socialService.loadDemoData()
            }
        }
    }

    // MARK: - Feed View

    private var feedView: some View {
        LazyVStack(spacing: RisingSpacing.md) {
            ForEach(socialService.communityPosts) { post in
                CommunityPostCard(post: post, socialService: socialService)
            }

            if socialService.communityPosts.isEmpty {
                emptyFeedView
            }
        }
        .padding(.horizontal, RisingSpacing.md)
        .padding(.top, RisingSpacing.sm)
    }

    private var emptyFeedView: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(Color.risingPrimary.opacity(0.5))

            Text("No posts yet")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("Ask questions, share tips, and celebrate milestones with other homebuyers")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)
                .multilineTextAlignment(.center)

            Button {
                showingNewPost = true
            } label: {
                Text("Create Post")
                    .risingBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackgroundDark)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.risingPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }

    // MARK: - Shared Goals View

    private var goalsView: some View {
        LazyVStack(spacing: RisingSpacing.md) {
            ForEach(socialService.sharedGoals) { goal in
                SharedGoalCard(goal: goal, socialService: socialService)
            }

            if socialService.sharedGoals.isEmpty {
                emptyGoalsView
            }
        }
        .padding(.horizontal, RisingSpacing.md)
        .padding(.top, RisingSpacing.sm)
    }

    private var emptyGoalsView: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundStyle(Color.risingPrimary.opacity(0.5))

            Text("No shared goals")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("Track your homeownership savings together with family or partners")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)
                .multilineTextAlignment(.center)

            Button {
                showingNewGoal = true
            } label: {
                Text("Create Goal")
                    .risingBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackgroundDark)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.risingPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }

    // MARK: - Challenges View

    private var challengesView: some View {
        LazyVStack(spacing: RisingSpacing.md) {
            ForEach(socialService.savingsChallenges) { challenge in
                SavingsChallengeCard(challenge: challenge, socialService: socialService)
            }

            if socialService.savingsChallenges.isEmpty {
                emptyChallengesView
            }
        }
        .padding(.horizontal, RisingSpacing.md)
        .padding(.top, RisingSpacing.sm)
    }

    private var emptyChallengesView: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "flame")
                .font(.system(size: 48))
                .foregroundStyle(Color.risingAccent.opacity(0.5))

            Text("No challenges")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("Start a savings challenge to stay motivated")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)
                .multilineTextAlignment(.center)

            Button {
                showingNewChallenge = true
            } label: {
                Text("Create Challenge")
                    .risingBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackgroundDark)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.risingAccent)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 48)
    }

    // MARK: - Groups View

    private var groupsView: some View {
        LazyVStack(spacing: RisingSpacing.md) {
            ForEach(socialService.homeBuyerGroups) { group in
                HomeBuyerGroupCard(group: group, socialService: socialService)
            }

            if socialService.homeBuyerGroups.isEmpty {
                emptyGroupsView
            }
        }
        .padding(.horizontal, RisingSpacing.md)
        .padding(.top, RisingSpacing.sm)
    }

    private var emptyGroupsView: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundStyle(Color.risingPrimary.opacity(0.5))

            Text("No groups yet")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("Join a homebuyer group in your city")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 48)
    }
}

// MARK: - Community Post Card

struct CommunityPostCard: View {
    let post: RisingR12Service.CommunityPost
    @ObservedObject var socialService: RisingR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack(spacing: RisingSpacing.sm) {
                Circle()
                    .fill(Color.risingPrimary.opacity(0.3))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(post.displayName.prefix(1)))
                            .font(.headline)
                            .foregroundStyle(Color.risingPrimary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.risingTextPrimaryDark)

                        if let city = post.city {
                            Text("in \(city)")
                                .font(.caption)
                                .foregroundStyle(Color.risingTextSecondaryDark)
                        }
                    }

                    Text(formatDate(post.createdAt))
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }

                Spacer()

                Text(post.postType.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.risingPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.risingPrimary.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(post.content)
                .risingBody()
                .foregroundStyle(Color.risingTextPrimaryDark)
                .lineLimit(5)

            Divider()
                .background(Color.risingCardDark)

            HStack(spacing: RisingSpacing.md) {
                ForEach(RisingR12Service.CommunityPost.Reaction.ReactionType.allCases, id: \.self) { reactionType in
                    let reaction = post.reactions.first { $0.type == reactionType }
                    let count = reaction?.count ?? 0
                    let hasReacted = reaction?.hasReacted ?? false

                    Button {
                        socialService.reactToPost(post.id, reaction: reactionType)
                    } label: {
                        HStack(spacing: 2) {
                            Text(reactionType.rawValue)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundStyle(hasReacted ? Color.risingPrimary : Color.risingTextSecondaryDark)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .opacity(count > 0 || hasReacted ? 1 : 0.5)
                }

                Spacer()
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Shared Goal Card

struct SharedGoalCard: View {
    let goal: RisingR12Service.SharedGoal
    @ObservedObject var socialService: RisingR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    HStack(spacing: 4) {
                        Image(systemName: goal.isPublic ? "globe" : "lock")
                            .font(.caption2)
                        Text(goal.isPublic ? "Public" : "Private")
                            .font(.caption)
                    }
                    .foregroundStyle(goal.isPublic ? Color.risingPrimary : Color.risingTextSecondaryDark)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(goal.progress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.risingPrimary)
                    Text("progress")
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingCardDark)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingPrimary)
                        .frame(width: geometry.size.width * goal.progress, height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("$\(Int(goal.currentAmount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingTextPrimaryDark)
                Text("/ $\(Int(goal.targetAmount))")
                    .font(.caption)
                    .foregroundStyle(Color.risingTextSecondaryDark)

                Spacer()

                if !goal.contributorIds.isEmpty {
                    HStack(spacing: -4) {
                        ForEach(goal.contributorIds.prefix(3), id: \.self) { _ in
                            Circle()
                                .fill(Color.risingAccent)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .stroke(Color.risingSurfaceDark, lineWidth: 1)
                                }
                        }
                        Text("\(goal.contributorIds.count) contributors")
                            .font(.caption)
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                }
            }

            Button {
                socialService.deleteSharedGoal(goal.id)
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundStyle(Color.risingError)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }
}

// MARK: - Savings Challenge Card

struct SavingsChallengeCard: View {
    let challenge: RisingR12Service.SavingsChallenge
    @ObservedObject var socialService: RisingR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(challenge.daysRemaining) days left")
                            .font(.caption)
                    }
                    .foregroundStyle(challenge.daysRemaining < 7 ? Color.risingWarning : Color.risingTextSecondaryDark)
                }

                Spacer()

                if challenge.isActive {
                    Circle()
                        .fill(Color.risingSuccess)
                        .frame(width: 8, height: 8)
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(Color.risingSuccess)
                }
            }

            if !challenge.description.isEmpty {
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .lineLimit(2)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target")
                        .font(.caption2)
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    Text("$\(Int(challenge.targetAmount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.risingAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Duration")
                        .font(.caption2)
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    Text("\(challenge.durationDays) days")
                        .font(.subheadline)
                        .foregroundStyle(Color.risingTextPrimaryDark)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "person.2")
                    .font(.caption2)
                Text("\(challenge.participantIds.count) participants")
                    .font(.caption)
            }
            .foregroundStyle(Color.risingTextSecondaryDark)

            Button {
                socialService.deleteChallenge(challenge.id)
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundStyle(Color.risingError)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }
}

// MARK: - Home Buyer Group Card

struct HomeBuyerGroupCard: View {
    let group: RisingR12Service.HomeBuyerGroup
    @ObservedObject var socialService: RisingR12Service

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                        Text(group.city)
                            .font(.caption)
                    }
                    .foregroundStyle(Color.risingPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(group.memberCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.risingTextPrimaryDark)
                    Text("members")
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }

            if !group.description.isEmpty {
                Text(group.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .lineLimit(2)
            }

            Button {
                if group.isJoined {
                    socialService.leaveGroup(group.id)
                } else {
                    socialService.joinGroup(group.id)
                }
            } label: {
                Text(group.isJoined ? "Leave Group" : "Join Group")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(group.isJoined ? Color.risingTextSecondaryDark : Color.risingBackgroundDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(group.isJoined ? Color.risingCardDark : Color.risingPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }
}

// MARK: - New Post Sheet

struct NewCommunityPostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: RisingR12Service
    @State private var content = ""
    @State private var selectedType: RisingR12Service.CommunityPost.PostType = .question
    @State private var city = ""
    @State private var isAnonymous = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark.ignoresSafeArea()

                VStack(spacing: RisingSpacing.md) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(RisingR12Service.CommunityPost.PostType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("What's on your mind?", text: $content, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(4...8)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    TextField("City (optional)", text: $city)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    Toggle("Post Anonymously", isOn: $isAnonymous)
                        .tint(Color.risingPrimary)
                        .padding(.horizontal, RisingSpacing.xs)

                    Spacer()

                    Button {
                        _ = socialService.createPost(
                            content: content,
                            type: selectedType,
                            city: city.isEmpty ? nil : city,
                            isAnonymous: isAnonymous
                        )
                        dismiss()
                    } label: {
                        Text("Post")
                            .font(.headline)
                            .foregroundStyle(Color.risingBackgroundDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(content.isEmpty ? Color.risingCardDark : Color.risingPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }
                    .disabled(content.isEmpty)
                }
                .padding(RisingSpacing.md)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - New Shared Goal Sheet

struct NewSharedGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: RisingR12Service
    @State private var name = ""
    @State private var targetAmount = ""
    @State private var isPublic = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark.ignoresSafeArea()

                VStack(spacing: RisingSpacing.md) {
                    TextField("Goal Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    TextField("Target Amount ($)", text: $targetAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    Toggle("Make Public", isOn: $isPublic)
                        .tint(Color.risingPrimary)
                        .padding(.horizontal, RisingSpacing.xs)

                    Spacer()

                    Button {
                        if let amount = Double(targetAmount) {
                            _ = socialService.createSharedGoal(name: name, targetAmount: amount, isPublic: isPublic)
                            dismiss()
                        }
                    } label: {
                        Text("Create Goal")
                            .font(.headline)
                            .foregroundStyle(Color.risingBackgroundDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(name.isEmpty ? Color.risingCardDark : Color.risingPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                }
                .padding(RisingSpacing.md)
            }
            .navigationTitle("New Shared Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - New Challenge Sheet

struct NewChallengeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var socialService: RisingR12Service
    @State private var name = ""
    @State private var description = ""
    @State private var targetAmount = ""
    @State private var durationDays = "30"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark.ignoresSafeArea()

                VStack(spacing: RisingSpacing.md) {
                    TextField("Challenge Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(2...4)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    HStack(spacing: RisingSpacing.md) {
                        TextField("Target ($)", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                        TextField("Days", text: $durationDays)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }

                    Spacer()

                    Button {
                        if let amount = Double(targetAmount), let days = Int(durationDays) {
                            _ = socialService.createChallenge(name: name, description: description, targetAmount: amount, durationDays: days)
                            dismiss()
                        }
                    } label: {
                        Text("Create Challenge")
                            .font(.headline)
                            .foregroundStyle(Color.risingBackgroundDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(name.isEmpty ? Color.risingCardDark : Color.risingAccent)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                }
                .padding(RisingSpacing.md)
            }
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}
