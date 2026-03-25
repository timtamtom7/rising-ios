import SwiftUI

struct AddAgentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddAgentViewModel()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    let onSaved: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RisingSpacing.lg) {
                        // Name
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Agent Name")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("Jane Smith", text: $viewModel.name)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .padding(RisingSpacing.md)
                                .background(Color.risingSurfaceDark)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                                .tint(Color.risingPrimary)
                        }

                        // Phone
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Phone (optional)")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("(555) 123-4567", text: $viewModel.phone)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .keyboardType(.phonePad)
                                .padding(RisingSpacing.md)
                                .background(Color.risingSurfaceDark)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                                .tint(Color.risingPrimary)
                        }

                        // Email
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Email (optional)")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("jane@realty.com", text: $viewModel.email)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .keyboardType(.emailAddress)
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

                            TextField("Met at open house March 15...", text: $viewModel.notes, axis: .vertical)
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
            .navigationTitle("Add Agent")
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
    AddAgentView(onSaved: {})
}
