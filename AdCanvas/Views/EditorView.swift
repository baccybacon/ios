import SwiftUI

struct EditorView: View {
    @StateObject private var viewModel = CanvasEditorViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F3F4F6")
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    HeaderBar(viewModel: viewModel)
                    CanvasBoardView(viewModel: viewModel)
                    InspectorView(viewModel: viewModel)
                    ElementTrayView(viewModel: viewModel)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct HeaderBar: View {
    @ObservedObject var viewModel: CanvasEditorViewModel

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ad Canvas")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color(hex: "#111827"))

                Text("Build clean dashboard ads")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "#6B7280"))
            }

            Spacer()

            Button {
                viewModel.resetToStarterTemplate()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .labelStyle(.iconOnly)
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            }
            .foregroundStyle(Color(hex: "#111827"))
            .accessibilityLabel("Reset template")
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
