import SwiftUI

struct AgentListView: View {
    @State private var viewModel = AgentListViewModel()
    @State private var showAddAgent = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.agents.isEmpty {
                emptyState
            } else {
                agentList
            }
        }
        .sheet(isPresented: $showAddAgent) {
            AddAgentView {
                Task { await viewModel.load() }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var emptyState: some View {
        VStack(spacing: RisingSpacing.md) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(Color.risingTextSecondaryDark)

            Text("No agents yet")
                .risingBody()
                .foregroundStyle(Color.risingTextSecondaryDark)

            Button {
                showAddAgent = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Agent")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, RisingSpacing.lg)
                .padding(.vertical, RisingSpacing.sm)
                .background(Color.risingPrimary)
                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RisingSpacing.xl)
    }

    private var agentList: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.md) {
            HStack {
                Text("Agents")
                    .risingHeading2()
                    .foregroundStyle(Color.risingTextPrimaryDark)

                Spacer()

                Button {
                    showAddAgent = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.risingPrimary)
                }
            }

            ForEach(viewModel.agents) { agent in
                AgentCardView(agent: agent) {
                    Task { await viewModel.delete(agent) }
                }
            }
        }
    }
}

// MARK: - Agent Card View

struct AgentCardView: View {
    let agent: Agent
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.sm) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.risingAccent.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Text(agent.name.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.risingAccent)
                }

                VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                    Text(agent.name)
                        .risingBody()
                        .foregroundStyle(Color.risingTextPrimaryDark)

                    if let phone = agent.phone, !phone.isEmpty {
                        HStack(spacing: RisingSpacing.xxs) {
                            Image(systemName: "phone")
                                .font(.caption)
                            Text(phone)
                                .risingCaption()
                        }
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    }
                }

                Spacer()
            }

            HStack(spacing: RisingSpacing.md) {
                if let phone = agent.phone, !phone.isEmpty {
                    Button {
                        if let url = URL(string: "tel:\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "phone.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.risingSuccess)
                    }
                }

                if let email = agent.email, !email.isEmpty {
                    Button {
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.risingPrimary)
                    }
                }

                Spacer()
            }

            if let notes = agent.notes, !notes.isEmpty {
                Text(notes)
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondaryDark)
                    .lineLimit(3)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    AgentListView()
        .background(Color.risingBackgroundDark)
}
