import SwiftUI

struct AddDepositView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddDepositViewModel
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    let onDeposited: () -> Void

    init(goalId: UUID, onDeposited: @escaping () -> Void) {
        _viewModel = State(initialValue: AddDepositViewModel(goalId: goalId))
        self.onDeposited = onDeposited
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark
                    .ignoresSafeArea()

                VStack(spacing: RisingSpacing.lg) {
                    // Amount Input
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Amount")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        HStack {
                            Text("$")
                                .risingDisplay()
                                .foregroundStyle(Color.risingPrimary)

                            TextField("0", text: $viewModel.amount)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                                .tint(Color.risingPrimary)
                        }
                        .padding(RisingSpacing.lg)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.xl))
                    }

                    // Date
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Date")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        DatePicker(
                            "Date",
                            selection: $viewModel.date,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .tint(Color.risingPrimary)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                        .foregroundStyle(Color.risingTextSecondaryDark)
                    }

                    // Note
                    VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                        Text("Note (optional)")
                            .risingLabel()
                            .foregroundStyle(Color.risingTextSecondaryDark)

                        TextField("e.g. Weekly deposit", text: $viewModel.note, axis: .vertical)
                            .font(.body)
                            .foregroundStyle(Color.risingTextPrimaryDark)
                            .lineLimit(2...4)
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                            .tint(Color.risingPrimary)
                    }

                    Spacer()

                    // Save Button
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, RisingSpacing.md)
                                .background(Color.risingPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Add Deposit")
                            }
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RisingSpacing.md)
                            .background(
                                viewModel.isValid ? Color.risingPrimary : Color.risingCardDark
                            )
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.lg))
                        }
                    }
                    .disabled(!viewModel.isValid || isSaving)
                }
                .padding(RisingSpacing.lg)
            }
            .navigationTitle("Add Deposit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.risingTextSecondaryDark)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func save() async {
        isSaving = true
        do {
            try await viewModel.save()
            onDeposited()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }
}

#Preview {
    AddDepositView(goalId: UUID(), onDeposited: {})
}
