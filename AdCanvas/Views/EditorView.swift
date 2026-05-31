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
    @State private var isShowingCanvasSettings = false

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
                isShowingCanvasSettings = true
            } label: {
                Label("Canvas", systemImage: "slider.horizontal.3")
                    .labelStyle(.iconOnly)
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            }
            .foregroundStyle(Color(hex: "#111827"))
            .accessibilityLabel("Canvas settings")

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
        .sheet(isPresented: $isShowingCanvasSettings) {
            CanvasSettingsView(viewModel: viewModel)
        }
    }
}

private struct CanvasSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CanvasEditorViewModel

    @State private var widthText = ""
    @State private var heightText = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        TextField("Width", text: $widthText)
                            .keyboardType(.numberPad)
                        Text("x")
                            .foregroundStyle(Color(hex: "#6B7280"))
                        TextField("Height", text: $heightText)
                            .keyboardType(.numberPad)
                    }

                    Button("Apply custom size") {
                        applyCustomSize()
                    }
                } header: {
                    Text("Custom canvas")
                } footer: {
                    Text("Use any custom size from 240px to 4000px per side. Existing elements are kept inside the canvas.")
                }

                Section("Presets") {
                    ForEach(CanvasSizePreset.all) { preset in
                        Button {
                            viewModel.applyPresetCanvas(preset)
                            syncSizeFields()
                        } label: {
                            HStack {
                                Text(preset.name)
                                Spacer()
                                Text("\(Int(preset.size.width)) x \(Int(preset.size.height))")
                                    .foregroundStyle(Color(hex: "#6B7280"))
                            }
                        }
                    }
                }

                Section {
                    Toggle("Show grid guides", isOn: Binding(
                        get: { viewModel.design.guideSettings.showsGrid },
                        set: viewModel.updateGridVisibility
                    ))

                    Toggle("Snap to guide lines", isOn: Binding(
                        get: { viewModel.design.guideSettings.snapsToGrid },
                        set: viewModel.updateSnapToGrid
                    ))

                    Stepper(
                        "Guide spacing: \(Int(viewModel.design.guideSettings.gridSpacing))px",
                        value: Binding(
                            get: { viewModel.design.guideSettings.gridSpacing },
                            set: viewModel.updateGridSpacing
                        ),
                        in: 20...300,
                        step: 10
                    )
                } header: {
                    Text("Grid and snapping")
                } footer: {
                    Text("Snapping only aligns element centers or edges to nearby guide lines. Elements are not locked into grid boxes.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Canvas")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                syncSizeFields()
            }
        }
    }

    private func syncSizeFields() {
        widthText = "\(Int(viewModel.design.canvasSize.width))"
        heightText = "\(Int(viewModel.design.canvasSize.height))"
        errorMessage = nil
    }

    private func applyCustomSize() {
        guard let width = Double(widthText), let height = Double(heightText) else {
            errorMessage = "Enter numeric width and height values."
            return
        }

        viewModel.updateCanvasSize(width: width, height: height)
        syncSizeFields()
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
    }
}
