import SwiftUI

// R12: Community & Social Features View
struct CommunityView: View {
    @State private var viewModel = CommunityViewModel()
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
                Color.risingBackground
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
                NewCommunityPostSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingNewGoal) {
                NewSharedGoalSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingNewChallenge) {
                NewChallengeSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.load()
            }
        }
    }

    // MARK: - Feed View

    private var feedView: some View {
        LazyVStack(spacing: RisingSpacing.md) {
            ForEach(viewModel.communityPosts) { post in CommunityPostCard(post: post, viewModel: viewModel) }

            if viewModel.communityPosts.isEmpty {
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
                .accessibilityHidden(true)

            Text("No posts yet")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondary)

            Text("Ask questions, share tips, and celebrate milestones with other homebuyers")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewPost = true
            } label: {
                Text("Create Post")
                    .risingBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackground)
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
            ForEach(viewModel.sharedGoals) { goal in
                SharedGoalCard(goal: goal, viewModel: viewModel) }

            if viewModel.sharedGoals.isEmpty {
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
                .accessibilityHidden(true)

            Text("No shared goals")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondary)

            Text("Track your homeownership savings together with family or partners")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewGoal = true
            } label: {
                Text("Create Goal")
                    .risingBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackground)
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
            ForEach(viewModel.savingsChallenges) { challenge in
                SavingsChallengeCard(challenge: challenge, viewModel: viewModel)
            }

            if viewModel.savingsChallenges.isEmpty {
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
                .accessibilityHidden(true)

            Text("No challenges")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondary)

            Text("Start a savings challenge to stay motivated")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewChallenge = true
            } label: {
                Text("Create Challenge")
                    .risingBody()
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.risingBackground)
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
            ForEach(viewModel.homeBuyerGroups) { group in
                HomeBuyerGroupCard(group: group, viewModel: viewModel)
            }

            if viewModel.homeBuyerGroups.isEmpty {
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
                .accessibilityHidden(true)

            Text("No groups yet")
                .risingHeading3()
                .foregroundStyle(Color.risingTextSecondary)

            Text("Join a homebuyer group in your city")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 48)
    }
}

// MARK: - Community Post Card

struct CommunityPostCard: View {
    let post: RisingR12Service.CommunityPost
    let viewModel: CommunityViewModel

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
                            .foregroundStyle(Color.risingTextPrimary)

                        if let city = post.city {
                            Text("in \(city)")
                                .font(.caption)
                                .foregroundStyle(Color.risingTextSecondary)
                        }
                    }

                    Text(formatDate(post.createdAt))
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondary)
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
                .foregroundStyle(Color.risingTextPrimary)
                .lineLimit(5)

            Divider()
                .background(Color.risingCard)

            HStack(spacing: RisingSpacing.md) {
                ForEach(RisingR12Service.CommunityPost.Reaction.ReactionType.allCases, id: \.self) { reactionType in
                    let reaction = post.reactions.first { $0.type == reactionType }
                    let count = reaction?.count ?? 0
                    let hasReacted = reaction?.hasReacted ?? false

                    Button {
                        viewModel.reactToPost(post.id, reaction: reactionType)
                    } label: {
                        HStack(spacing: 2) {
                            Text(reactionType.rawValue)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundStyle(hasReacted ? Color.risingPrimary : Color.risingTextSecondary)
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
        .background(Color.risingSurface)
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
    let viewModel: CommunityViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: goal.isPublic ? "globe" : "lock")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text(goal.isPublic ? "Public" : "Private")
                            .font(.caption)
                    }
                    .foregroundStyle(goal.isPublic ? Color.risingPrimary : Color.risingTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(goal.progress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.risingPrimary)
                    Text("progress")
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingCard)
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
                    .foregroundStyle(Color.risingTextPrimary)
                Text("/ $\(Int(goal.targetAmount))")
                    .font(.caption)
                    .foregroundStyle(Color.risingTextSecondary)

                Spacer()

                if !goal.contributorIds.isEmpty {
                    HStack(spacing: -4) {
                        ForEach(goal.contributorIds.prefix(3), id: \.self) { _ in
                            Circle()
                                .fill(Color.risingAccent)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .stroke(Color.risingSurface, lineWidth: 1)
                                }
                        }
                        Text("\(goal.contributorIds.count) contributors")
                            .font(.caption)
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                }
            }

            Button {
                viewModel.deleteSharedGoal(goal.id)
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundStyle(Color.risingError)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        .accessibilityLabel("Shared goal: \(goal.name), \(Int(goal.progress * 100))% progress, \(goal.isPublic ? "Public" : "Private")")
    }
}

// MARK: - Savings Challenge Card

struct SavingsChallengeCard: View {
    let challenge: RisingR12Service.SavingsChallenge
    let viewModel: CommunityViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text("\(challenge.daysRemaining) days left")
                            .font(.caption)
                    }
                    .foregroundStyle(challenge.daysRemaining < 7 ? Color.risingWarning : Color.risingTextSecondary)
                }

                Spacer()

                if challenge.isActive {
                    Circle()
                        .fill(Color.risingSuccess)
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(Color.risingSuccess)
                }
            }

            if !challenge.description.isEmpty {
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.risingTextSecondary)
                    .lineLimit(2)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target")
                        .font(.caption2)
                        .foregroundStyle(Color.risingTextSecondary)
                    Text("$\(Int(challenge.targetAmount))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.risingAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Duration")
                        .font(.caption2)
                        .foregroundStyle(Color.risingTextSecondary)
                    Text("\(challenge.durationDays) days")
                        .font(.subheadline)
                        .foregroundStyle(Color.risingTextPrimary)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "person.2")
                    .font(.caption2)
                    .accessibilityHidden(true)
                Text("\(challenge.participantIds.count) participants")
                    .font(.caption)
            }
            .foregroundStyle(Color.risingTextSecondary)

            Button {
                viewModel.deleteChallenge(challenge.id)
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundStyle(Color.risingError)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        .accessibilityLabel("Savings challenge: \(challenge.name), \(challenge.daysRemaining) days left, target $\(Int(challenge.targetAmount))")
    }
}

// MARK: - Home Buyer Group Card

struct HomeBuyerGroupCard: View {
    let group: RisingR12Service.HomeBuyerGroup
    let viewModel: CommunityViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundStyle(Color.risingTextPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                            .accessibilityHidden(true)
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
                        .foregroundStyle(Color.risingTextPrimary)
                    Text("members")
                        .font(.caption)
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }

            if !group.description.isEmpty {
                Text(group.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.risingTextSecondary)
                    .lineLimit(2)
            }

            Button {
                if group.isJoined {
                    viewModel.leaveGroup(group.id)
                } else {
                    viewModel.joinGroup(group.id)
                }
            } label: {
                Text(group.isJoined ? "Leave Group" : "Join Group")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(group.isJoined ? Color.risingTextSecondary : Color.risingBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(group.isJoined ? Color.risingCard : Color.risingPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        .accessibilityLabel("Home buyer group: \(group.name) in \(group.city), \(group.memberCount) members")
    }
}

// MARK: - New Post Sheet

struct NewCommunityPostSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: CommunityViewModel
    @State private var content = ""
    @State private var selectedType: RisingR12Service.CommunityPost.PostType = .question
    @State private var city = ""
    @State private var isAnonymous = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground.ignoresSafeArea()

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
                        .background(Color.risingSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    TextField("City (optional)", text: $city)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    Toggle("Post Anonymously", isOn: $isAnonymous)
                        .tint(Color.risingPrimary)
                        .padding(.horizontal, RisingSpacing.xs)

                    Spacer()

                    Button {
                        viewModel.createPost(
                            content: content,
                            type: selectedType,
                            city: city.isEmpty ? nil : city,
                            isAnonymous: isAnonymous
                        )
                        dismiss()
                    } label: {
                        Text("Post")
                            .font(.headline)
                            .foregroundStyle(Color.risingBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(content.isEmpty ? Color.risingCard : Color.risingPrimary)
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
    let viewModel: CommunityViewModel
    @State private var name = ""
    @State private var targetAmount = ""
    @State private var isPublic = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground.ignoresSafeArea()

                VStack(spacing: RisingSpacing.md) {
                    TextField("Goal Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    TextField("Target Amount ($)", text: $targetAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    Toggle("Make Public", isOn: $isPublic)
                        .tint(Color.risingPrimary)
                        .padding(.horizontal, RisingSpacing.xs)

                    Spacer()

                    Button {
                        if let amount = Double(targetAmount) {
                            viewModel.createSharedGoal(name: name, targetAmount: amount, isPublic: isPublic)
                            dismiss()
                        }
                    } label: {
                        Text("Create Goal")
                            .font(.headline)
                            .foregroundStyle(Color.risingBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(name.isEmpty ? Color.risingCard : Color.risingPrimary)
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
    let viewModel: CommunityViewModel
    @State private var name = ""
    @State private var description = ""
    @State private var targetAmount = ""
    @State private var durationDays = "30"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground.ignoresSafeArea()

                VStack(spacing: RisingSpacing.md) {
                    TextField("Challenge Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(2...4)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurface)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                    HStack(spacing: RisingSpacing.md) {
                        TextField("Target ($)", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurface)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                        TextField("Days", text: $durationDays)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.plain)
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurface)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }

                    Spacer()

                    Button {
                        if let amount = Double(targetAmount), let days = Int(durationDays) {
                            viewModel.createChallenge(name: name, description: description, targetAmount: amount, durationDays: days)
                            dismiss()
                        }
                    } label: {
                        Text("Create Challenge")
                            .font(.headline)
                            .foregroundStyle(Color.risingBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(name.isEmpty ? Color.risingCard : Color.risingAccent)
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
