import Foundation

struct CSSBackground: Codable, Hashable, Sendable {
    enum BackgroundType: String, Codable, Sendable {
        case color
        case gradient
        case image
    }

    var type: BackgroundType
    var color: CSSColor?
    var imageURL: String?
    var gradientValue: String?
    var size: String?
    var position: String?
    var repeatValue: String?

    var cssProperties: [(key: String, value: String)] {
        var props: [(String, String)] = []
        switch type {
        case .color:
            if let color {
                props.append(("background-color", color.cssString))
            }
        case .image:
            if let url = imageURL {
                props.append(("background-image", "url('\(url)')"))
            }
        case .gradient:
            if let gradient = gradientValue {
                props.append(("background-image", gradient))
            }
        }
        if let size {
            props.append(("background-size", size))
        }
        if let position {
            props.append(("background-position", position))
        }
        if let repeatValue {
            props.append(("background-repeat", repeatValue))
        }
        return props
    }
}
