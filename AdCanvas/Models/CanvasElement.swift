import Foundation

struct AdDesign: Codable, Equatable {
    var name: String
    var canvasSize: CGSize
    var backgroundHex: String
    var elements: [CanvasElement]

    static let starter = AdDesign(
        name: "Dashboard Launch Ad",
        canvasSize: CGSize(width: 1080, height: 1350),
        backgroundHex: "#F6F7FB",
        elements: [
            .logoText("NOVA", position: CGPoint(x: 540, y: 110)),
            .headline("Turn product data into decisions.", position: CGPoint(x: 540, y: 250)),
            .mockup(.dashboard, position: CGPoint(x: 540, y: 680)),
            .metric("Revenue", value: "$128K", position: CGPoint(x: 330, y: 1010)),
            .metric("Growth", value: "+32%", position: CGPoint(x: 750, y: 1010)),
            .cta("Start free", position: CGPoint(x: 540, y: 1195))
        ]
    )
}

struct CanvasElement: Identifiable, Codable, Equatable {
    enum Kind: String, Codable, CaseIterable {
        case logoText
        case media
        case headline
        case bodyText
        case mockup
        case chart
        case metricCard
        case ctaButton
        case shape

        var title: String {
            switch self {
            case .logoText:
                return "Logo Text"
            case .media:
                return "Media"
            case .headline:
                return "Headline"
            case .bodyText:
                return "Text"
            case .mockup:
                return "Mockup"
            case .chart:
                return "Chart"
            case .metricCard:
                return "Metric"
            case .ctaButton:
                return "CTA"
            case .shape:
                return "Shape"
            }
        }
    }

    var id: UUID
    var kind: Kind
    var title: String
    var text: String
    var detailText: String
    var imageData: Data?
    var mediaType: MediaType
    var mockupStyle: MockupStyle
    var chartValues: [Double]
    var position: CGPoint
    var size: CGSize
    var backgroundHex: String
    var foregroundHex: String
    var accentHex: String
    var fontSize: Double
    var cornerRadius: Double
    var opacity: Double
    var isBold: Bool
    var zIndex: Int

    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String = "",
        text: String,
        detailText: String = "",
        imageData: Data? = nil,
        mediaType: MediaType = .image,
        mockupStyle: MockupStyle = .dashboard,
        chartValues: [Double] = [0.24, 0.18, 0.31, 0.27],
        position: CGPoint,
        size: CGSize,
        backgroundHex: String,
        foregroundHex: String,
        accentHex: String = "#246BFE",
        fontSize: Double,
        cornerRadius: Double = 28,
        opacity: Double = 1,
        isBold: Bool = false,
        zIndex: Int = 0
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.text = text
        self.detailText = detailText
        self.imageData = imageData
        self.mediaType = mediaType
        self.mockupStyle = mockupStyle
        self.chartValues = chartValues
        self.position = position
        self.size = size
        self.backgroundHex = backgroundHex
        self.foregroundHex = foregroundHex
        self.accentHex = accentHex
        self.fontSize = fontSize
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.isBold = isBold
        self.zIndex = zIndex
    }
}

enum MediaType: String, Codable, CaseIterable {
    case image
    case gif
    case video

    var title: String {
        switch self {
        case .image:
            return "Image"
        case .gif:
            return "GIF"
        case .video:
            return "Video"
        }
    }
}

enum MockupStyle: String, Codable, CaseIterable, Identifiable {
    case dashboard
    case browser
    case laptop
    case tablet
    case mobileApp
    case analytics
    case ecommerce
    case landingPage
    case emailCampaign
    case kanban
    case report
    case socialAd
    case testimonial
    case pricing
    case presentation
    case videoDashboard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .browser:
            return "Browser"
        case .laptop:
            return "Laptop"
        case .tablet:
            return "Tablet"
        case .mobileApp:
            return "Mobile App"
        case .analytics:
            return "Analytics"
        case .ecommerce:
            return "Ecommerce"
        case .landingPage:
            return "Landing Page"
        case .emailCampaign:
            return "Email"
        case .kanban:
            return "Kanban"
        case .report:
            return "Report"
        case .socialAd:
            return "Social Ad"
        case .testimonial:
            return "Testimonial"
        case .pricing:
            return "Pricing"
        case .presentation:
            return "Presentation"
        case .videoDashboard:
            return "Video Dashboard"
        }
    }
}

extension CanvasElement {
    static func logoText(_ text: String, position: CGPoint, zIndex: Int = 10) -> CanvasElement {
        CanvasElement(
            kind: .logoText,
            text: text,
            position: position,
            size: CGSize(width: 300, height: 96),
            backgroundHex: "#111827",
            foregroundHex: "#FFFFFF",
            fontSize: 34,
            cornerRadius: 34,
            isBold: true,
            zIndex: zIndex
        )
    }

    static func media(data: Data, type: MediaType, position: CGPoint, zIndex: Int = 10) -> CanvasElement {
        CanvasElement(
            kind: .media,
            text: type == .video ? "Video" : "Media",
            imageData: data,
            mediaType: type,
            position: position,
            size: CGSize(width: type == .video ? 560 : 260, height: type == .video ? 320 : 160),
            backgroundHex: "#FFFFFF",
            foregroundHex: "#111827",
            fontSize: 18,
            cornerRadius: 30,
            zIndex: zIndex
        )
    }

    static func imageLogo(data: Data, position: CGPoint, zIndex: Int = 10) -> CanvasElement {
        media(data: data, type: .image, position: position, zIndex: zIndex)
    }

    static func headline(_ text: String, position: CGPoint, zIndex: Int = 20) -> CanvasElement {
        CanvasElement(
            kind: .headline,
            text: text,
            position: position,
            size: CGSize(width: 860, height: 180),
            backgroundHex: "#00000000",
            foregroundHex: "#111827",
            fontSize: 58,
            cornerRadius: 0,
            isBold: true,
            zIndex: zIndex
        )
    }

    static func body(_ text: String, position: CGPoint, zIndex: Int = 21) -> CanvasElement {
        CanvasElement(
            kind: .bodyText,
            text: text,
            position: position,
            size: CGSize(width: 760, height: 150),
            backgroundHex: "#00000000",
            foregroundHex: "#4B5563",
            fontSize: 34,
            cornerRadius: 0,
            zIndex: zIndex
        )
    }

    static func mockup(_ style: MockupStyle, position: CGPoint, zIndex: Int = 30) -> CanvasElement {
        CanvasElement(
            kind: .mockup,
            title: style.title,
            text: defaultText(for: style),
            detailText: defaultDetail(for: style),
            mockupStyle: style,
            chartValues: defaultChartValues(for: style),
            position: position,
            size: defaultSize(for: style),
            backgroundHex: "#FFFFFF",
            foregroundHex: "#111827",
            accentHex: style == .ecommerce ? "#10B981" : "#635BFF",
            fontSize: 30,
            cornerRadius: style == .mobileApp ? 54 : 42,
            zIndex: zIndex
        )
    }

    static func chart(position: CGPoint, zIndex: Int = 35) -> CanvasElement {
        CanvasElement(
            kind: .chart,
            title: "Channel mix",
            text: "Ads 42%",
            detailText: "Organic 31%",
            chartValues: [0.42, 0.31, 0.18, 0.09],
            position: position,
            size: CGSize(width: 760, height: 280),
            backgroundHex: "#FFFFFF",
            foregroundHex: "#111827",
            accentHex: "#246BFE",
            fontSize: 34,
            cornerRadius: 38,
            isBold: true,
            zIndex: zIndex
        )
    }

    static func metric(_ label: String, value: String, position: CGPoint, zIndex: Int = 40) -> CanvasElement {
        CanvasElement(
            kind: .metricCard,
            title: label,
            text: value,
            detailText: "vs last month",
            position: position,
            size: CGSize(width: 330, height: 190),
            backgroundHex: "#FFFFFF",
            foregroundHex: "#111827",
            accentHex: "#0EA5E9",
            fontSize: 48,
            cornerRadius: 38,
            isBold: true,
            zIndex: zIndex
        )
    }

    static func cta(_ text: String, position: CGPoint, zIndex: Int = 50) -> CanvasElement {
        CanvasElement(
            kind: .ctaButton,
            text: text,
            position: position,
            size: CGSize(width: 360, height: 104),
            backgroundHex: "#111827",
            foregroundHex: "#FFFFFF",
            accentHex: "#FFFFFF",
            fontSize: 34,
            cornerRadius: 52,
            isBold: true,
            zIndex: zIndex
        )
    }

    static func shape(position: CGPoint, zIndex: Int = 5) -> CanvasElement {
        CanvasElement(
            kind: .shape,
            text: "",
            position: position,
            size: CGSize(width: 360, height: 260),
            backgroundHex: "#DBEAFE",
            foregroundHex: "#1D4ED8",
            accentHex: "#60A5FA",
            fontSize: 24,
            cornerRadius: 46,
            opacity: 0.9,
            zIndex: zIndex
        )
    }

    private static func defaultText(for style: MockupStyle) -> String {
        switch style {
        case .dashboard:
            return "Analytics Overview"
        case .browser:
            return "Campaign Command Center"
        case .laptop:
            return "SaaS product preview"
        case .tablet:
            return "Tablet dashboard"
        case .mobileApp:
            return "Mobile-first workflow"
        case .analytics:
            return "Performance Snapshot"
        case .ecommerce:
            return "Storefront Launch"
        case .landingPage:
            return "Landing page that converts"
        case .emailCampaign:
            return "Launch email sequence"
        case .kanban:
            return "Pipeline at a glance"
        case .report:
            return "Executive report"
        case .socialAd:
            return "High-performing creative"
        case .testimonial:
            return "\"This dashboard made our launch simple.\""
        case .pricing:
            return "Pro Plan"
        case .presentation:
            return "Investor-ready slide"
        case .videoDashboard:
            return "Live product walkthrough"
        }
    }

    private static func defaultDetail(for style: MockupStyle) -> String {
        switch style {
        case .dashboard:
            return "MRR, signups, retention"
        case .browser:
            return "Funnels, audiences, insights"
        case .laptop:
            return "Charts, cards, and product proof"
        case .tablet:
            return "Touch-friendly KPI view"
        case .mobileApp:
            return "Tasks, stats, alerts"
        case .analytics:
            return "ROAS, CAC, conversion"
        case .ecommerce:
            return "Products, cart, checkout"
        case .landingPage:
            return "Hero, social proof, CTA"
        case .emailCampaign:
            return "Subject, offer, CTA"
        case .kanban:
            return "Leads, demos, closed"
        case .report:
            return "Highlights, risks, next steps"
        case .socialAd:
            return "Hook, proof, CTA"
        case .testimonial:
            return "Maya Chen, Growth Lead"
        case .pricing:
            return "$29/mo - scale cleanly"
        case .presentation:
            return "Problem, solution, traction"
        case .videoDashboard:
            return "Drop video, GIF, or image media into clean frames"
        }
    }

    private static func defaultChartValues(for style: MockupStyle) -> [Double] {
        switch style {
        case .analytics, .report, .presentation:
            return [0.18, 0.24, 0.13, 0.29, 0.16]
        case .ecommerce, .landingPage, .emailCampaign:
            return [0.38, 0.22, 0.21, 0.19]
        case .pricing, .kanban:
            return [0.5, 0.3, 0.2]
        default:
            return [0.42, 0.31, 0.18, 0.09]
        }
    }

    private static func defaultSize(for style: MockupStyle) -> CGSize {
        switch style {
        case .mobileApp:
            return CGSize(width: 410, height: 720)
        case .tablet:
            return CGSize(width: 640, height: 820)
        case .socialAd:
            return CGSize(width: 540, height: 540)
        case .testimonial, .pricing:
            return CGSize(width: 620, height: 360)
        case .presentation:
            return CGSize(width: 820, height: 460)
        case .videoDashboard:
            return CGSize(width: 840, height: 520)
        default:
            return CGSize(width: 880, height: 520)
        }
    }
}
