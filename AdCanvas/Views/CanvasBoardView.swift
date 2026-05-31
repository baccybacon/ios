import SwiftUI

struct CanvasBoardView: View {
    @ObservedObject var viewModel: CanvasEditorViewModel

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 20
            let availableWidth = max(geometry.size.width - horizontalPadding, 1)
            let availableHeight = max(geometry.size.height - 24, 1)
            let scale = min(
                availableWidth / viewModel.design.canvasSize.width,
                availableHeight / viewModel.design.canvasSize.height
            )

            VStack {
                Spacer(minLength: 0)
                CanvasSurfaceView(viewModel: viewModel, scale: scale)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxHeight: 500)
    }
}

private struct CanvasSurfaceView: View {
    @ObservedObject var viewModel: CanvasEditorViewModel
    let scale: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: viewModel.design.backgroundHex),
                            Color.white.opacity(viewModel.design.backgroundHex == "#111827" ? 0.04 : 0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            ForEach(viewModel.design.elements.sorted(by: { $0.zIndex < $1.zIndex })) { element in
                DraggableElementView(
                    element: element,
                    isSelected: element.id == viewModel.selectedElementID,
                    scale: scale,
                    select: {
                        viewModel.select(element.id)
                    },
                    move: { translation in
                        viewModel.moveElement(id: element.id, by: translation)
                    },
                    resize: { translation in
                        viewModel.resizeElement(id: element.id, by: translation)
                    }
                )
            }
        }
        .frame(width: viewModel.design.canvasSize.width, height: viewModel.design.canvasSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 2)
        }
        .shadow(color: .black.opacity(0.16), radius: 28, y: 18)
        .scaleEffect(scale, anchor: .center)
        .frame(width: viewModel.design.canvasSize.width * scale, height: viewModel.design.canvasSize.height * scale)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.select(nil)
        }
    }
}

private struct DraggableElementView: View {
    let element: CanvasElement
    let isSelected: Bool
    let scale: CGFloat
    let select: () -> Void
    let move: (CGSize) -> Void
    let resize: (CGSize) -> Void

    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var resizeOffset: CGSize = .zero

    private var previewSize: CGSize {
        CGSize(
            width: max(element.size.width + resizeOffset.width / scale, 60),
            height: max(element.size.height + resizeOffset.height / scale, 44)
        )
    }

    var body: some View {
        CanvasElementView(element: element)
            .frame(width: previewSize.width, height: previewSize.height)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Text("Move")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#111827"))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .offset(x: 16, y: -22)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: max(element.cornerRadius, 14), style: .continuous)
                    .stroke(isSelected ? Color(hex: "#246BFE") : Color.clear, lineWidth: isSelected ? 6 : 0)
            }
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    ResizeHandle()
                        .offset(x: 18, y: 18)
                        .gesture(
                            DragGesture(minimumDistance: 1)
                                .updating($resizeOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onChanged { _ in
                                    select()
                                }
                                .onEnded { value in
                                    resize(CGSize(width: value.translation.width / scale, height: value.translation.height / scale))
                                }
                        )
                }
            }
            .position(
                x: element.position.x + dragOffset.width / scale,
                y: element.position.y + dragOffset.height / scale
            )
            .gesture(
                DragGesture(minimumDistance: 1)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { _ in
                        select()
                    }
                    .onEnded { value in
                        move(CGSize(width: value.translation.width / scale, height: value.translation.height / scale))
                    }
            )
            .onTapGesture {
                select()
            }
    }
}

private struct ResizeHandle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 54, height: 54)
                .shadow(color: .black.opacity(0.18), radius: 12, y: 6)

            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: "#246BFE"))
        }
        .contentShape(Circle())
    }
}
