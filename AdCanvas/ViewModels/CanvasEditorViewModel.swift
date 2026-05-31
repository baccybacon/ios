import Foundation
import CoreGraphics

@MainActor
final class CanvasEditorViewModel: ObservableObject {
    @Published var design = AdDesign.starter
    @Published var selectedElementID: UUID?

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

    func updateCanvasSize(width: Double, height: Double) {
        let width = min(max(width, 240), 4_000)
        let height = min(max(height, 240), 4_000)
        design.canvasSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        clampElementsToCanvas()
    }

    func updateGridVisibility(_ isVisible: Bool) {
        design.guideSettings.showsGrid = isVisible
    }

    func updateSnapToGrid(_ isEnabled: Bool) {
        design.guideSettings.snapsToGrid = isEnabled
    }

    func updateGridSpacing(_ spacing: Double) {
        design.guideSettings.gridSpacing = min(max(spacing, 20), 300)
    }

    func moveElement(id: UUID, by translation: CGSize) {
        let canvasSize = design.canvasSize
        let guideSettings = design.guideSettings
        updateElement(id: id) { element in
            let nextX = element.position.x + translation.width
            let nextY = element.position.y + translation.height
            let clampedPosition = Self.clampedPosition(for: element, canvasSize: canvasSize, x: nextX, y: nextY)
            let snappedPosition = Self.snappedPosition(for: element, canvasSize: canvasSize, guideSettings: guideSettings, proposedPosition: clampedPosition)
            element.position = Self.clampedPosition(for: element, canvasSize: canvasSize, x: snappedPosition.x, y: snappedPosition.y)
        }
    }

    func resizeElement(id: UUID, by translation: CGSize) {
        let canvasSize = design.canvasSize
        let guideSettings = design.guideSettings
        updateElement(id: id) { element in
            let minimumSize = Self.minimumElementSize(for: element)
            element.size.width = min(max(element.size.width + translation.width, minimumSize.width), canvasSize.width)
            element.size.height = min(max(element.size.height + translation.height, minimumSize.height), canvasSize.height)
            element.size = Self.snappedSize(for: element, canvasSize: canvasSize, guideSettings: guideSettings, minimumSize: minimumSize)
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

    func moveSelectedElementForward() {
        moveSelectedElementLayer(by: 1)
    }

    func moveSelectedElementBackward() {
        moveSelectedElementLayer(by: -1)
    }

    func bringSelectedElementToFront() {
        guard let selectedElementID,
              let index = design.elements.firstIndex(where: { $0.id == selectedElementID }) else {
            return
        }

        design.elements[index].zIndex = nextZIndex()
        normalizeLayerOrder()
    }

    func sendSelectedElementToBack() {
        guard let selectedElementID,
              let index = design.elements.firstIndex(where: { $0.id == selectedElementID }) else {
            return
        }

        design.elements[index].zIndex = (design.elements.map(\.zIndex).min() ?? 0) - 1
        normalizeLayerOrder()
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

    func applyPresetCanvas(_ preset: CanvasSizePreset) {
        updateCanvasSize(width: Double(preset.size.width), height: Double(preset.size.height))
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

    private func nextZIndex() -> Int {
        (design.elements.map(\.zIndex).max() ?? 0) + 1
    }

    private func moveSelectedElementLayer(by offset: Int) {
        guard let selectedElementID else { return }

        let orderedIDs = design.elements
            .sorted { lhs, rhs in
                if lhs.zIndex == rhs.zIndex {
                    return lhs.id.uuidString < rhs.id.uuidString
                }
                return lhs.zIndex < rhs.zIndex
            }
            .map(\.id)

        guard let currentPosition = orderedIDs.firstIndex(of: selectedElementID) else { return }
        let targetPosition = min(max(currentPosition + offset, 0), orderedIDs.count - 1)
        guard targetPosition != currentPosition else { return }

        let targetID = orderedIDs[targetPosition]
        guard let selectedIndex = design.elements.firstIndex(where: { $0.id == selectedElementID }),
              let targetIndex = design.elements.firstIndex(where: { $0.id == targetID }) else {
            return
        }

        let selectedZIndex = design.elements[selectedIndex].zIndex
        design.elements[selectedIndex].zIndex = design.elements[targetIndex].zIndex
        design.elements[targetIndex].zIndex = selectedZIndex
        normalizeLayerOrder()
    }

    private func normalizeLayerOrder() {
        let orderedIDs = design.elements
            .sorted { lhs, rhs in
                if lhs.zIndex == rhs.zIndex {
                    return lhs.id.uuidString < rhs.id.uuidString
                }
                return lhs.zIndex < rhs.zIndex
            }
            .map(\.id)

        for (zIndex, id) in orderedIDs.enumerated() {
            guard let index = design.elements.firstIndex(where: { $0.id == id }) else { continue }
            design.elements[index].zIndex = zIndex
        }
    }

    private func clampElementsToCanvas() {
        let canvasSize = design.canvasSize

        for index in design.elements.indices {
            let minimumSize = Self.minimumElementSize(for: design.elements[index])
            design.elements[index].size.width = min(max(design.elements[index].size.width, minimumSize.width), canvasSize.width)
            design.elements[index].size.height = min(max(design.elements[index].size.height, minimumSize.height), canvasSize.height)
            let position = design.elements[index].position
            design.elements[index].position = Self.clampedPosition(for: design.elements[index], canvasSize: canvasSize, x: position.x, y: position.y)
        }
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
            x: min(max(x, minX), max(minX, maxX)),
            y: min(max(y, minY), max(minY, maxY))
        )
    }

    private static func snappedPosition(
        for element: CanvasElement,
        canvasSize: CGSize,
        guideSettings: CanvasGuideSettings,
        proposedPosition: CGPoint
    ) -> CGPoint {
        guard guideSettings.snapsToGrid else { return proposedPosition }

        let spacing = max(CGFloat(guideSettings.gridSpacing), 1)
        let threshold = max(CGFloat(guideSettings.snapThreshold), 0)

        let horizontalAnchors = [
            proposedPosition.x,
            proposedPosition.x - element.size.width / 2,
            proposedPosition.x + element.size.width / 2
        ]
        let verticalAnchors = [
            proposedPosition.y,
            proposedPosition.y - element.size.height / 2,
            proposedPosition.y + element.size.height / 2
        ]

        let snappedX = snappedCenter(
            center: proposedPosition.x,
            anchors: horizontalAnchors,
            spacing: spacing,
            limit: canvasSize.width,
            threshold: threshold
        )
        let snappedY = snappedCenter(
            center: proposedPosition.y,
            anchors: verticalAnchors,
            spacing: spacing,
            limit: canvasSize.height,
            threshold: threshold
        )

        return CGPoint(x: snappedX, y: snappedY)
    }

    private static func snappedSize(
        for element: CanvasElement,
        canvasSize: CGSize,
        guideSettings: CanvasGuideSettings,
        minimumSize: CGSize
    ) -> CGSize {
        guard guideSettings.snapsToGrid else { return element.size }

        let spacing = max(CGFloat(guideSettings.gridSpacing), 1)
        let threshold = max(CGFloat(guideSettings.snapThreshold), 0)
        var size = element.size

        let rightEdge = element.position.x + element.size.width / 2
        if let snappedRightEdge = snappedGuide(for: rightEdge, spacing: spacing, limit: canvasSize.width, threshold: threshold) {
            size.width = min(max((snappedRightEdge - element.position.x) * 2, minimumSize.width), canvasSize.width)
        }

        let bottomEdge = element.position.y + element.size.height / 2
        if let snappedBottomEdge = snappedGuide(for: bottomEdge, spacing: spacing, limit: canvasSize.height, threshold: threshold) {
            size.height = min(max((snappedBottomEdge - element.position.y) * 2, minimumSize.height), canvasSize.height)
        }

        return size
    }

    private static func snappedCenter(center: CGFloat, anchors: [CGFloat], spacing: CGFloat, limit: CGFloat, threshold: CGFloat) -> CGFloat {
        var bestAdjustment: CGFloat?

        for anchor in anchors {
            guard let guide = snappedGuide(for: anchor, spacing: spacing, limit: limit, threshold: threshold) else { continue }
            let adjustment = guide - anchor

            if bestAdjustment == nil || abs(adjustment) < abs(bestAdjustment ?? 0) {
                bestAdjustment = adjustment
            }
        }

        return center + (bestAdjustment ?? 0)
    }

    private static func snappedGuide(for value: CGFloat, spacing: CGFloat, limit: CGFloat, threshold: CGFloat) -> CGFloat? {
        let nearestGuide = (value / spacing).rounded() * spacing
        let clampedGuide = min(max(nearestGuide, 0), limit)
        return abs(clampedGuide - value) <= threshold ? clampedGuide : nil
    }
}

struct CanvasSizePreset: Identifiable {
    let id: String
    let name: String
    let size: CGSize

    static let all: [CanvasSizePreset] = [
        CanvasSizePreset(id: "custom-square", name: "Square", size: CGSize(width: 1080, height: 1080)),
        CanvasSizePreset(id: "portrait-ad", name: "Portrait Ad", size: CGSize(width: 1080, height: 1350)),
        CanvasSizePreset(id: "story", name: "Story", size: CGSize(width: 1080, height: 1920)),
        CanvasSizePreset(id: "landscape", name: "Landscape", size: CGSize(width: 1200, height: 628)),
        CanvasSizePreset(id: "banner", name: "Banner", size: CGSize(width: 1600, height: 900))
    ]
}
