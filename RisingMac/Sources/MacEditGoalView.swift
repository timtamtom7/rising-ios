import SwiftUI

struct MacEditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var targetAmount: String
    @State private var deadline: Date
    @State private var hasDeadline: Bool
    @State private var iconName: String
    @State private var description: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    let goal: Goal
    let onSaved: () -> Void

    private let iconOptions = ["target", "house.fill", "car.fill", "airplane", "graduationcap.fill", "heart.fill", "bag.fill", "creditcard.fill"]

    init(goal: Goal, onSaved: @escaping () -> Void) {
        self.goal = goal
        self.onSaved = onSaved
        _name = State(initialValue: goal.name)
        _targetAmount = State(initialValue: String(format: "%.0f", goal.targetAmount))
        _deadline = State(initialValue: goal.deadline ?? Date())
        _hasDeadline = State(initialValue: goal.deadline != nil)
        _iconName = State(initialValue: goal.iconName)
        _description = State(initialValue: goal.description ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    nameSection
                    amountSection
                    deadlineSection
                    iconSection
                    descriptionSection
                }
                .padding(24)
            }
            Divider()
            footer
        }
        .frame(width: 500, height: 560)
        .background(Color.risingSurfaceDark)
    }

    private var header: some View {
        HStack {
            Text("Edit Goal")
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
            .accessibilityLabel("Close")
            .accessibilityHint("Close this dialog")
        }
        .padding(20)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Goal Name")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            TextField("e.g. House Down Payment", text: $name)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.risingCardDark)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.risingTextPrimary)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Target Amount")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            HStack {
                Text("$")
                    .foregroundStyle(.risingTextSecondary)
                    .padding(.leading, 12)
                TextField("50000", text: $targetAmount)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.risingTextPrimary)
            }
            .padding(12)
            .background(Color.risingCardDark)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var deadlineSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("Set a deadline", isOn: $hasDeadline)
                .toggleStyle(.switch)
                .foregroundStyle(.risingTextSecondary)
                .tint(.risingPrimary)

            if hasDeadline {
                DatePicker("", selection: $deadline, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.risingPrimary)
                    .padding(8)
                    .background(Color.risingCardDark)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Icon")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        iconName = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(iconName == icon ? .white : .risingTextSecondary)
                            .frame(width: 36, height: 36)
                            .background(iconName == icon ? Color.risingPrimary : Color.risingCardDark)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(icon) icon")
                    .accessibilityHint(iconName == icon ? "Currently selected" : "Select this icon for your goal")
                }
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description (optional)")
                .font(.caption)
                .foregroundStyle(.risingTextSecondary)
            TextField("What are you saving for?", text: $description, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(2...4)
                .padding(12)
                .background(Color.risingCardDark)
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
            .accessibilityLabel("Cancel")
            .accessibilityHint("Discard and close this form")

            Button {
                save()
            } label: {
                if isSaving {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Save Changes")
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.risingPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(isSaving || name.isEmpty || targetAmount.isEmpty)
            .accessibilityLabel(isSaving ? "Saving..." : "Save Changes")
            .accessibilityHint("Apply your goal edits")
        }
        .padding(20)
    }

    private func save() {
        guard let amount = Double(targetAmount), amount > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }

        isSaving = true
        errorMessage = nil

        var updatedGoal = goal
        updatedGoal.name = name
        updatedGoal.targetAmount = amount
        updatedGoal.deadline = hasDeadline ? deadline : nil
        updatedGoal.iconName = iconName
        updatedGoal.description = description.isEmpty ? nil : description

        Task {
            do {
                try await GoalService.shared.update(updatedGoal)
                onSaved()
                dismiss()
            } catch {
                errorMessage = "Failed to save changes."
                isSaving = false
            }
        }
    }
}
