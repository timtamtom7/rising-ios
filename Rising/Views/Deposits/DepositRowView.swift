import SwiftUI

struct DepositRowView: View {
    let deposit: Deposit
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: RisingSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.risingSuccess.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.risingSuccess)
            }

            // Info
            VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                Text(formatCurrency(deposit.amount))
                    .risingBody()
                    .foregroundStyle(Color.risingSuccess)

                if let note = deposit.note, !note.isEmpty {
                    Text(note)
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondaryDark)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Date
            VStack(alignment: .trailing, spacing: RisingSpacing.xxs) {
                Text(formatDate(deposit.date))
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondaryDark)
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurfaceDark)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    DepositRowView(
        deposit: Deposit(
            goalId: UUID(),
            amount: 500,
            date: Date(),
            note: "Weekly deposit"
        ),
        onDelete: {}
    )
    .padding()
    .background(Color.risingBackgroundDark)
}
