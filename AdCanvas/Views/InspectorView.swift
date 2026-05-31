import SwiftUI

struct InspectorView: View {
    @ObservedObject var viewModel: CanvasEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let element = viewModel.selectedElement {
                selectedControls(for: element)
            } else {
                emptyState
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
    }

    private func selectedControls(for element: CanvasElement) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(element.kind.title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text("Tap colors or use controls to refine it")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#6B7280"))
                }

                Spacer()

                Button(role: .destructive) {
                    viewModel.deleteSelectedElement()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.borderless)
            }

            editableFields(for: element)

            if element.kind == .mockup {
                Picker("Mockup type", selection: Binding(
                    get: { viewModel.selectedElement?.mockupStyle ?? element.mockupStyle },
                    set: viewModel.updateSelectedMockupStyle
                )) {
                    ForEach(MockupStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.menu)
            }

            if element.kind == .chart || element.kind == .mockup {
                chartControls(for: element)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ActionChip(title: "Back", systemImage: "arrow.down") {
                        viewModel.moveSelectedElementBackward()
                    }
                    ActionChip(title: "Forward", systemImage: "arrow.up") {
                        viewModel.moveSelectedElementForward()
                    }
                    ActionChip(title: "To back", systemImage: "arrow.down.to.line") {
                        viewModel.sendSelectedElementToBack()
                    }
                    ActionChip(title: "To front", systemImage: "arrow.up.to.line") {
                        viewModel.bringSelectedElementToFront()
                    }
                    ActionChip(title: "Smaller", systemImage: "minus.magnifyingglass") {
                        viewModel.updateSelectedScale(0.9)
                    }
                    ActionChip(title: "Larger", systemImage: "plus.magnifyingglass") {
                        viewModel.updateSelectedScale(1.1)
                    }
                    ActionChip(title: "Text -", systemImage: "textformat.size.smaller") {
                        viewModel.updateSelectedFontSize(element.fontSize - 4)
                    }
                    ActionChip(title: "Text +", systemImage: "textformat.size.larger") {
                        viewModel.updateSelectedFontSize(element.fontSize + 4)
                    }
                    ActionChip(title: "Duplicate", systemImage: "square.on.square") {
                        viewModel.duplicateSelectedElement()
                    }
                }
            }

            HStack(alignment: .top, spacing: 16) {
                ColorSwatchGroup(
                    title: "Fill",
                    selectedHex: element.backgroundHex,
                    colors: BrandPalette.backgrounds + BrandPalette.accents,
                    onSelect: viewModel.updateSelectedBackground
                )

                ColorSwatchGroup(
                    title: "Text",
                    selectedHex: element.foregroundHex,
                    colors: BrandPalette.accents,
                    onSelect: viewModel.updateSelectedForeground
                )

                ColorSwatchGroup(
                    title: "Accent",
                    selectedHex: element.accentHex,
                    colors: BrandPalette.accents,
                    onSelect: viewModel.updateSelectedAccent
                )
            }
        }
    }

    @ViewBuilder
    private func editableFields(for element: CanvasElement) -> some View {
        switch element.kind {
        case .mockup:
            compactTextField("Title", text: element.title, update: viewModel.updateSelectedTitle)
            compactTextField("Headline", text: element.text, update: viewModel.updateSelectedText)
            compactTextField("Detail", text: element.detailText, update: viewModel.updateSelectedDetail)
        case .chart:
            compactTextField("Title", text: element.title, update: viewModel.updateSelectedTitle)
            HStack(spacing: 10) {
                compactTextField("Stat A", text: element.text, update: viewModel.updateSelectedText)
                compactTextField("Stat B", text: element.detailText, update: viewModel.updateSelectedDetail)
            }
        case .metricCard:
            HStack(spacing: 10) {
                compactTextField("Label", text: element.title, update: viewModel.updateSelectedTitle)
                compactTextField("Value", text: element.text, update: viewModel.updateSelectedText)
            }
            compactTextField("Detail", text: element.detailText, update: viewModel.updateSelectedDetail)
        case .shape, .media:
            EmptyView()
        default:
            compactTextField("Text", text: element.text, update: viewModel.updateSelectedText)
        }
    }

    private func chartControls(for element: CanvasElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chart mix")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(hex: "#6B7280"))

            ForEach(Array(element.chartValues.enumerated()), id: \.offset) { index, value in
                HStack(spacing: 10) {
                    Text("Bar \(index + 1)")
                        .font(.caption)
                        .frame(width: 44, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { viewModel.selectedElement?.chartValues[safe: index] ?? value },
                            set: { viewModel.updateSelectedChartValue(at: index, value: $0) }
                        ),
                        in: 0.05...0.9
                    )
                    Text("\(Int(value * 100))%")
                        .font(.caption.monospacedDigit())
                        .frame(width: 42, alignment: .trailing)
                }
            }
        }
    }

    private func compactTextField(_ title: String, text: String, update: @escaping (String) -> Void) -> some View {
        TextField(title, text: Binding(
            get: { textForCurrentSelection(fallback: text, title: title) },
            set: update
        ))
        .textFieldStyle(.roundedBorder)
        .font(.system(.subheadline, design: .rounded))
    }

    private func textForCurrentSelection(fallback: String, title: String) -> String {
        guard let element = viewModel.selectedElement else { return fallback }

        switch title {
        case "Title", "Label":
            return element.title
        case "Detail", "Stat B":
            return element.detailText
        default:
            return element.text
        }
    }

    private var emptyState: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.draw")
                .font(.title3)
                .foregroundStyle(Color(hex: "#246BFE"))
                .frame(width: 44, height: 44)
                .background(Color(hex: "#DBEAFE"))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("Select an element")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text("Drag items on the canvas. Use the tray below to add more.")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#6B7280"))
            }
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private struct ActionChip: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color(hex: "#F3F4F6"))
                .clipShape(Capsule())
        }
        .foregroundStyle(Color(hex: "#111827"))
    }
}

private struct ColorSwatchGroup: View {
    let title: String
    let selectedHex: String
    let colors: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(hex: "#6B7280"))

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(24), spacing: 6), count: 4), spacing: 6) {
                ForEach(colors, id: \.self) { hex in
                    Button {
                        onSelect(hex)
                    } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 24, height: 24)
                            .overlay {
                                Circle()
                                    .stroke(selectedHex == hex ? Color(hex: "#111827") : Color.black.opacity(0.08), lineWidth: selectedHex == hex ? 3 : 1)
                            }
                    }
                    .accessibilityLabel("\(title) \(hex)")
                }
            }
        }
    }
}
