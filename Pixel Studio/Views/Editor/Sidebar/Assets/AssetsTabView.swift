import SwiftUI

struct AssetsTabView: View {
    let project: Project

    private var sortedAssets: [Asset] {
        project.assets.sorted { $0.addedAt > $1.addedAt }
    }

    var body: some View {
        ScrollView {
            if sortedAssets.isEmpty {
                VStack(spacing: 8) {
                    Spacer().frame(height: 40)
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    Text("No assets yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(sortedAssets) { asset in
                        AssetRowView(asset: asset)
                    }
                }
            }
        }
    }
}
