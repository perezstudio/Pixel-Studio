import Foundation

extension Node {
    /// Gets the current value for a CSS property at the given breakpoint.
    func styleValue(for key: CSSPropertyKey, breakpointID: UUID? = nil) -> String? {
        styles.first { $0.key == key && $0.breakpointID == breakpointID }?.value
    }

    /// Gets the current value for a custom CSS property at the given breakpoint.
    func customStyleValue(for customKey: String, breakpointID: UUID? = nil) -> String? {
        styles.first { $0.key == .custom && $0.customKey == customKey && $0.breakpointID == breakpointID }?.value
    }

    /// Sets or updates the value for a CSS property at the given breakpoint.
    /// If value is nil or empty, removes the property.
    func setStyle(key: CSSPropertyKey, value: String?, breakpointID: UUID? = nil) {
        if let existing = styles.first(where: { $0.key == key && $0.breakpointID == breakpointID }) {
            if let value, !value.isEmpty {
                existing.value = value
            } else {
                styles.removeAll { $0.id == existing.id }
            }
        } else if let value, !value.isEmpty {
            let prop = StyleProperty(key: key, value: value, breakpointID: breakpointID)
            prop.sortOrder = styles.count
            prop.node = self
            styles.append(prop)
        }
    }

    /// Sets or updates a custom CSS property.
    func setCustomStyle(customKey: String, value: String?, breakpointID: UUID? = nil) {
        if let existing = styles.first(where: { $0.key == .custom && $0.customKey == customKey && $0.breakpointID == breakpointID }) {
            if let value, !value.isEmpty {
                existing.value = value
            } else {
                styles.removeAll { $0.id == existing.id }
            }
        } else if let value, !value.isEmpty {
            let prop = StyleProperty(key: .custom, value: value, breakpointID: breakpointID)
            prop.customKey = customKey
            prop.sortOrder = styles.count
            prop.node = self
            styles.append(prop)
        }
    }

    /// Returns all custom properties for the given breakpoint.
    func customStyles(breakpointID: UUID? = nil) -> [(key: String, value: String)] {
        styles
            .filter { $0.key == .custom && $0.breakpointID == breakpointID }
            .compactMap { prop in
                guard let customKey = prop.customKey else { return nil }
                return (key: customKey, value: prop.value)
            }
            .sorted { $0.key < $1.key }
    }

    /// Removes all custom properties for the given breakpoint.
    func removeCustomStyle(customKey: String, breakpointID: UUID? = nil) {
        styles.removeAll { $0.key == .custom && $0.customKey == customKey && $0.breakpointID == breakpointID }
    }
}
