import Foundation
import SwiftData

enum AssetType: String, Codable, CaseIterable, Sendable {
    case image
    case font
    case svg
    case video
    case audio
    case other

    var displayName: String {
        switch self {
        case .image: return "Image"
        case .font:  return "Font"
        case .svg:   return "SVG"
        case .video: return "Video"
        case .audio: return "Audio"
        case .other: return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .image: return "photo"
        case .font:  return "textformat"
        case .svg:   return "square.on.circle"
        case .video: return "play.rectangle"
        case .audio: return "speaker.wave.2"
        case .other: return "doc"
        }
    }
}

@Model
final class Asset {
    @Attribute(.unique) var id: UUID
    var name: String
    var fileName: String
    var fileType: AssetType
    var fileSize: Int64
    var bookmarkData: Data?
    var addedAt: Date

    var project: Project?

    init(name: String, fileName: String, fileType: AssetType, fileSize: Int64) {
        self.id = UUID()
        self.name = name
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.addedAt = Date()
    }
}
