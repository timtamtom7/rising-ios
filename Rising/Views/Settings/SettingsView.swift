import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()
    @State private var showResetAlert = false
    @State private var showNotificationSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark
                    .ignoresSafeArea()

                List {
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
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                    .listRowBackground(Color.risingSurfaceDark)

                    // Investment Tools Section (R7)
                    Section {
                        NavigationLink {
                            ROICalculatorView()
                        } label: {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("ROI Calculator")
                                    .foregroundStyle(Color.risingTextPrimaryDark)
                            }
                        }
                        
                        NavigationLink {
                            PortfolioView()
                        } label: {
                            HStack {
                                Image(systemName: "building.columns")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("Investment Portfolio")
                                    .foregroundStyle(Color.risingTextPrimaryDark)
                            }
                        }
                    } header: {
                        Text("Investment Tools")
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                    .listRowBackground(Color.risingSurfaceDark)

                    // Notifications Section
                    Section {
                        NavigationLink {
                            NotificationSettingsView()
                        } label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(Color.risingPrimary)
                                Text("Notifications")
                                    .foregroundStyle(Color.risingTextPrimaryDark)
                            }
                        }
                    } header: {
                        Text("Reminders")
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                    .listRowBackground(Color.risingSurfaceDark)

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
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                    .listRowBackground(Color.risingSurfaceDark)

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundStyle(Color.risingTextPrimaryDark)
                            Spacer()
                            Text(viewModel.appVersion)
                                .foregroundStyle(Color.risingTextSecondaryDark)
                        }
                    } header: {
                        Text("About")
                            .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                    .listRowBackground(Color.risingSurfaceDark)
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
        }
    }
}

#Preview {
    SettingsView()
}
