import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var showCreateGoal = false
    @State private var showSettings = false
    @State private var showCommunity = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.risingBackgroundDark
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
                            showCommunity = true
                        } label: {
                            Image(systemName: "person.3")
                                .foregroundStyle(Color.risingPrimary)
                        }
                        
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color.risingTextSecondaryDark)
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
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
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
                    .background(Color.risingSurfaceDark)
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
                        .foregroundStyle(Color.risingTextSecondaryDark)

                    Text(formatCurrency(viewModel.totalSaved))
                        .risingHeading1()
                        .foregroundStyle(Color.risingTextPrimaryDark)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: RisingSpacing.xxs) {
                    Text("Goal")
                        .risingLabel()
                        .foregroundStyle(Color.risingTextSecondaryDark)

                    Text(formatCurrency(viewModel.totalTarget))
                        .risingHeading2()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RisingRadius.full)
                        .fill(Color.risingCardDark)
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
                    .foregroundStyle(Color.risingTextSecondaryDark)

                Spacer()

                Text("\(viewModel.goals.count) goal\(viewModel.goals.count == 1 ? "" : "s")")
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }
        }
        .padding(RisingSpacing.lg)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    DashboardView()
}
