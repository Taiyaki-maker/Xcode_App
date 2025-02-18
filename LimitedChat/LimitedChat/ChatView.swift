/*
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    var sessionID: String
    @State private var messages: [ChatMessage] = []
    @State private var text: String = ""
    private let db = Firestore.firestore()

    var body: some View {
        VStack {
            List(messages) { message in
                HStack {
                    if message.sender == Auth.auth().currentUser?.uid {
                        Spacer()
                        Text(message.content)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    } else {
                        Text(message.content)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }

            HStack {
                TextField("メッセージを入力", text: $text,axis: .vertical)
                    //.disabled(isCompleting)
                    .font(.system(size: 17))
                    .padding(8)
                    .padding(.horizontal, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(self.text == "" ? Color.gray : Color.blue)
                }
            }
            .padding()
        }
        .onAppear(perform: fetchMessages)
    }

    private func sendMessage() {
        guard let user = Auth.auth().currentUser else { return }
        let message = [
            "content": text,
            "sender": user.uid,
            "timestamp": Timestamp()
        ] as [String : Any]

        db.collection("chatSessions").document(sessionID).collection("messages").addDocument(data: message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self.text = ""
            }
        }
    }

    private func fetchMessages() {
        db.collection("chatSessions").document(sessionID).collection("messages").order(by: "timestamp").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                return
            }

            self.messages = querySnapshot?.documents.compactMap { document -> ChatMessage? in
                try? document.data(as: ChatMessage.self)
            } ?? []
        }
    }
}
*/

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    var sessionID: String
    @State private var messages: [ChatMessage] = []
    @State private var text: String = ""
    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 0) { // VStackのスペースを0に設定
            HStack {
                /*
                Button(action: {
                }) {
                    Image(systemName: "arrow.left")
                }
                 */
                
                Spacer()
                Text("Chat")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 40) // カスタムナビゲーションバーの高さを最小化

            Divider() // ナビゲーションバーとメッセージリストの間に区切り線を追加

            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _ in
                    if let lastMessage = messages.last {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("メッセージを入力", text: $text, axis: .vertical)
                    .font(.system(size: 17))
                    .padding(8)
                    .padding(.horizontal, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(self.text.isEmpty ? Color.gray : Color.blue)
                }
                .disabled(self.text.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .onAppear(perform: fetchMessages)
    }

    private func sendMessage() {
        guard let user = Auth.auth().currentUser else { return }
        let message = [
            "content": text,
            "sender": user.uid,
            "timestamp": Timestamp()
        ] as [String : Any]

        db.collection("chatSessions").document(sessionID).collection("messages").addDocument(data: message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                self.text = ""
            }
        }
    }

    private func fetchMessages() {
        db.collection("chatSessions").document(sessionID).collection("messages").order(by: "timestamp").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                return
            }

            self.messages = querySnapshot?.documents.compactMap { document -> ChatMessage? in
                try? document.data(as: ChatMessage.self)
            } ?? []
        }
    }
}

struct MessageView: View {
    var message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.sender == Auth.auth().currentUser?.uid {
                Spacer()
                Text(message.content)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                AvatarView(imageName: "person.crop.circle")
                    .padding(.leading, 0) // 左の余白をなくす
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .frame(maxWidth: 250, alignment: .leading)
                        .padding(.leading, 0)  // 左の余白をなくす
                }
                .padding(.vertical, 5)
                Spacer()
            }
        }
        .padding(.horizontal, 0) // 全体の余白をなくす
        .frame(maxWidth: .infinity, alignment: message.sender == Auth.auth().currentUser?.uid ? .trailing : .leading)
    }
}

struct AvatarView: View {
    var imageName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            Text("論破王")
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}
