/*
import Foundation
import SwiftUI

class ChatSession: ObservableObject, Identifiable {
    let id: UUID
    @Published var name: String
    @Published var dialect: String
    
    init(id: UUID = UUID(), name: String, dialect: String) {
        self.id = id
        self.name = name
        self.dialect = dialect
    }
}
*/

import Foundation
import SwiftUI

class ChatSession: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    @Published var dialect: String
    @Published var messages: [ChatMessage] = []
    
    init(id: UUID = UUID(), name: String, dialect: String) {
        self.id = id
        self.name = name
        self.dialect = dialect
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, dialect, messages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        dialect = try container.decode(String.self, forKey: .dialect)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dialect, forKey: .dialect)
        try container.encode(messages, forKey: .messages)
    }
}
