import SwiftUI

struct AddPropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddPropertyViewModel
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    let onSaved: () -> Void

    init(goalId: UUID, onSaved: @escaping () -> Void) {
        _viewModel = State(initialValue: AddPropertyViewModel(goalId: goalId))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RisingSpacing.lg) {
                        // Address
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Property Address")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("123 Main St, City, State", text: $viewModel.address)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .padding(RisingSpacing.md)
                                .background(Color.risingSurfaceDark)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                                .tint(Color.risingPrimary)
                        }

                        // Price
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Property Price")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            HStack {
                                Text("$")
                                    .risingBody()
                                    .foregroundStyle(Color.risingTextSecondaryDark)

                                TextField("350,000", text: $viewModel.price)
                                    .font(.body)
                                    .foregroundStyle(Color.risingTextPrimaryDark)
                                    .keyboardType(.numberPad)
                                    .tint(Color.risingPrimary)
                            }
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                        }

                        // Link
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Listing Link (optional)")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("https://zillow.com/...", text: $viewModel.link)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .padding(RisingSpacing.md)
                                .background(Color.risingSurfaceDark)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                                .tint(Color.risingPrimary)
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Notes (optional)")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("Open house March 15, beautiful backyard...", text: $viewModel.notes, axis: .vertical)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .lineLimit(3...6)
                                .padding(RisingSpacing.md)
                                .background(Color.risingSurfaceDark)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                                .tint(Color.risingPrimary)
                        }
                    }
                    .padding(RisingSpacing.lg)
                }
            }
            .navigationTitle("Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.risingTextSecondaryDark)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(viewModel.isValid ? Color.risingPrimary : Color.risingTextSecondaryDark)
                    .disabled(!viewModel.isValid || isSaving)
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
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }
}

#Preview {
    AddPropertyView(goalId: UUID(), onSaved: {})
}
