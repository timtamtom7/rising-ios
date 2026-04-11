import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var showCreateGoal = false
    @State private var showSettings = false
    @State private var showCommunity = false
    @State private var showAchievements = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.goals.isEmpty {
                    ProgressView()
                        .tint(Color.risingPrimary)
                } else if viewModel.isEmpty {
                    EmptyDashboardView(onCreateGoal: { showCreateGoal = true })
                } else {
                    goalsList
                }
            }
            .navigationTitle("Rising")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: RisingSpacing.sm) {
                        Button {
                            showAchievements = true
                        } label: {
                            Image(systemName: "trophy")
                                .foregroundStyle(Color.risingAccent)
                                .accessibilityLabel("Achievements")
                        }

                        Button {
                            showCommunity = true
                        } label: {
                            Image(systemName: "person.3")
                                .foregroundStyle(Color.risingPrimary)
                                .accessibilityLabel("Community")
                        }
                        
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color.risingTextSecondary)
                                .accessibilityLabel("Settings")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView(onGoalCreated: {
                    Task { await viewModel.load() }
                })
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showCommunity) {
                CommunityView()
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
            .errorAlert(errorMessage: $viewModel.errorMessage) {
                Task { await viewModel.load() }
            }
        }
    }

    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: RisingSpacing.md) {
                // Summary Card
                summaryCard
                    .padding(.horizontal, RisingSpacing.md)

                // Goals Section
                ForEach(viewModel.goals) { goal in
                    NavigationLink {
                        GoalDetailView(goal: goal)
                    } label: {
                        GoalCardView(goal: goal)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteGoal(goal) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.horizontal, RisingSpacing.md)
                }

                // Add Goal Button
                Button {
                    showCreateGoal = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Goal")
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.risingPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, RisingSpacing.md)
                    .background(Color.risingSurface)
                    .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                }
                .padding(.horizontal, RisingSpacing.md)
                .padding(.bottom, RisingSpacing.xl)
            }
            .padding(.top, RisingSpacing.md)
        }
    }

    private var summaryCard: some View {
        VStack(spacing: RisingSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                    Text("Total Saved")
                        .risingLabel()
                        .foregroundStyle(Color.risingTextSecondary)

                    Text(viewModel.totalSaved.formattedCurrency)
                        .risingHeading1()
                        .foregroundStyle(Color.risingTextPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: RisingSpacing.xxs) {
                    Text("Goal")
                        .risingLabel()
                        .foregroundStyle(Color.risingTextSecondary)

                    Text(viewModel.totalTarget.formattedCurrency)
                        .risingHeading2()
                        .foregroundStyle(Color.risingTextSecondary)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingCard)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingPrimary)
                        .frame(width: geometry.size.width * min(viewModel.overallProgress, 1.0), height: 8)
                        .animation(.easeOut(duration: 0.6), value: viewModel.overallProgress)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(Int(viewModel.overallProgress * 100))% of total goal")
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondary)

                Spacer()

                Text("\(viewModel.goals.count) goal\(viewModel.goals.count == 1 ? "" : "s")")
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondary)
            }
        }
        .padding(RisingSpacing.lg)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
        .accessibilityLabel("Summary: \(Int(viewModel.overallProgress * 100))% of total goal, \(viewModel.goals.count) goals, total saved \(viewModel.totalSaved.formattedCurrency) of \(viewModel.totalTarget.formattedCurrency)")
    }
}

#Preview {
    DashboardView()
}
