import Foundation
import Combine

@MainActor
final class AssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        .welcome
    ]
    @Published var draft = ""
    @Published var isSending = false
    @Published var errorMessage: String?

    private let client: OpenAIClient

    init(client: OpenAIClient = OpenAIClient()) {
        self.client = client
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    func send() async {
        let trimmedMessage = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty, !isSending else { return }

        let userMessage = ChatMessage(role: .user, content: trimmedMessage)
        messages.append(userMessage)
        draft = ""
        isSending = true
        errorMessage = nil

        do {
            let reply = try await client.send(messages: messages, configuration: configuration())
            messages.append(reply)
        } catch {
            errorMessage = error.localizedDescription
        }

        isSending = false
    }

    func clearConversation() {
        messages = [
            ChatMessage(role: .assistant, content: "Conversation cleared. What would you like help with next?")
        ]
        draft = ""
        errorMessage = nil
    }

    private func configuration() throws -> AssistantConfiguration {
        let defaults = UserDefaults.standard
        let baseURLString = defaults.string(forKey: "apiBaseURL") ?? OpenAIClient.defaultBaseURL.absoluteString

        guard let baseURL = URL(string: baseURLString),
              baseURL.scheme == "http" || baseURL.scheme == "https" else {
            throw OpenAIClientError.invalidURL
        }

        return AssistantConfiguration(
            apiKey: KeychainStore.loadAPIKey() ?? "",
            baseURL: baseURL,
            model: defaults.string(forKey: "assistantModel") ?? OpenAIClient.defaultModel
        )
    }
}
