import SwiftUI

// MARK: - Share Card ViewModel (macOS compatible)

@MainActor
@Observable
final class ShareCardViewModel {
    var isGenerating = false

    func generateCardImage(for goal: Goal) async -> NSImage? {
        isGenerating = true
        defer { isGenerating = false }

        let view = ShareableGoalCardContent(goal: goal)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        return renderer.nsImage
    }
}

// MARK: - Shareable Goal Card Content

struct ShareableGoalCardContent: View {
    let goal: Goal

    var body: some View {
        ZStack {
            Color(hex: "0F172A")

            VStack(spacing: 20) {
                HStack {
                    Image(systemName: goal.iconName)
                        .font(.title)
                        .foregroundStyle(.risingPrimary)
                    Text(goal.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.risingTextPrimary)
                    Spacer()
                }

                HStack(alignment: .bottom, spacing: 12) {
                    Text(formatCurrency(goal.currentAmount))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.risingPrimary)

                    Text("/ \(formatCurrency(goal.targetAmount))")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundStyle(.risingTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ProgressView(value: goal.progress)
                    .tint(.risingPrimary)

                HStack {
                    Text("\(Int(goal.progress * 100))% complete")
                        .font(.subheadline)
                        .foregroundStyle(.risingTextSecondary)
                    Spacer()
                    Text("Rising")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.risingAccent)
                }
            }
            .padding(30)
        }
        .frame(width: 400, height: 280)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
