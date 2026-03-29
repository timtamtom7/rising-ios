import SwiftUI

struct MacDepositSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var date = Date()
    @State private var note = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let goalId: UUID
    let onSaved: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            formContent
            Divider()
            footer
        }
        .frame(width: 420, height: 380)
        .background(Color(hex: "1E293B"))
    }

    private var header: some View {
        HStack {
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.risingPrimary)
            Text("Add Deposit")
                .font(.headline)
                .foregroundStyle(.risingTextPrimary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.risingTextSecondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            amountField
            dateField
            noteField
        }
        .padding(24)
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)

            HStack {
                Text("$")
                    .foregroundStyle(.risingTextSecondary)
                    .padding(.leading, 14)
                    .font(.system(.body, design: .monospaced))

                TextField("0.00", text: $amount)
                    .textFieldStyle(.plain)
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(.risingTextPrimary)
            }
            .padding(14)
            .background(Color(hex: "334155"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var dateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .tint(.risingPrimary)
                .padding(10)
                .background(Color(hex: "334155"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .labelsHidden()
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Note (optional)")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)

            TextField("e.g. Monthly savings", text: $note, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(2...4)
                .padding(12)
                .background(Color(hex: "334155"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.risingTextPrimary)
        }
    }

    private var footer: some View {
        HStack {
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.risingError)
            }
            Spacer()

            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.risingTextSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Button {
                save()
            } label: {
                if isSaving {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Save Deposit", systemImage: "checkmark.circle.fill")
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Color(hex: "10B981"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(isSaving || amount.isEmpty)
        }
        .padding(20)
    }

    private func save() {
        guard let depositAmount = Double(amount), depositAmount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                try await DepositService.shared.create(
                    goalId: goalId,
                    amount: depositAmount,
                    date: date,
                    note: note.isEmpty ? nil : note
                )
                onSaved()
                dismiss()
            } catch {
                errorMessage = "Failed to save deposit."
                isSaving = false
            }
        }
    }
}
