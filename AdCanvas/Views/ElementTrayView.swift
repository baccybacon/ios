import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ElementTrayView: View {
    @ObservedObject var viewModel: CanvasEditorViewModel
    @State private var selectedMediaItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Elements")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Spacer()
                Text("Tap to add, then drag")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#6B7280"))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TrayButton(title: "Logo", systemImage: "signature") {
                        viewModel.addLogoText()
                    }

                    PhotosPicker(selection: $selectedMediaItem, matching: .any(of: [.images, .videos])) {
                        TrayButtonLabel(title: "Media", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(.plain)

                    TrayButton(title: "Headline", systemImage: "textformat") {
                        viewModel.addHeadline()
                    }

                    TrayButton(title: "Text", systemImage: "text.alignleft") {
                        viewModel.addBodyText()
                    }

                    Menu {
                        ForEach(MockupStyle.allCases) { style in
                            Button(style.title) {
                                viewModel.addMockup(style)
                            }
                        }
                    } label: {
                        TrayButtonLabel(title: "Mockups", systemImage: "rectangle.3.group")
                    }

                    TrayButton(title: "Chart", systemImage: "chart.bar.xaxis") {
                        viewModel.addChart()
                    }

                    TrayButton(title: "Metric", systemImage: "chart.line.uptrend.xyaxis") {
                        viewModel.addMetricCard()
                    }

                    TrayButton(title: "CTA", systemImage: "cursorarrow.click") {
                        viewModel.addCTA()
                    }

                    TrayButton(title: "Shape", systemImage: "square.on.circle") {
                        viewModel.addShape()
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
        .onChange(of: selectedMediaItem) { item in
            Task {
                guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
                let mediaType = mediaType(for: item.supportedContentTypes)
                await MainActor.run {
                    viewModel.addLogoImage(data: data, type: mediaType)
                    selectedMediaItem = nil
                }
            }
        }
    }

    private func mediaType(for contentTypes: [UTType]) -> MediaType {
        if contentTypes.contains(where: { $0.conforms(to: .movie) || $0.conforms(to: .video) }) {
            return .video
        }

        if contentTypes.contains(where: { $0 == .gif || $0.conforms(to: .gif) }) {
            return .gif
        }

        return .image
    }
}

private struct TrayButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TrayButtonLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}

private struct TrayButtonLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(Color(hex: "#F3F4F6"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(Color(hex: "#111827"))
        .frame(width: 86, height: 88)
        .background(Color(hex: "#FAFAFA"))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        }
    }
}
