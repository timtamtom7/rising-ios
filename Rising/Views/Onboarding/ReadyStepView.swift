import SwiftUI

struct ReadyStepView: View {
    var body: some View {
        VStack(spacing: RisingSpacing.xxl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.risingPrimary.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.risingPrimary)
            }

            VStack(spacing: RisingSpacing.md) {
                Text("You're all set!")
                    .risingDisplay()
                    .foregroundStyle(Color.risingTextPrimaryDark)

                Text("Your first goal is ready. Every deposit brings you closer to your dream.")
                    .risingBody()
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RisingSpacing.lg)
            }

            Spacer()

            // Summary
            VStack(spacing: RisingSpacing.md) {
                HStack {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundStyle(Color.risingPrimary)
                    Text("Track your progress daily")
                        .risingBodySmall()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    Spacer()
                }

                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.risingPrimary)
                    Text("Add deposits to see your goal grow")
                        .risingBodySmall()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    Spacer()
                }

                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(Color.risingPrimary)
                    Text("We'll remind you to stay on track")
                        .risingBodySmall()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    Spacer()
                }
            }
            .padding(RisingSpacing.lg)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
            .padding(.horizontal, RisingSpacing.lg)

            Spacer()
        }
        .padding(RisingSpacing.lg)
    }
}

#Preview {
    ReadyStepView()
        .background(Color.risingBackgroundDark)
}
