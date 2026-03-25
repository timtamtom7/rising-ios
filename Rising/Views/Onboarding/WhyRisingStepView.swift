import SwiftUI

struct WhyRisingStepView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: RisingSpacing.xxl) {
                VStack(spacing: RisingSpacing.xl) {
                    Text("Why Rising?")
                        .risingDisplay()
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    Text("Built for people serious about their goals.")
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, RisingSpacing.xxl)

                VStack(spacing: RisingSpacing.lg) {
                    FeatureRow(
                        icon: "target",
                        title: "Set Goals",
                        description: "Define exactly what you're saving for and by when."
                    )

                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Progress",
                        description: "See your savings grow with beautiful visualizations."
                    )

                    FeatureRow(
                        icon: "lightbulb",
                        title: "Understand Your Money",
                        description: "AI-powered insights to help you save smarter."
                    )

                    FeatureRow(
                        icon: "bell",
                        title: "Stay On Track",
                        description: "Reminders and milestones keep you motivated."
                    )
                }
                .padding(.horizontal, RisingSpacing.lg)

                Spacer(minLength: RisingSpacing.xxl)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: RisingSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: RisingRadius.md)
                    .fill(Color.risingPrimary.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.risingPrimary)
            }

            VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                Text(title)
                    .risingHeading3()
                    .foregroundStyle(Color.risingTextPrimaryDark)

                Text(description)
                    .risingBodySmall()
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }

            Spacer()
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
    }
}

#Preview {
    WhyRisingStepView()
        .background(Color.risingBackgroundDark)
}
