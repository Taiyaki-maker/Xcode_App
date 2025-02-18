import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    var id = UUID()
    var role: Role
    var content: String
    
    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
    
    enum Role: String, Codable {
        case user
        case assistant
        case system
    }
    
    static func ==(lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
