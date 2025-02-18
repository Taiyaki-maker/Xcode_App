import Foundation

extension UserDefaults {
    private enum Keys {
        static let chats = "chats"
    }
    
    func saveChats(_ chats: [ChatSession]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(chats) {
            set(encoded, forKey: Keys.chats)
        }
    }
    
    func loadChats() -> [ChatSession] {
        let decoder = JSONDecoder()
        if let data = data(forKey: Keys.chats),
           let decoded = try? decoder.decode([ChatSession].self, from: data) {
            return decoded
        }
        return []
    }
}
