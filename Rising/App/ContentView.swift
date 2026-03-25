import SwiftUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = OnboardingService.shared.hasCompletedOnboarding

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                DashboardView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
}
