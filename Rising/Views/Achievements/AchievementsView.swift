import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AchievementsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RisingSpacing.lg) {
                        progressHeader

                        if !viewModel.recentUnlocked.isEmpty {
                            recentSection
                        }

                        allAchievementsSection
                    }
                    .padding(.horizontal, RisingSpacing.md)
                    .padding(.vertical, RisingSpacing.lg)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                }
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: RisingSpacing.md) {
            HStack(spacing: RisingSpacing.lg) {
                ZStack {
                    Circle()
                        .stroke(Color.risingCard, lineWidth: 6)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: viewModel.progressPercent)
                        .stroke(Color.risingPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: viewModel.progressPercent)

                    VStack(spacing: 0) {
                        Text("\(viewModel.unlockedCount)")
                            .font(.title3.bold())
                            .foregroundStyle(Color.risingTextPrimary)
                        Text("of \(viewModel.totalCount)")
                            .font(.caption2)
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                    Text("Your Badges")
                        .font(.title2.bold())
                        .foregroundStyle(Color.risingTextPrimary)

                    Text(viewModel.motivationText)
                        .font(.subheadline)
                        .foregroundStyle(Color.risingTextSecondary)
                }

                Spacer()
            }
        }
        .padding(RisingSpacing.lg)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            Text("Recently Unlocked")
                .font(.headline)
                .foregroundStyle(Color.risingTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RisingSpacing.md) {
                    ForEach(viewModel.recentUnlocked) { achievement in
                        AchievementBadgeView(achievement: achievement, size: .large)
                    }
                }
            }
        }
    }

    private var allAchievementsSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            Text("All Achievements")
                .font(.headline)
                .foregroundStyle(Color.risingTextPrimary)

            LazyVStack(spacing: RisingSpacing.sm) {
                ForEach(viewModel.sortedAchievements) { achievement in
                    AchievementProgressRow(achievement: achievement)
                }
            }
        }
    }
}

@MainActor
@Observable
final class AchievementsViewModel {
    private let achievementService: AchievementService

    init(achievementService: AchievementService = .shared) {
        self.achievementService = achievementService
    }

    var achievements: [Achievement] { achievementService.achievements }
    var unlockedCount: Int { achievementService.unlockedCount }
    var totalCount: Int { achievementService.totalCount }
    var recentUnlocked: [Achievement] { achievementService.recentAchievements }

    var progressPercent: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }

    var sortedAchievements: [Achievement] {
        achievementService.achievements.sorted { a, b in
            if a.isUnlocked != b.isUnlocked {
                return a.isUnlocked
            }
            return a.tier.sortOrder > b.tier.sortOrder
        }
    }

    var motivationText: String {
        switch progressPercent {
        case 0..<0.1: return "Every journey starts with a single step"
        case 0.1..<0.25: return "You're making great progress"
        case 0.25..<0.5: return "Halfway there — keep it up"
        case 0.5..<0.75: return "You're on fire. Amazing dedication"
        case 0.75..<1.0: return "Almost complete — so close"
        case 1.0: return "Master saver. Impressive discipline"
        default: return "Keep saving"
        }
    }
}

extension Achievement.Tier {
    var sortOrder: Int {
        switch self {
        case .platinum: return 4
        case .gold: return 3
        case .silver: return 2
        case .bronze: return 1
        }
    }
}

#Preview {
    AchievementsView()
}
