import SwiftUI

/// Color picker with hex input field.
struct ColorPickerField: View {
    let label: String
    @Binding var value: String

    @State private var selectedColor: Color = .clear
    @State private var hexText: String = ""

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            ColorPicker("", selection: $selectedColor, supportsOpacity: true)
                .labelsHidden()
                .frame(width: 24, height: 24)
                .onChange(of: selectedColor) {
                    let hex = colorToHex(selectedColor)
                    hexText = hex
                    value = hex
                }

            TextField("#000000", text: $hexText)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11, design: .monospaced))
                .frame(maxWidth: .infinity)
                .onSubmit {
                    value = hexText
                    selectedColor = hexToColor(hexText)
                }
        }
        .onAppear { parseValue() }
        .onChange(of: value) { parseValue() }
    }

    private func parseValue() {
        hexText = value
        if !value.isEmpty {
            selectedColor = hexToColor(value)
        }
    }

    private func hexToColor(_ hex: String) -> Color {
        var hexStr = hex.trimmingCharacters(in: .whitespaces)
        if hexStr.hasPrefix("#") { hexStr.removeFirst() }

        guard hexStr.count >= 6 else { return .clear }

        let scanner = Scanner(string: hexStr)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return .clear }

        let r = Double((hexNumber & 0xFF0000) >> 16) / 255.0
        let g = Double((hexNumber & 0x00FF00) >> 8) / 255.0
        let b = Double(hexNumber & 0x0000FF) / 255.0

        if hexStr.count == 8 {
            let a = Double((hexNumber & 0xFF000000) >> 24) / 255.0
            return Color(red: r, green: g, blue: b, opacity: a)
        }

        return Color(red: r, green: g, blue: b)
    }

    private func colorToHex(_ color: Color) -> String {
        guard let components = NSColor(color).usingColorSpace(.sRGB) else { return "#000000" }
        let r = Int(components.redComponent * 255)
        let g = Int(components.greenComponent * 255)
        let b = Int(components.blueComponent * 255)
        let a = components.alphaComponent

        if a < 1.0 {
            let ai = Int(a * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, ai)
        }
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
