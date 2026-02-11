import SwiftUI

/// Settings view shown when a page is selected (no node selected).
struct PageSettingsView: View {
    let page: Page

    @State private var title: String = ""
    @State private var metaDescription: String = ""
    @State private var route: String = ""
    @State private var slug: String = ""
    @State private var isLayout: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: page.isLayout ? "rectangle.split.3x1" : "doc.text")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(page.name)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            CollapsibleSection("Page Settings") {
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Title")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("Page Title", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11))
                            .frame(maxWidth: .infinity)
                            .onChange(of: title) {
                                page.title = title.isEmpty ? nil : title
                                page.updatedAt = Date()
                            }
                    }

                    HStack(spacing: 4) {
                        Text("Route")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("/page-route", text: $route)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .onChange(of: route) {
                                page.route = route
                                page.updatedAt = Date()
                            }
                    }

                    HStack(spacing: 4) {
                        Text("Slug")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        TextField("page-slug", text: $slug)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 11, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .onChange(of: slug) {
                                page.slug = slug
                                page.updatedAt = Date()
                            }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)

                        TextEditor(text: $metaDescription)
                            .font(.system(size: 11))
                            .frame(minHeight: 50)
                            .border(Color.primary.opacity(0.1), width: 1)
                            .onChange(of: metaDescription) {
                                page.metaDescription = metaDescription.isEmpty ? nil : metaDescription
                                page.updatedAt = Date()
                            }
                    }

                    HStack(spacing: 4) {
                        Text("Layout")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        Toggle("", isOn: $isLayout)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .onChange(of: isLayout) {
                                page.isLayout = isLayout
                                page.updatedAt = Date()
                            }

                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            title = page.title ?? ""
            metaDescription = page.metaDescription ?? ""
            route = page.route
            slug = page.slug
            isLayout = page.isLayout
        }
    }
}
