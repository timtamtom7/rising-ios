import SwiftUI
import StoreKit

struct SubscriptionPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SubscriptionPaywallViewModel()
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        featuresSection

                        tierCardsSection

                        restoreButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Rising Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                }
            }
            .task {
                await viewModel.loadProducts()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.risingPrimary)
                .accessibilityHidden(true)

            Text("Unlock Your Full Potential")
                .font(.title2.bold())
                .foregroundStyle(Color.risingTextPrimary)
                .multilineTextAlignment(.center)

            Text("Get unlimited goals, AI-powered savings advice, and advanced analytics.")
                .font(.subheadline)
                .foregroundStyle(Color.risingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.featureHighlights, id: \.icon) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.body)
                        .foregroundStyle(Color.risingPrimary)
                        .frame(width: 24)
                        .accessibilityHidden(true)

                    Text(feature.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.risingTextPrimary)

                    Spacer()

                    if feature.isPremium {
                        Text("Premium")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.risingPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.risingPrimary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var tierCardsSection: some View {
        VStack(spacing: 12) {
            ForEach(SubscriptionService.SubscriptionTier.allCases, id: \.self) { tier in
                TierCard(
                    tier: tier,
                    isSelected: viewModel.selectedTier == tier,
                    isLoading: viewModel.isPurchasing && viewModel.selectedTier == tier
                ) {
                    viewModel.selectedTier = tier
                } onSubscribe: {
                    await subscribe(to: tier)
                }
            }
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await viewModel.restorePurchases()
                if !viewModel.isSubscribed {
                    errorMessage = "No previous purchases found to restore."
                    showError = true
                } else {
                    dismiss()
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(Color.risingTextSecondary)
        }
        .padding(.top, 8)
    }

    private func subscribe(to tier: SubscriptionService.SubscriptionTier) async {
        do {
            let success = try await viewModel.purchase(tier)
            if success {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct TierCard: View {
    let tier: SubscriptionService.SubscriptionTier
    let isSelected: Bool
    let isLoading: Bool
    let onSelect: () -> Void
    let onSubscribe: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(tier == .monthly ? "Monthly" : "Yearly")
                            .font(.headline)
                            .foregroundStyle(Color.risingTextPrimary)

                        if tier == .yearly {
                            Text("Best Value")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.risingPrimary)
                                .clipShape(Capsule())
                        }
                    }

                    Text(tier.price)
                        .font(.title3.bold())
                        .foregroundStyle(Color.risingPrimary)
                }

                Spacer()

                Button {
                    Task {
                        await onSubscribe()
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Subscribe")
                                .font(.subheadline.bold())
                        }
                    }
                    .frame(width: 100, height: 36)
                    .background(Color.risingPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isLoading)
            }

            Divider()
                .background(Color.risingTextSecondary.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(tier.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundStyle(Color.risingPrimary)
                            .accessibilityHidden(true)

                        Text(feature)
                            .font(.caption)
                            .foregroundStyle(Color.risingTextSecondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.risingPrimary : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tier == .monthly ? "Monthly" : "Yearly") plan, \(tier.price)")
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }
}

@MainActor
@Observable
final class SubscriptionPaywallViewModel {
    private let subscriptionService: SubscriptionService

    var products: [Product] = []
    var selectedTier: SubscriptionService.SubscriptionTier = .yearly
    var isPurchasing = false
    var isLoading = false

    init(subscriptionService: SubscriptionService = .shared) {
        self.subscriptionService = subscriptionService
    }

    var isSubscribed: Bool {
        switch subscriptionService.subscriptionStatus {
        case .notSubscribed:
            return false
        case .subscribed, .trialDaysRemaining:
            return true
        }
    }

    var featureHighlights: [(icon: String, title: String, isPremium: Bool)] {
        [
            ("target", "Unlimited Savings Goals", false),
            ("brain", "AI Savings Advice", true),
            ("chart.bar.xaxis", "Advanced Analytics", true),
            ("building.columns", "Plaid Bank Sync", true),
            ("headphones", "Priority Support", true)
        ]
    }

    func loadProducts() async {
        isLoading = true
        await subscriptionService.loadProducts()
        products = subscriptionService.products
        isLoading = false
    }

    func purchase(_ tier: SubscriptionService.SubscriptionTier) async throws -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        return try await subscriptionService.purchase(tier)
    }

    func restorePurchases() async {
        await subscriptionService.restorePurchases()
    }
}

#Preview {
    SubscriptionPaywallView()
}
