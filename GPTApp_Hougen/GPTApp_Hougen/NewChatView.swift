import SwiftUI

struct NewChatView: View {
    @Binding var chats: [ChatSession]
    @Environment(\.presentationMode) var presentationMode
    @State private var chatName: String = ""
    @State private var selectedDialect: String = "津軽弁"
    @State private var navigateToChat = false
    
    let dialects = ["津軽弁", "関西弁", "沖縄弁"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("チャットの名前", text: $chatName)
                
                Picker("方言を選択", selection: $selectedDialect) {
                    ForEach(dialects, id: \.self) { dialect in
                        Text(dialect)
                    }
                }
            }
            .navigationBarItems(leading: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("作成") {
                let chat = ChatSession(name: chatName, dialect: selectedDialect)
                chats.append(chat)
                UserDefaults.standard.saveChats(chats)
                navigateToChat = true
            })
            .navigationTitle("新しいチャット")
            .background(
                NavigationLink(
                    destination: ChatView(chat: chats.last ?? ChatSession(name: "", dialect: ""), chats: $chats),
                    isActive: $navigateToChat,
                    label: { EmptyView() }
                )
            )
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView(chats: .constant([]))
    }
}
