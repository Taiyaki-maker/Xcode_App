//sk-proj-0SJ95JBfBI6kGc8Dr8CFT3BlbkFJvY6YSfiFHKK6gn2vSq8Q

import SwiftUI
import OpenAIKit

struct ContentView: View {
    @State private var message = "Press the button to send a message to ChatGPT."
    @State private var userInput = ""
    @State private var showAlert = false
    @State private var isCompleting = false
    @State private var openAI: OpenAI?
    @State private var chat: [ChatMessage] = []
    
    init() {
        let config = Configuration(
            organizationId: "YOUR_ORGANIZATION_ID", // ここに組織IDを入力
            apiKey: "ここにAPIキーを入力" // ここにAPIキーを入力
        )
        self._openAI = State(initialValue: OpenAI(config))
    }
    
    var body: some View {
        VStack {
            TextField("Enter your text here", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                sendMessageToChatGPT()
            }) {
                Text("Send")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isCompleting)
            .padding()
            
            Text(message)
                .padding()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Response"), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }
    
    func sendMessageToChatGPT() {
        guard let openAI = openAI else {
            message = "OpenAI client is not initialized."
            showAlert = true
            return
        }
        
        isCompleting = true
        let prompt = "以下の意見を事実と個人の感想に切り分けてください。表記は事実: 感想:という感じです。「\(userInput)」"
        chat.append(ChatMessage(role: .user, content: prompt))
        
        Task {
            do {
                let chatParameters = ChatParameters(model: .gpt4, messages: chat)
                let chatCompletion = try await openAI.generateChatCompletion(parameters: chatParameters)
                
                isCompleting = false
                
                if let firstMessage = chatCompletion.choices.first?.message?.content {
                    DispatchQueue.main.async {
                        message = firstMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        showAlert = true
                    }
                    // チャットにAIのレスポンスを追加
                    chat.append(ChatMessage(role: .assistant, content: firstMessage))
                } else {
                    DispatchQueue.main.async {
                        message = "Failed to get a response from ChatGPT."
                        showAlert = true
                    }
                }
            } catch {
                isCompleting = false
                DispatchQueue.main.async {
                    message = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
