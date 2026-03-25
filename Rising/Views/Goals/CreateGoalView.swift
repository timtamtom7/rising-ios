import SwiftUI

struct CreateGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CreateGoalViewModel()
    @State private var showError = false
    @State private var errorMessage = ""

    let onGoalCreated: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.risingBackgroundDark
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RisingSpacing.lg) {
                        // Goal Name
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Goal Name")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("e.g. House Down Payment", text: $viewModel.name)
                                .font(.body)
                                .foregroundStyle(Color.risingTextPrimaryDark)
                                .padding(RisingSpacing.md)
                                .background(Color.risingSurfaceDark)
                                .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                                .tint(Color.risingPrimary)
                        }

                        // Target Amount
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Target Amount")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            HStack {
                                Text("$")
                                    .risingBody()
                                    .foregroundStyle(Color.risingTextSecondaryDark)

                                TextField("25,000", text: $viewModel.targetAmount)
                                    .font(.body)
                                    .foregroundStyle(Color.risingTextPrimaryDark)
                                    .keyboardType(.decimalPad)
                                    .tint(Color.risingPrimary)
                            }
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                        }

                        // Deadline Toggle
                        Toggle(isOn: $viewModel.hasDeadline) {
                            Text("Set a target date")
                                .risingBody()
                                .foregroundStyle(Color.risingTextPrimaryDark)
                        }
                        .tint(Color.risingPrimary)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                        if viewModel.hasDeadline {
                            DatePicker(
                                "Target Date",
                                selection: $viewModel.deadline,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .tint(Color.risingPrimary)
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                            .foregroundStyle(Color.risingTextSecondaryDark)
                        }

                        // Icon Picker
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Icon")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: RisingSpacing.sm) {
                                ForEach(viewModel.iconOptions, id: \.self) { icon in
                                    Button {
                                        viewModel.selectedIcon = icon
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(viewModel.selectedIcon == icon
                                                    ? Color.risingPrimary.opacity(0.2)
                                                    : Color.risingSurfaceDark)
                                                .frame(width: 50, height: 50)

                                            Image(systemName: icon)
                                                .font(.system(size: 20))
                                                .foregroundStyle(
                                                    viewModel.selectedIcon == icon
                                                    ? Color.risingPrimary
                                                    : Color.risingTextSecondaryDark
                                                )
                                        }
                                    }
                                }
                            }
                            .padding(RisingSpacing.md)
                            .background(Color.risingSurfaceDark)
                            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
                        }

                        // Description
                        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
                            Text("Description (optional)")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("Why is this important?", text: $viewModel.description, axis: .vertical)
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
            .navigationTitle("New Goal")
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
                    .disabled(!viewModel.isValid)
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
        do {
            try await viewModel.save()
            onGoalCreated()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    CreateGoalView(onGoalCreated: {})
}
