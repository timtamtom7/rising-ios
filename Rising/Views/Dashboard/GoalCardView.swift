import SwiftUI

struct GoalCardView: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: RisingSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.risingPrimary.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: goal.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.risingPrimary)
                    .accessibilityHidden(true)
            }

            // Info
            VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                Text(goal.name)
                    .risingHeading3()
                    .foregroundStyle(Color.risingTextPrimary)
                    .lineLimit(1)
                    .accessibilityLabel("\(goal.name) goal")

                HStack(spacing: RisingSpacing.xxs) {
                    Text(goal.currentAmount.formattedCurrency)
                        .risingBodySmall()
                        .foregroundStyle(Color.risingPrimary)

                    Text("of \(goal.targetAmount.formattedCurrency)")
                        .risingBodySmall()
                        .foregroundStyle(Color.risingTextSecondary)
                }
                .accessibilityLabel("\(goal.currentAmount.formattedCurrency) of \(goal.targetAmount.formattedCurrency) saved")

                if let days = goal.daysRemaining {
                    Text("\(days) days remaining")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                        .accessibilityLabel("\(days) days remaining to reach goal")
                }
            }

            Spacer()

            // Progress Ring
            ProgressRingView(progress: goal.progress, size: 44)
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }

}

// MARK: - Progress Ring

struct ProgressRingView: View {
    let progress: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 5

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.risingCard, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    Color.risingPrimary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)

            Text("\(Int(progress * 100))%")
                .risingCaption()
                .foregroundStyle(Color.risingTextPrimary)
                .font(.system(size: size * 0.22, weight: .semibold))
        }
        .frame(width: size, height: size)
        .accessibilityLabel("\(Int(progress * 100)) percent progress")
    }
}

#Preview {
    GoalCardView(goal: Goal(
        name: "House Down Payment",
        targetAmount: 50000,
        currentAmount: 15000,
        deadline: Calendar.current.date(byAdding: .month, value: 6, to: Date())
    ))
    .padding()
    .background(Color.risingBackground)
}
