import SwiftUI

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: RisingSpacing.xl) {
            Spacer()

            // Logo / Icon
            ZStack {
                Circle()
                    .fill(Color.risingPrimary.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.risingPrimary)
            }

            VStack(spacing: RisingSpacing.md) {
                Text("Your money, rising.")
                    .risingDisplay()
                    .foregroundStyle(Color.risingTextPrimaryDark)
                    .multilineTextAlignment(.center)

                Text("Track your savings goals, visualize your progress, and understand your money — all in one place.")
                    .risingBody()
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RisingSpacing.lg)
            }

            Spacer()
            Spacer()
        }
        .padding(RisingSpacing.lg)
    }
}

#Preview {
    WelcomeStepView()
        .background(Color.risingBackgroundDark)
}
