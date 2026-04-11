import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()
    @State private var showResetAlert = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground
                    .ignoresSafeArea()

                List {
                    // Premium Section
                    Section {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("Rising Premium")
                                    .foregroundStyle(Color.risingTextPrimary)
                                Spacer()
                                Text(viewModel.subscriptionTierName)
                                    .font(.caption)
                                    .foregroundStyle(Color.risingTextSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.risingTextSecondary)
                            }
                        }
                    } header: {
                        Text("Subscription")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                    .listRowBackground(Color.risingSurface)

                    // Appearance Section
                    Section {
                        Picker("Theme", selection: $viewModel.themeMode) {
                            Text("Dark").tag(ThemeService.ThemeMode.dark)
                            Text("Light").tag(ThemeService.ThemeMode.light)
                            Text("System").tag(ThemeService.ThemeMode.system)
                        }
                        .tint(Color.risingPrimary)
                    } header: {
                        Text("Appearance")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                    .listRowBackground(Color.risingSurface)

                    // Investment Tools Section (R7)
                    Section {
                        NavigationLink {
                            ROICalculatorView()
                        } label: {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("ROI Calculator")
                                    .foregroundStyle(Color.risingTextPrimary)
                            }
                        }
                        
                        NavigationLink {
                            PortfolioView()
                        } label: {
                            HStack {
                                Image(systemName: "building.columns")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("Investment Portfolio")
                                    .foregroundStyle(Color.risingTextPrimary)
                            }
                        }
                    } header: {
                        Text("Investment Tools")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                    .listRowBackground(Color.risingSurface)

                    // Notifications Section
                    Section {
                        NavigationLink {
                            NotificationSettingsView()
                        } label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("Notifications")
                                    .foregroundStyle(Color.risingTextPrimary)
                            }
                        }
                    } header: {
                        Text("Reminders")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                    .listRowBackground(Color.risingSurface)

                    // Data Section
                    Section {
                        Button {
                            showResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundStyle(Color.risingError)
                                Text("Reset Onboarding")
                                    .foregroundStyle(Color.risingError)
                            }
                        }
                    } header: {
                        Text("Data")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                    .listRowBackground(Color.risingSurface)

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundStyle(Color.risingTextPrimary)
                            Spacer()
                            Text(viewModel.appVersion)
                                .foregroundStyle(Color.risingTextSecondary)
                        }
                    } header: {
                        Text("About")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                    .listRowBackground(Color.risingSurface)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.risingPrimary)
                }
            }
            .alert("Reset Onboarding?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetOnboarding()
                    dismiss()
                }
            } message: {
                Text("This will show the onboarding screens again on next launch.")
            }
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
