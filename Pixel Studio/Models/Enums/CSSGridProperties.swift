import Foundation

enum CSSGridAutoFlow: String, Codable, CaseIterable, Sendable {
    case row
    case column
    case dense
    case rowDense = "row dense"
    case columnDense = "column dense"
}
