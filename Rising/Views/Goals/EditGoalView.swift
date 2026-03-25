import SwiftUI

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var targetAmount: String
    @State private var deadline: Date
    @State private var hasDeadline: Bool
    @State private var description: String
    @State private var selectedIcon: String
    @State private var showError = false
    @State private var errorMessage = ""

    let goal: Goal
    let onSaved: () -> Void

    private let iconOptions = [
        "target", "house", "car", "airplane", "gift",
        "graduationcap", "heart", "star", "bag", "creditcard"
    ]

    init(goal: Goal, onSaved: @escaping () -> Void) {
        self.goal = goal
        self.onSaved = onSaved
        _name = State(initialValue: goal.name)
        _targetAmount = State(initialValue: String(format: "%.0f", goal.targetAmount))
        _deadline = State(initialValue: goal.deadline ?? Calendar.current.date(byAdding: .month, value: 12, to: Date())!)
        _hasDeadline = State(initialValue: goal.deadline != nil)
        _description = State(initialValue: goal.description ?? "")
        _selectedIcon = State(initialValue: goal.iconName)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(targetAmount) ?? 0) > 0
    }

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

                            TextField("Goal Name", text: $name)
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

                                TextField("0", text: $targetAmount)
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
                        Toggle(isOn: $hasDeadline) {
                            Text("Set a target date")
                                .risingBody()
                                .foregroundStyle(Color.risingTextPrimaryDark)
                        }
                        .tint(Color.risingPrimary)
                        .padding(RisingSpacing.md)
                        .background(Color.risingSurfaceDark)
                        .clipShape(RoundedRectangle(cornerRadius: RisingRadius.md))

                        if hasDeadline {
                            DatePicker(
                                "Target Date",
                                selection: $deadline,
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
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon
                                                    ? Color.risingPrimary.opacity(0.2)
                                                    : Color.risingSurfaceDark)
                                                .frame(width: 50, height: 50)

                                            Image(systemName: icon)
                                                .font(.system(size: 20))
                                                .foregroundStyle(
                                                    selectedIcon == icon
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
                            Text("Description")
                                .risingLabel()
                                .foregroundStyle(Color.risingTextSecondaryDark)

                            TextField("Why is this important?", text: $description, axis: .vertical)
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
            .navigationTitle("Edit Goal")
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
                    .foregroundStyle(isValid ? Color.risingPrimary : Color.risingTextSecondaryDark)
                    .disabled(!isValid)
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
        guard let amount = Double(targetAmount), amount > 0 else {
            errorMessage = "Please enter a valid target amount."
            showError = true
            return
        }

        var updatedGoal = goal
        updatedGoal.name = name.trimmingCharacters(in: .whitespaces)
        updatedGoal.targetAmount = amount
        updatedGoal.deadline = hasDeadline ? deadline : nil
        updatedGoal.description = description.isEmpty ? nil : description
        updatedGoal.iconName = selectedIcon

        do {
            try await GoalService.shared.update(updatedGoal)
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    EditGoalView(
        goal: Goal(name: "House Down Payment", targetAmount: 50000),
        onSaved: {}
    )
}
