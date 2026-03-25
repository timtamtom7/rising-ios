import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    @State private var isCompleting = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Background
            Color.risingBackgroundDark
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: RisingSpacing.xxs) {
                    ForEach(0..<viewModel.totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(index <= viewModel.currentStep ? Color.risingPrimary : Color.risingCardDark)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, RisingSpacing.lg)
                .padding(.top, RisingSpacing.lg)

                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView()
                        .tag(0)

                    FirstGoalStepView(viewModel: viewModel)
                        .tag(1)

                    WhyRisingStepView()
                        .tag(2)

                    ReadyStepView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)

                // Navigation buttons
                VStack(spacing: RisingSpacing.md) {
                    if viewModel.currentStep == 1 && !viewModel.isValidGoal {
                        Text("Please enter a goal name and target amount.")
                            .risingCaption()
                            .foregroundStyle(.red)
                    }

                    HStack(spacing: RisingSpacing.md) {
                        if viewModel.currentStep > 0 {
                            Button {
                                viewModel.previousStep()
                            } label: {
                                Text("Back")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(Color.risingTextSecondaryDark)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, RisingSpacing.md)
                                    .background(Color.risingCardDark)
                                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                            }
                        }

                        Button {
                            Task {
                                await handleNext()
                            }
                        } label: {
                            if isCompleting {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, RisingSpacing.md)
                                    .background(Color.risingPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                            } else {
                                Text(buttonTitle)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, RisingSpacing.md)
                                    .background(
                                        viewModel.canProceed ? Color.risingPrimary : Color.risingCardDark
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                            }
                        }
                        .disabled(!viewModel.canProceed || isCompleting)
                    }
                    .padding(.horizontal, RisingSpacing.lg)
                    .padding(.bottom, RisingSpacing.xl)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private var buttonTitle: String {
        switch viewModel.currentStep {
        case 0: return "Let's Go"
        case 1: return "Create Goal"
        case 2: return "Continue"
        case 3: return "Start Saving"
        default: return "Next"
        }
    }

    private func handleNext() async {
        if viewModel.currentStep == viewModel.totalSteps - 1 {
            isCompleting = true
            do {
                try await viewModel.completeOnboarding()
                hasCompletedOnboarding = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isCompleting = false
        } else {
            viewModel.nextStep()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
