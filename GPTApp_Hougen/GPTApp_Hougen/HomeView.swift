import SwiftUI

struct HomeView: View {
    @State private var chats: [ChatSession] = UserDefaults.standard.loadChats()
    @State private var showingNewChatView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(chats) { chat in
                    NavigationLink(destination: ChatView(chat: chat, chats: $chats)) {
                        Text(chat.name)
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarItems(trailing: Button(action: {
                showingNewChatView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingNewChatView) {
                NewChatView(chats: $chats)
            }
        }
        .onDisappear {
            UserDefaults.standard.saveChats(chats)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
