import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("assistantModel") private var model = OpenAIClient.defaultModel
    @AppStorage("apiBaseURL") private var apiBaseURL = OpenAIClient.defaultBaseURL.absoluteString

    @State private var apiKey = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Provider key")
                } footer: {
                    Text("Your key is stored in the iOS Keychain on this device and is never committed to the project.")
                }

                Section {
                    TextField("Model", text: $model)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    TextField("API base URL", text: $apiBaseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                } header: {
                    Text("AI provider")
                } footer: {
                    Text("The default endpoint uses OpenAI chat completions. You can point this at another OpenAI-compatible provider.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .onAppear {
                apiKey = KeychainStore.loadAPIKey() ?? ""
            }
        }
    }

    private func save() {
        errorMessage = nil

        guard let url = URL(string: apiBaseURL), url.scheme == "https" || url.scheme == "http" else {
            errorMessage = "Enter a valid HTTP API base URL."
            return
        }

        do {
            try KeychainStore.saveAPIKey(apiKey)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
