import Foundation
import FirebaseFirestore

/*
struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var content: String
    var sender: String
    var timestamp: Timestamp
}
*/

struct ChatMessage: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var content: String
    var sender: String
    var timestamp: Timestamp

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

