import SwiftUI

// MARK: - Shareable Goal Card View

struct ShareableGoalCardView: View {
    let goal: Goal

    var body: some View {
        VStack(spacing: RisingSpacing.lg) {
            // Header
            HStack {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.risingPrimary)
                    .accessibilityHidden(true)

                Text("Rising")
                    .risingBodySmall()
                    .foregroundStyle(Color.risingTextSecondary)

                Spacer()
            }

            // Goal name
            Text(goal.name)
                .risingHeading1()
                .foregroundStyle(Color.risingTextPrimary)
                .multilineTextAlignment(.center)

            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.risingCard, lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(
                        Color.risingPrimary,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(goal.progress * 100))%")
                        .risingHeading2()
                        .foregroundStyle(Color.risingTextPrimary)

                    Text("saved")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }
            .accessibilityLabel("\(Int(goal.progress * 100)) percent of goal saved")

            // Amounts
            HStack(spacing: RisingSpacing.xl) {
                VStack(spacing: 2) {
                    Text(goal.currentAmount.formattedCurrency)
                        .risingBody()
                        .foregroundStyle(Color.risingPrimary)

                    Text("Saved")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                }

                VStack(spacing: 2) {
                    Text(goal.targetAmount.formattedCurrency)
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondary)

                    Text("Goal")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                }

                VStack(spacing: 2) {
                    Text(goal.remainingAmount.formattedCurrency)
                        .risingBody()
                        .foregroundStyle(Color.risingAccent)

                    Text("Left")
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }

            // Motivational message
            Text(motivationalMessage)
                .risingCaption()
                .foregroundStyle(Color.risingTextSecondary)
                .italic()
        }
        .padding(RisingSpacing.xl)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }

    private var motivationalMessage: String {
        let progress = goal.progress
        if progress >= 1.0 {
            return "Goal achieved!"
        } else if progress >= 0.75 {
            return "So close! Keep going!"
        } else if progress >= 0.5 {
            return "Halfway there — you've got this!"
        } else if progress >= 0.25 {
            return "Great start! Every deposit counts."
        } else {
            return "The journey of a thousand miles begins with a single step."
        }
    }
}

// MARK: - Share Card Wrapper (with capture support)

struct ShareCardWrapper: View {
    let goal: Goal
    let onShare: (UIImage) -> Void

    @State private var cardImage: UIImage?

    var body: some View {
        VStack {
            ShareableGoalCardView(goal: goal)
                .padding(RisingSpacing.lg)
        }
        .background(Color.risingBackground)
    }
}

// MARK: - Share Sheet

struct ShareCardSheet: View {
    let goal: Goal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground
                    .ignoresSafeArea()

                VStack(spacing: RisingSpacing.xl) {
                    Text("Share Your Progress")
                        .risingHeading1()
                        .foregroundStyle(Color.risingTextPrimary)

                    Text("Let your friends know you're working toward your goal!")
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Preview Card
                    ShareableGoalCardView(goal: goal)
                        .padding(.horizontal, RisingSpacing.md)

                    // Share Button
                    ShareLink(
                        item: shareText,
                        preview: SharePreview(goal.name, image: Image(systemName: "chart.line.uptrend.xyaxis"))
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .accessibilityHidden(true)
                            Text("Share Card")
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, RisingSpacing.md)
                        .background(Color.risingPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                    }
                    .accessibilityLabel("Share \(goal.name) progress card")
                    .padding(.horizontal, RisingSpacing.lg)

                    Spacer()
                }
                .padding(.top, RisingSpacing.xl)
            }
            .navigationTitle("Share Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.risingPrimary)
                }
            }
        }
    }

    private var shareText: String {
        let percent = Int(goal.progress * 100)
        return "I'm \(percent)% toward my \(goal.name)! Rising helps me track my savings goals — check it out!"
    }
}

#Preview {
    ShareableGoalCardView(goal: Goal(
        name: "House Down Payment",
        targetAmount: 50000,
        currentAmount: 17500
    ))
    .background(Color.risingBackground)
}
