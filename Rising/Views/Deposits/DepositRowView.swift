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
                    .accessibilityHidden(true)
            }

            // Info
            VStack(alignment: .leading, spacing: RisingSpacing.xxs) {
                Text(deposit.amount.formattedCurrency)
                    .risingBody()
                    .foregroundStyle(Color.risingSuccess)
                    .accessibilityLabel("\(deposit.amount.formattedCurrency) deposit")

                if let note = deposit.note, !note.isEmpty {
                    Text(note)
                        .risingCaption()
                        .foregroundStyle(Color.risingTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Date
            VStack(alignment: .trailing, spacing: RisingSpacing.xxs) {
                Text(formatDate(deposit.date))
                    .risingCaption()
                    .foregroundStyle(Color.risingTextSecondary)
                    .accessibilityLabel("Deposited on \(formatDate(deposit.date))")
            }
        }
        .padding(RisingSpacing.md)
        .background(Color.risingSurface)
        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
        .accessibilityLabel("\(deposit.amount.formattedCurrency) deposit on \(formatDate(deposit.date))")
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
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
    .background(Color.risingBackground)
}
