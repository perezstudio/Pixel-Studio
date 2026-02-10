import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct AssetImportSheet: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Import Assets")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Select files to import into your project.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)

                Button("Choose Files...") { importFiles() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }

    private func importFiles() {
        let panel = NSOpenPanel()
        panel.title = "Import Assets"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.image, .font, .svg, .movie, .audio]

        if panel.runModal() == .OK {
            for url in panel.urls {
                let fileType: AssetType
                let ext = url.pathExtension.lowercased()
                switch ext {
                case "png", "jpg", "jpeg", "gif", "webp", "ico":
                    fileType = .image
                case "svg":
                    fileType = .svg
                case "ttf", "otf", "woff", "woff2":
                    fileType = .font
                case "mp4", "webm", "mov":
                    fileType = .video
                case "mp3", "wav", "ogg":
                    fileType = .audio
                default:
                    fileType = .other
                }

                let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
                let bookmark = try? url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )

                let asset = Asset(
                    name: url.deletingPathExtension().lastPathComponent,
                    fileName: url.lastPathComponent,
                    fileType: fileType,
                    fileSize: fileSize
                )
                asset.bookmarkData = bookmark
                project.assets.append(asset)
            }
            dismiss()
        }
    }
}
