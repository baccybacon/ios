import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case system
        case user
        case assistant

        var displayName: String {
            switch self {
            case .system:
                return "System"
            case .user:
                return "You"
            case .assistant:
                return "Assistant"
            }
        }

        var systemImageName: String {
            switch self {
            case .system:
                return "gearshape"
            case .user:
                return "person.crop.circle"
            case .assistant:
                return "sparkles"
            }
        }
    }

    let id: UUID
    let role: Role
    let content: String
    let createdAt: Date

    init(id: UUID = UUID(), role: Role, content: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }

    static let welcome = ChatMessage(
        role: .assistant,
        content: "Hi, I am your AI assistant. Ask me to plan, write, summarize, brainstorm, or help with everyday tasks."
    )
}
