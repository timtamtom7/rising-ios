import SwiftUI

struct EmptyDashboardView: View {
    let onCreateGoal: () -> Void

    var body: some View {
        VStack(spacing: RisingSpacing.xl) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(Color.risingPrimary.opacity(0.1))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(Color.risingPrimary.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: "arrow.up.right.circle")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.risingPrimary)
                    .accessibilityHidden(true)
            }

            VStack(spacing: RisingSpacing.md) {
                Text("No goals yet")
                    .risingHeading1()
                    .foregroundStyle(Color.risingTextPrimary)

                Text("Create your first savings goal and watch your money rise.")
                    .risingBody()
                    .foregroundStyle(Color.risingTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RisingSpacing.xl)
            }

            Button {
                onCreateGoal()
            } label: {
                HStack(spacing: RisingSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                        .accessibilityHidden(true)
                    Text("Create Your First Goal")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, RisingSpacing.xl)
                .padding(.vertical, RisingSpacing.md)
                .background(Color.risingPrimary)
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
            }

            Spacer()
        }
    }
}

#Preview {
    EmptyDashboardView(onCreateGoal: {})
        .background(Color.risingBackground)
}
