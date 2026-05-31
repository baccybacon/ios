import AVKit
import SwiftUI
import UIKit
import WebKit

struct CanvasElementView: View {
    let element: CanvasElement

    var body: some View {
        Group {
            switch element.kind {
            case .logoText:
                logoText
            case .media:
                MediaFrameView(element: element)
            case .headline, .bodyText:
                copyText
            case .mockup:
                MockupElementView(element: element)
            case .chart:
                ChartElementView(element: element)
            case .metricCard:
                MetricCardView(element: element)
            case .ctaButton:
                ctaButton
            case .shape:
                shape
            }
        }
        .opacity(element.opacity)
    }

    private var logoText: some View {
        Text(element.text)
            .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
            .tracking(3)
            .foregroundStyle(Color(hex: element.foregroundHex))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: element.backgroundHex))
            .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
    }

    private var copyText: some View {
        Text(element.text)
            .font(.system(size: element.fontSize, weight: element.isBold ? .bold : .regular, design: .rounded))
            .foregroundStyle(Color(hex: element.foregroundHex))
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .minimumScaleFactor(0.45)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var ctaButton: some View {
        Text(element.text)
            .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: element.foregroundHex))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: element.backgroundHex))
            .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
            .shadow(color: Color(hex: element.backgroundHex).opacity(0.24), radius: 18, y: 10)
    }

    private var shape: some View {
        RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: element.backgroundHex),
                        Color(hex: element.accentHex).opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

private struct MockupElementView: View {
    let element: CanvasElement

    var body: some View {
        switch element.mockupStyle {
        case .mobileApp:
            mobileApp
        case .socialAd:
            socialAd
        case .testimonial:
            testimonial
        case .pricing:
            pricing
        default:
            dashboardLike
        }
    }

    private var dashboardLike: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle().fill(Color(hex: "#EF4444")).frame(width: 22, height: 22)
                Circle().fill(Color(hex: "#F59E0B")).frame(width: 22, height: 22)
                Circle().fill(Color(hex: "#10B981")).frame(width: 22, height: 22)

                Spacer()

                Text(element.title.isEmpty ? "Dashboard" : element.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: element.foregroundHex))
            }
            .padding(.horizontal, 34)
            .frame(height: 86)
            .background(Color(hex: "#F9FAFB"))

            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(element.text)
                            .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
                        Text(element.detailText)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#6B7280"))
                    }

                    Spacer()

                    Text("LIVE")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: element.accentHex))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: element.accentHex).opacity(0.12))
                        .clipShape(Capsule())
                }

                HStack(alignment: .bottom, spacing: 18) {
                    ForEach(Array(element.chartValues.enumerated()), id: \.offset) { _, height in
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(hex: element.accentHex).opacity(0.85))
                            .frame(height: 210 * height)
                    }
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 18) {
                    miniCard(title: "MRR", value: "$42K")
                    miniCard(title: "Users", value: "9.8K")
                    miniCard(title: "Churn", value: "1.4%")
                }
            }
            .padding(34)
        }
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 28, y: 18)
    }

    private var mobileApp: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color(hex: "#111827"))
                .frame(width: 120, height: 10)
                .padding(.top, 22)

            VStack(alignment: .leading, spacing: 14) {
                Text(element.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B7280"))
                Text(element.text)
                    .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: element.foregroundHex))
                    .minimumScaleFactor(0.45)
                Text(element.detailText)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B7280"))

                VStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { index in
                        HStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: element.accentHex).opacity(0.16 + Double(index) * 0.08))
                                .frame(width: 58, height: 58)
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#E5E7EB")).frame(height: 12)
                                RoundedRectangle(cornerRadius: 8).fill(Color(hex: "#F3F4F6")).frame(width: 150, height: 12)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(hex: "#F9FAFB"))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
            }
            .padding(28)
        }
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.14), radius: 26, y: 16)
    }

    private var socialAd: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Circle().fill(Color(hex: element.accentHex)).frame(width: 54, height: 54)
                VStack(alignment: .leading, spacing: 6) {
                    Text(element.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Sponsored")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B7280"))
                }
                Spacer()
            }

            Text(element.text)
                .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: element.foregroundHex))
                .minimumScaleFactor(0.45)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: element.accentHex), Color(hex: "#DBEAFE")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    Text(element.detailText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding()
                }
        }
        .padding(30)
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 24, y: 14)
    }

    private var testimonial: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "quote.opening")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(Color(hex: element.accentHex))
            Text(element.text)
                .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: element.foregroundHex))
                .minimumScaleFactor(0.45)
            Text(element.detailText)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B7280"))
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 24, y: 14)
    }

    private var pricing: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(element.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B7280"))
            Text(element.text)
                .font(.system(size: element.fontSize + 8, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: element.foregroundHex))
                .minimumScaleFactor(0.45)
            Text(element.detailText)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#6B7280"))
            HStack(spacing: 10) {
                ForEach(["Seats", "Reports", "AI"], id: \.self) { item in
                    Text(item)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(hex: element.accentHex).opacity(0.14))
                        .foregroundStyle(Color(hex: element.accentHex))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 24, y: 14)
    }

    private func miniCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#6B7280"))
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: element.foregroundHex))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(hex: "#F3F4F6"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ChartElementView: View {
    let element: CanvasElement

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(element.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("\(element.text) / \(element.detailText)")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#6B7280"))
                }
                Spacer()
            }

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ForEach(Array(element.chartValues.enumerated()), id: \.offset) { index, value in
                        RoundedRectangle(cornerRadius: index == 0 || index == element.chartValues.count - 1 ? 20 : 4, style: .continuous)
                            .fill(chartColor(for: index))
                            .frame(width: max(geometry.size.width * value, 8))
                    }
                }
            }
            .frame(height: 78)

            HStack {
                ForEach(Array(element.chartValues.enumerated()), id: \.offset) { index, value in
                    Text("\(Int(value * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(chartColor(for: index))
                }
            }
        }
        .padding(28)
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 22, y: 12)
    }

    private func chartColor(for index: Int) -> Color {
        let colors = [element.accentHex, "#111827", "#0EA5E9", "#10B981", "#F97316"]
        return Color(hex: colors[index % colors.count])
    }
}

private struct MediaFrameView: View {
    let element: CanvasElement

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous)
                .fill(Color(hex: element.backgroundHex))

            if let data = element.imageData {
                switch element.mediaType {
                case .image:
                    imageView(data: data)
                case .gif:
                    GIFView(data: data)
                        .clipShape(RoundedRectangle(cornerRadius: max(element.cornerRadius - 10, 8), style: .continuous))
                        .padding(12)
                case .video:
                    VideoAssetView(data: data)
                        .clipShape(RoundedRectangle(cornerRadius: max(element.cornerRadius - 10, 8), style: .continuous))
                        .padding(12)
                }
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
    }

    private func imageView(data: Data) -> some View {
        Group {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(14)
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        VStack(spacing: 10) {
            Image(systemName: element.mediaType == .video ? "play.rectangle" : "photo")
                .font(.system(size: 42, weight: .semibold))
            Text(element.mediaType.title)
                .font(.system(size: element.fontSize, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(Color(hex: element.foregroundHex))
    }
}

private struct GIFView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: NSTemporaryDirectory()))
    }
}

private struct VideoAssetView: View {
    let data: Data
    @State private var videoURL: URL?

    var body: some View {
        Group {
            if let videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
            } else {
                ProgressView()
            }
        }
        .onAppear {
            guard videoURL == nil else { return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
            try? data.write(to: url)
            videoURL = url
        }
    }
}

private struct MetricCardView: View {
    let element: CanvasElement

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(element.title.isEmpty ? "Metric" : element.title)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#6B7280"))
                Spacer()
                Circle()
                    .fill(Color(hex: element.accentHex).opacity(0.16))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(hex: element.accentHex))
                    }
            }

            Text(element.text)
                .font(.system(size: element.fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: element.foregroundHex))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(element.detailText)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "#9CA3AF"))
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(hex: element.backgroundHex))
        .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 22, y: 12)
    }
}
