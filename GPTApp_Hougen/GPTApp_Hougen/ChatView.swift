import SwiftUI
import OpenAIKit

struct ChatView: View {
    @ObservedObject var chat: ChatSession
    @Binding var chats: [ChatSession]
    @State private var text: String = ""
    @State private var isCompleting: Bool = false
    @State private var openAI: OpenAI?
    
    @FocusState private var isTextFieldFocused: Bool
    
    init(chat: ChatSession, chats: Binding<[ChatSession]>) {
        self.chat = chat
        self._chats = chats
        let config = Configuration(
            organizationId: "YOUR_ORGANIZATION_ID",
            apiKey: "ここにAPIキーを入力"
        )
        self._openAI = State(initialValue: OpenAI(config))
        print("ChatViewが初期化されました: \(chat)")
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(chat.messages.indices, id: \.self) { index in
                            MessageView(message: chat.messages[index])
                                .id(index)
                        }
                    }
                }
                .padding(.top)
                .onChange(of: chat.messages) { _ in
                    scrollViewProxy.scrollTo(chat.messages.count - 1, anchor: .bottom)
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            
            HStack {
                TextField("メッセージを入力", text: $text)
                    .disabled(isCompleting)
                    .font(.system(size: 15))
                    .padding(8)
                    .padding(.horizontal, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                Button(action: {
                    sendMessageToChatGPT()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(self.text == "" ? Color.gray : Color.blue)
                }
                .disabled(self.text == "" || isCompleting)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding()
        .navigationTitle(chat.name)
        .onAppear {
            if chat.messages.isEmpty {
                startChat()
            }
        }
        .onDisappear {
            saveChat()
        }
    }
    
    func startChat() {
        chat.messages.append(ChatMessage(role: .system, content: "今から「\(chat.dialect)」で会話してもらいます。よろしくお願いします。"))
        
        let initialPrompt = "今から「\(chat.dialect)」で会話してもらいます。コンセプトとしては、ひさびさに会った地元の友達で、雰囲気に合わせて質問したり話を聞いたりしてください。友達と会話してる感じを出すために'「」'などはつけず、なるべく短めでお願いします。ではそちらから会話を始めてください。"
        
        Task {
            do {
                let chatParameters = ChatParameters(model: .gpt4, messages: [OpenAIKit.ChatMessage(role: .user, content: initialPrompt)])
                let chatCompletion = try await openAI?.generateChatCompletion(parameters: chatParameters)
                
                if let firstMessage = chatCompletion?.choices.first?.message?.content {
                    DispatchQueue.main.async {
                        chat.messages.append(ChatMessage(role: .assistant, content: firstMessage.trimmingCharacters(in: .whitespacesAndNewlines)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    chat.messages.append(ChatMessage(role: .system, content: "Error: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    func sendMessageToChatGPT() {
            guard let openAI = openAI else { return }
            
            isCompleting = true
            
            chat.messages.append(ChatMessage(role: .user, content: text))
            let prompt = "次のメッセージを「\(chat.dialect)」で返信してください: \(text)"
            
            //text = ""
            self.text = self.text + " "
            Task { @MainActor in
                self.text = ""
            }
            
            Task {
                do {
                    let openAIMessages = chat.messages.map { OpenAIKit.ChatMessage(role: $0.role == .user ? .user : .assistant, content: $0.content) }
                    let chatParameters = ChatParameters(model: .gpt4, messages: openAIMessages + [OpenAIKit.ChatMessage(role: .user, content: prompt)])
                    let chatCompletion = try await openAI.generateChatCompletion(parameters: chatParameters)
                    
                    isCompleting = false
                    
                    if let firstMessage = chatCompletion.choices.first?.message?.content {
                        DispatchQueue.main.async {
                            chat.messages.append(ChatMessage(role: .assistant, content: firstMessage.trimmingCharacters(in: .whitespacesAndNewlines)))
                        }
                    } else {
                        DispatchQueue.main.async {
                            chat.messages.append(ChatMessage(role: .system, content: "Failed to get a response from ChatGPT."))
                        }
                    }
                } catch {
                    isCompleting = false
                    DispatchQueue.main.async {
                        chat.messages.append(ChatMessage(role: .system, content: "Error: \(error.localizedDescription)"))
                    }
                }
            }
        }
        
    
    func saveChat() {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index] = chat
            UserDefaults.standard.saveChats(chats)
        }
    }
}

struct MessageView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            } else {
                AvatarView(imageName: "avatar")
                    .padding(.trailing, 8)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(message.role == .user ? .white : .black)
                    .padding(10)
                    .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(20)
            }
            .padding(.vertical, 5)
            if message.role != .user {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct AvatarView: View {
    var imageName: String
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            Text("AI")
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chat: ChatSession(id: UUID(), name: "テストチャット", dialect: "津軽弁"), chats: .constant([]))
    }
}
