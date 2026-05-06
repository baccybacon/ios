import Foundation

struct AssistantConfiguration {
    var apiKey: String
    var baseURL: URL
    var model: String
}

enum OpenAIClientError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case invalidResponse
    case requestFailed(Int, String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The AI service URL is invalid."
        case .missingAPIKey:
            return "Add your API key in Settings before sending a message."
        case .invalidResponse:
            return "The AI service returned an unexpected response."
        case .requestFailed(let statusCode, let message):
            return "Request failed with status \(statusCode): \(message)"
        case .emptyResponse:
            return "The assistant returned an empty response."
        }
    }
}

struct OpenAIClient {
    static let defaultBaseURL = URL(string: "https://api.openai.com/v1")!
    static let defaultModel = "gpt-4o-mini"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(messages: [ChatMessage], configuration: AssistantConfiguration) async throws -> ChatMessage {
        let apiKey = configuration.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty else {
            throw OpenAIClientError.missingAPIKey
        }

        let endpoint = configuration.baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ChatCompletionRequest(
            model: configuration.model,
            messages: apiMessages(from: messages),
            temperature: 0.7
        ))

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw OpenAIClientError.requestFailed(
                httpResponse.statusCode,
                apiError?.error.message ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            )
        }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty else {
            throw OpenAIClientError.emptyResponse
        }

        return ChatMessage(role: .assistant, content: content)
    }

    private func apiMessages(from messages: [ChatMessage]) -> [APIMessage] {
        var apiMessages = [
            APIMessage(
                role: ChatMessage.Role.system.rawValue,
                content: "You are a helpful, privacy-conscious personal assistant inside an iOS app. Be concise, practical, and ask clarifying questions when needed."
            )
        ]

        apiMessages.append(contentsOf: messages
            .filter { $0.role == .user || $0.role == .assistant }
            .map { APIMessage(role: $0.role.rawValue, content: $0.content) })

        return apiMessages
    }
}

private struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [APIMessage]
    let temperature: Double
}

private struct APIMessage: Codable {
    let role: String
    let content: String
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: APIMessage
    }
}

private struct APIErrorResponse: Decodable {
    let error: APIError

    struct APIError: Decodable {
        let message: String
    }
}
