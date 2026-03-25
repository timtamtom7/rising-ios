import SwiftUI

struct FirstGoalStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RisingSpacing.xl) {
                VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                    Text("Let's start with your first goal")
                        .risingHeading1()
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    Text("What are you saving for?")
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
                .padding(.top, RisingSpacing.xl)

                VStack(spacing: RisingSpacing.lg) {
                    // Goal Name
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Goal Name")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        TextField("e.g. House Down Payment", text: $viewModel.goalName)
                            .font(.body)
                            .foregroundStyle(Color.risingTextPrimaryDark)
                            .padding(RisingSpacing.md)
                            .background(Color.risingCardDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                            .tint(Color.risingPrimary)
                    }

                    // Target Amount
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Target Amount")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        HStack {
                            Text("$")
                                .risingBody()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("25,000", text: $viewModel.goalTargetAmount)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .keyboardType(.decimalPad)
                                .tint(Color.risingPrimary)
                        }
                        .padding(RisingSpacing.md)
                        .background(Color.risingCardDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }

                    // Deadline
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Target Date (optional)")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        DatePicker(
                            "Deadline",
                            selection: $viewModel.goalDeadline,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .tint(Color.risingPrimary)
                        .padding(RisingSpacing.sm)
                        .background(Color.risingCardDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Description (optional)")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        TextField("Why is this important to you?", text: $viewModel.goalDescription, axis: .vertical)
                            .font(.body)
                            .foregroundStyle(Color.risingTextPrimaryDark)
                            .lineLimit(3...6)
                            .padding(RisingSpacing.md)
                            .background(Color.risingCardDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                            .tint(Color.risingPrimary)
                    }
                }

                Spacer(minLength: RisingSpacing.xl)
            }
            .padding(.horizontal, RisingSpacing.lg)
        }
    }
}

#Preview {
    FirstGoalStepView(viewModel: OnboardingViewModel())
        .background(Color.risingBackgroundDark)
}
