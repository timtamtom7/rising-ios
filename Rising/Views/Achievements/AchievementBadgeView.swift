import SwiftUI

struct AchievementBadgeView: View {
    let achievement: Achievement
    let size: BadgeSize

    enum BadgeSize {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 64
            case .large: return 80
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 26
            case .large: return 34
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
    }

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return Color(hex: "CD7F32")
        case .silver: return Color(hex: "C0C0C0")
        case .gold: return Color(hex: "FFD700")
        case .platinum: return Color(hex: "E5E4E2")
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [tierColor.opacity(0.3), tierColor.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(backgroundGradient)
                    .frame(width: size.dimension, height: size.dimension)

                Circle()
                    .stroke(achievement.isUnlocked ? tierColor : Color.risingTextSecondary.opacity(0.3), lineWidth: 2)
                    .frame(width: size.dimension, height: size.dimension)

                Image(systemName: achievement.icon)
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? tierColor : Color.risingTextSecondary.opacity(0.4))

                if !achievement.isUnlocked {
                    Circle()
                        .fill(Color.risingBackground.opacity(0.6))
                        .frame(width: size.dimension, height: size.dimension)

                    Image(systemName: "lock.fill")
                        .font(.system(size: size.iconSize * 0.5))
                        .foregroundStyle(Color.risingTextSecondary.opacity(0.5))
                }
            }

            if size == .large {
                Text(achievement.title)
                    .font(size.fontSize.bold())
                    .foregroundStyle(achievement.isUnlocked ? Color.risingTextPrimary : Color.risingTextSecondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title), \(achievement.tier.rawValue) tier, \(achievement.isUnlocked ? "unlocked" : "locked")")
        .accessibilityHint(achievement.description)
    }
}

struct AchievementProgressRow: View {
    let achievement: Achievement

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze: return Color(hex: "CD7F32")
        case .silver: return Color(hex: "C0C0C0")
        case .gold: return Color(hex: "FFD700")
        case .platinum: return Color(hex: "E5E4E2")
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            AchievementBadgeView(achievement: achievement, size: .medium)

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(achievement.isUnlocked ? Color.risingTextPrimary : Color.risingTextSecondary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(Color.risingTextSecondary)

                if !achievement.isUnlocked && achievement.progress > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.risingCard)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(tierColor)
                                .frame(width: geometry.size.width * achievement.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.risingPrimary)
            }
        }
        .padding(12)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("Badge sizes") {
    HStack(spacing: 20) {
        AchievementBadgeView(
            achievement: Achievement.allAchievements[0],
            size: .small
        )
        AchievementBadgeView(
            achievement: Achievement.allAchievements[0],
            size: .medium
        )
        AchievementBadgeView(
            achievement: Achievement.allAchievements[0],
            size: .large
        )
    }
    .padding()
    .background(Color.risingBackground)
}
