import SwiftUI

struct FirstGoalStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RisingSpacing.xl) {
                VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                    Text("Let's start with your first goal")
                        .risingHeading1()
                        .foregroundStyle(Color.risingTextPrimary)

                    Text("What are you saving for?")
                        .risingBody()
                        .foregroundStyle(Color.risingTextSecondary)
                }
                .padding(.top, RisingSpacing.xl)

                VStack(spacing: RisingSpacing.lg) {
                    // Goal Name
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Goal Name")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondary)

                        TextField("e.g. House Down Payment", text: $viewModel.goalName)
                            .font(.body)
                            .foregroundStyle(Color.risingTextPrimary)
                            .padding(RisingSpacing.md)
                            .background(Color.risingCard)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                            .tint(Color.risingPrimary)
                    }

                    // Target Amount
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Target Amount")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondary)

                        HStack {
                            Text("$")
                                .risingBody()
                                .foregroundStyle(Color.risingTextSecondary)

                            TextField("25,000", text: $viewModel.goalTargetAmount)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimary)
                                .keyboardType(.decimalPad)
                                .tint(Color.risingPrimary)
                        }
                        .padding(RisingSpacing.md)
                        .background(Color.risingCard)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                    }

                    // Deadline
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Target Date (optional)")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondary)

                        DatePicker(
                            "Deadline",
                            selection: $viewModel.goalDeadline,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .tint(Color.risingPrimary)
                        .padding(RisingSpacing.sm)
                        .background(Color.risingCard)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                        .foregroundStyle(Color.risingTextSecondary)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Description (optional)")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondary)

                        TextField("Why is this important to you?", text: $viewModel.goalDescription, axis: .vertical)
                            .font(.body)
                            .foregroundStyle(Color.risingTextPrimary)
                            .lineLimit(3...6)
                            .padding(RisingSpacing.md)
                            .background(Color.risingCard)
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
        .background(Color.risingBackground)
}
