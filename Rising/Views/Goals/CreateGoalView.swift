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
                        goalNameSection
                        targetAmountSection
                        deadlineSection
                        iconPickerSection
                        descriptionSection
                    }
                    .padding(RisingSpacing.lg)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    cancelButton
                }

                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Sections

    private var goalNameSection: some View {
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
    }

    private var targetAmountSection: some View {
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
    }

    private var deadlineSection: some View {
        VStack(spacing: RisingSpacing.sm) {
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
        }
    }

    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: RisingSpacing.xs) {
            Text("Icon")
                .risingLabel()
                .foregroundStyle(Color.risingTextSecondaryDark)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: RisingSpacing.sm) {
                ForEach(viewModel.iconOptions, id: \.self) { icon in
                    iconButton(for: icon)
                }
            }
            .padding(RisingSpacing.md)
            .background(Color.risingSurfaceDark)
            .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))
        }
    }

    private var descriptionSection: some View {
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

    // MARK: - Icon Button

    private func iconButton(for icon: String) -> some View {
        Button {
            HapticsService.shared.selection()
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
        .accessibilityLabel("Select \(icon.replacingOccurrences(of: "circle.fill", with: "").trimmingCharacters(in: .whitespaces)) icon")
        .accessibilityAddTraits(viewModel.selectedIcon == icon ? .isSelected : [])
    }

    // MARK: - Toolbar Buttons

    private var cancelButton: some View {
        Button("Cancel") {
            HapticsService.shared.impactLight()
            dismiss()
        }
        .foregroundStyle(Color.risingTextSecondaryDark)
        .accessibilityLabel("Cancel creating goal")
        .accessibilityHint("Closes this view without saving")
    }

    private var saveButton: some View {
        Button("Save") {
            HapticsService.shared.notificationSuccess()
            Task { await save() }
        }
        .font(.body.weight(.semibold))
        .foregroundStyle(viewModel.isValid ? Color.risingPrimary : Color.risingTextSecondaryDark)
        .disabled(!viewModel.isValid)
        .accessibilityLabel("Save goal")
        .accessibilityValue(viewModel.isValid ? "Ready" : "Fill in required fields")
        .accessibilityHint("Creates a new goal with the entered information")
    }

    // MARK: - Actions

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
