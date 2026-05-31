import Foundation
import CoreGraphics

@MainActor
final class CanvasEditorViewModel: ObservableObject {
    @Published var design = AdDesign.starter
    @Published var selectedElementID: UUID? {
        didSet {
            bringSelectedElementToFront()
        }
    }

    var selectedElement: CanvasElement? {
        guard let selectedElementID else { return nil }
        return design.elements.first { $0.id == selectedElementID }
    }

    func addLogoText() {
        append(.logoText("LOGO", position: CGPoint(x: design.canvasSize.width / 2, y: 120)))
    }

    func addLogoImage(data: Data, type: MediaType = .image) {
        append(.media(data: data, type: type, position: CGPoint(x: design.canvasSize.width / 2, y: 140)))
    }

    func addHeadline() {
        append(.headline("Your product, beautifully explained.", position: CGPoint(x: design.canvasSize.width / 2, y: 260)))
    }

    func addBodyText() {
        append(.body("A short supporting line that makes the ad feel polished and easy to understand.", position: CGPoint(x: design.canvasSize.width / 2, y: 410)))
    }

    func addDashboard() {
        append(.mockup(.dashboard, position: CGPoint(x: design.canvasSize.width / 2, y: 700)))
    }

    func addMockup(_ style: MockupStyle) {
        append(.mockup(style, position: CGPoint(x: design.canvasSize.width / 2, y: 700)))
    }

    func addChart() {
        append(.chart(position: CGPoint(x: design.canvasSize.width / 2, y: 760)))
    }

    func addMetricCard() {
        append(.metric("Conversion", value: "+18%", position: CGPoint(x: design.canvasSize.width / 2, y: 980)))
    }

    func addCTA() {
        append(.cta("Book a demo", position: CGPoint(x: design.canvasSize.width / 2, y: 1190)))
    }

    func addShape() {
        append(.shape(position: CGPoint(x: design.canvasSize.width / 2, y: 640)))
    }

    func select(_ elementID: UUID?) {
        selectedElementID = elementID
    }

    func moveElement(id: UUID, by translation: CGSize) {
        let canvasSize = design.canvasSize
        updateElement(id: id) { element in
            let nextX = element.position.x + translation.width
            let nextY = element.position.y + translation.height
            element.position = Self.clampedPosition(for: element, canvasSize: canvasSize, x: nextX, y: nextY)
        }
    }

    func resizeElement(id: UUID, by translation: CGSize) {
        let canvasSize = design.canvasSize
        updateElement(id: id) { element in
            let minimumSize = Self.minimumElementSize(for: element)
            element.size.width = min(max(element.size.width + translation.width, minimumSize.width), canvasSize.width)
            element.size.height = min(max(element.size.height + translation.height, minimumSize.height), canvasSize.height)
            element.position = Self.clampedPosition(for: element, canvasSize: canvasSize, x: element.position.x, y: element.position.y)
        }
    }

    func updateSelectedText(_ text: String) {
        updateSelectedElement { element in
            element.text = text
        }
    }

    func updateSelectedTitle(_ title: String) {
        updateSelectedElement { element in
            element.title = title
        }
    }

    func updateSelectedDetail(_ detail: String) {
        updateSelectedElement { element in
            element.detailText = detail
        }
    }

    func updateSelectedBackground(_ hex: String) {
        updateSelectedElement { element in
            element.backgroundHex = hex
        }
    }

    func updateSelectedForeground(_ hex: String) {
        updateSelectedElement { element in
            element.foregroundHex = hex
        }
    }

    func updateSelectedAccent(_ hex: String) {
        updateSelectedElement { element in
            element.accentHex = hex
        }
    }

    func updateSelectedMockupStyle(_ style: MockupStyle) {
        let canvasSize = design.canvasSize
        updateSelectedElement { element in
            let template = CanvasElement.mockup(style, position: element.position)
            element.mockupStyle = style
            element.title = style.title
            element.text = template.text
            element.detailText = template.detailText
            element.chartValues = template.chartValues
            element.cornerRadius = template.cornerRadius
            element.size = template.size
            element.position = Self.clampedPosition(for: element, canvasSize: canvasSize, x: element.position.x, y: element.position.y)
        }
    }

    func updateSelectedChartValue(at index: Int, value: Double) {
        updateSelectedElement { element in
            guard element.chartValues.indices.contains(index) else { return }
            element.chartValues[index] = min(max(value, 0.05), 0.9)
            Self.normalizeChartValues(&element.chartValues)
        }
    }

    func updateSelectedFontSize(_ size: Double) {
        updateSelectedElement { element in
            element.fontSize = min(max(size, 16), 96)
        }
    }

    func updateSelectedScale(_ scale: Double) {
        let canvasSize = design.canvasSize
        updateSelectedElement { element in
            element.size.width = min(max(element.size.width * scale, 120), canvasSize.width)
            element.size.height = min(max(element.size.height * scale, 64), canvasSize.height)
            element.position = Self.clampedPosition(for: element, canvasSize: canvasSize, x: element.position.x, y: element.position.y)
        }
    }

    func duplicateSelectedElement() {
        guard var selectedElement else { return }
        selectedElement.id = UUID()
        selectedElement.position.x += 36
        selectedElement.position.y += 36
        selectedElement.zIndex = nextZIndex()
        selectedElement.position = Self.clampedPosition(for: selectedElement, canvasSize: design.canvasSize, x: selectedElement.position.x, y: selectedElement.position.y)
        design.elements.append(selectedElement)
        selectedElementID = selectedElement.id
    }

    func deleteSelectedElement() {
        guard let selectedElementID else { return }
        design.elements.removeAll { $0.id == selectedElementID }
        self.selectedElementID = design.elements.max(by: { $0.zIndex < $1.zIndex })?.id
    }

    func resetToStarterTemplate() {
        design = .starter
        selectedElementID = design.elements.last?.id
    }

    private func append(_ element: CanvasElement) {
        var element = element
        element.zIndex = nextZIndex()
        design.elements.append(element)
        selectedElementID = element.id
    }

    private func updateSelectedElement(_ update: (inout CanvasElement) -> Void) {
        guard let selectedElementID else { return }
        updateElement(id: selectedElementID, update)
    }

    private func updateElement(id: UUID, _ update: (inout CanvasElement) -> Void) {
        guard let index = design.elements.firstIndex(where: { $0.id == id }) else { return }
        update(&design.elements[index])
    }

    private func bringSelectedElementToFront() {
        guard let selectedElementID else { return }
        let zIndex = nextZIndex()
        updateElement(id: selectedElementID) { element in
            element.zIndex = zIndex
        }
    }

    private func nextZIndex() -> Int {
        (design.elements.map(\.zIndex).max() ?? 0) + 1
    }

    private static func minimumElementSize(for element: CanvasElement) -> CGSize {
        switch element.kind {
        case .logoText:
            return CGSize(width: 140, height: 56)
        case .media:
            return CGSize(width: 120, height: 90)
        case .headline, .bodyText:
            return CGSize(width: 180, height: 80)
        case .mockup:
            return CGSize(width: 260, height: 220)
        case .chart:
            return CGSize(width: 260, height: 140)
        case .metricCard:
            return CGSize(width: 180, height: 130)
        case .ctaButton:
            return CGSize(width: 160, height: 64)
        case .shape:
            return CGSize(width: 80, height: 80)
        }
    }

    private static func normalizeChartValues(_ values: inout [Double]) {
        let total = values.reduce(0, +)
        guard total > 0 else { return }
        values = values.map { $0 / total }
    }

    private static func clampedPosition(for element: CanvasElement, canvasSize: CGSize, x: CGFloat, y: CGFloat) -> CGPoint {
        let minX = element.size.width / 2
        let maxX = canvasSize.width - element.size.width / 2
        let minY = element.size.height / 2
        let maxY = canvasSize.height - element.size.height / 2

        return CGPoint(
            x: min(max(x, minX), maxX),
            y: min(max(y, minY), maxY)
        )
    }
}
