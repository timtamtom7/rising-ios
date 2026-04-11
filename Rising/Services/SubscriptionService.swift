import Foundation
import StoreKit

// MARK: - R9: Subscription Service

@MainActor
@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    enum SubscriptionTier: String, CaseIterable, Codable {
        case monthly = "com.rising.premium.monthly"
        case yearly = "com.rising.premium.yearly"

        var price: String {
            switch self {
            case .monthly: return "$4.99/month"
            case .yearly: return "$39.99/year"
            }
        }

        var features: [String] {
            [
                "Unlimited goals",
                "AI savings advice",
                "Advanced analytics",
                "Plaid bank sync",
                "Priority support"
            ]
        }
    }

    enum Status: Equatable {
        case notSubscribed
        case subscribed(SubscriptionTier)
        case trialDaysRemaining(Int)
    }

    var subscriptionStatus: Status = .notSubscribed
    var products: [Product] = []
    var isLoading = false

    private init() {}

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIds = Set(SubscriptionTier.allCases.map { $0.rawValue })
            products = try await Product.products(for: productIds)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ tier: SubscriptionTier) async throws -> Bool {
        guard let product = products.first(where: { $0.id == tier.rawValue }) else {
            throw SubscriptionError.productNotFound
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore: \(error)")
        }
    }

    func updateSubscriptionStatus() async {
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.productType == .autoRenewable {
                    hasActiveSubscription = true

                    if let tier = SubscriptionTier(rawValue: transaction.productID) {
                        if transaction.revocationDate == nil {
                            subscriptionStatus = .subscribed(tier)
                            return
                        }
                    }
                }

                await transaction.finish()
            } catch {
                continue
            }
        }

        if !hasActiveSubscription {
            subscriptionStatus = .notSubscribed
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    enum SubscriptionError: LocalizedError {
        case productNotFound
        case verificationFailed
        case purchaseFailed

        var errorDescription: String? {
            switch self {
            case .productNotFound: return "Product not found"
            case .verificationFailed: return "Purchase verification failed"
            case .purchaseFailed: return "Purchase failed"
            }
        }
    }
}

// MARK: - Feature Gate

struct FeatureGate {
    static func isAvailable(_ feature: Feature, for status: SubscriptionService.Status) -> Bool {
        switch feature {
        case .unlimitedGoals:
            return true
        case .aiSavingsAdvice, .advancedAnalytics, .plaidSync, .prioritySupport, .exportData:
            return isPremium(status)
        case .communityAccess:
            return true
        }
    }

    private static func isPremium(_ status: SubscriptionService.Status) -> Bool {
        switch status {
        case .notSubscribed:
            return false
        case .subscribed, .trialDaysRemaining:
            return true
        }
    }

    enum Feature: String, CaseIterable {
        case unlimitedGoals
        case aiSavingsAdvice
        case advancedAnalytics
        case plaidSync
        case prioritySupport
        case communityAccess
        case exportData
    }
}