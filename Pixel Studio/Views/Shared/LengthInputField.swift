import SwiftUI

/// Input field for CSS length values with a numeric field and unit picker.
struct LengthInputField: View {
    let label: String
    @Binding var value: String
    var units: [CSSUnit] = [.px, .rem, .em, .percent, .vw, .vh, .auto]

    @State private var numericText: String = ""
    @State private var selectedUnit: CSSUnit = .px

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            if selectedUnit == .auto {
                Text("auto")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                TextField("0", text: $numericText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 11))
                    .frame(maxWidth: .infinity)
                    .onChange(of: numericText) {
                        updateValue()
                    }
            }

            Picker("", selection: $selectedUnit) {
                ForEach(units, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 55)
            .onChange(of: selectedUnit) {
                updateValue()
            }
        }
        .onAppear { parseValue() }
        .onChange(of: value) { parseValue() }
    }

    private func parseValue() {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            numericText = ""
            selectedUnit = .px
            return
        }
        if trimmed == "auto" {
            numericText = ""
            selectedUnit = .auto
            return
        }

        // Try to find matching unit suffix
        for unit in units where unit != .auto && unit != .none {
            if trimmed.hasSuffix(unit.rawValue) {
                let numPart = String(trimmed.dropLast(unit.rawValue.count))
                numericText = numPart
                selectedUnit = unit
                return
            }
        }

        // Fallback: treat as px if it's just a number
        numericText = trimmed
        selectedUnit = .px
    }

    private func updateValue() {
        if selectedUnit == .auto {
            value = "auto"
        } else if numericText.isEmpty {
            value = ""
        } else {
            value = "\(numericText)\(selectedUnit.rawValue)"
        }
    }
}
