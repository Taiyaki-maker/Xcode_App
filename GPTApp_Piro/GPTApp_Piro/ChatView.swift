import SwiftUI
import GoogleGenerativeAI
import GoogleMobileAds

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, content: "詭弁の練習を始めます。以下のテーマに関して、あなたの意見を書いてください。"),
    ]
    @State private var text: String = ""
    @State private var isCompleting: Bool = false
    let fallacyName: String
    
    // MARK: - Ads
    
    // MARK: - Ads

    // GeminiAIの設定
    enum APIKey {
        static var ApiKey: String {
            guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist")
            else {
                fatalError("Couldn't find file 'Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY' in 'Info.plist'.")
            }
            if value.starts(with: "_") {
                fatalError("Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key.")
            }
            return value
        }
    }

    enum GeminError: Error {
        case invalidPrompt
        case requestFailed
        case badRequest
        case internalSeverError
    }

    let visionModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.ApiKey)

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) {
                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
            HStack {
                TextField("メッセージを入力", text: $text, axis: .vertical)
                    .disabled(isCompleting)
                    .font(.system(size: 17))
                    .padding(8)
                    .padding(.horizontal, 10)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                Button(action: {
                    let prompt = "「\(text)」この意見に対して、\(fallacyName)を使った反論を70字以内で作成してください。「」のような装飾はつけないようにお願いします。"
                    // ユーザーのメッセージを追加
                    let userMessage = ChatMessage(role: .user, content: text)
                    messages.append(userMessage)
                    sendMessageToGemini(prompt)
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(self.text.isEmpty ? Color.gray : Color.blue)
                }
                .disabled(self.text.isEmpty || isCompleting)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding()
        .navigationTitle("チャット")
        .onAppear {
            startChat()
        }
    }

    func startChat() {
        let first_prompt = "討論のテーマをランダムに一言設定してください。反対・賛成等はっきりできるテーマでお願いします。それ以外何も記述しないでください。"
        sendMessageToGemini(first_prompt)
    }

    func sendMessageToGemini(_ prompt: String) {
        isCompleting = true
        let loadingMessage = ChatMessage(role: .assistant, content: "Loading...")
        messages.append(loadingMessage)
        text = ""

        Task {
            do {
                let responseText = try await generateResponse(to: prompt)
                if let responseText = responseText {
                    updateMessage(content: responseText)
                } else {
                    updateMessage(content: "Failed to get a response from Gemini.")
                }
            } catch {
                updateMessage(content: "Error: \(error.localizedDescription)")
            }
            isCompleting = false
        }
    }

    func generateResponse(to text: String) async throws -> String? {
        do {
            let response = try await visionModel.generateContent(text)
            if let responseText = response.text {
                return responseText
            }
        } catch {
            handleGeminiError(error)
        }
        return nil
    }

    func handleGeminiError(_ error: Error) {
        if let geminiError = error as? GeminError {
            switch geminiError {
            case .invalidPrompt:
                print("入力が不正です.")
            case .requestFailed:
                print("リクエストが失敗しました.")
            case .badRequest:
                print("リクエストが不正です.")
            case .internalSeverError:
                print("サーバーエラーが発生しました.")
            }
        } else {
            print("予期せぬエラーが発生しました: \(error.localizedDescription)")
        }
    }

    func updateMessage(content: String) {
        DispatchQueue.main.async {
            if let index = messages.firstIndex(where: { $0.content == "Loading..." }) {
                messages[index] = ChatMessage(role: .assistant, content: content.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: MessageType
    let content: String

    enum MessageType: String {
        case user
        case assistant
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MessageView: View {
    var message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .assistant {
                AvatarView(imageName: "person.crop.circle")
                    .padding(.leading, 0)
                VStack(alignment: .leading, spacing: 4) {
                    if message.content == "Loading..." {
                        ProgressView()
                            .padding()
                    } else {
                        Text(message.content)
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .frame(maxWidth: 250, alignment: .leading)
                            .padding(.leading, 0)
                    }
                }
                .padding(.vertical, 5)
                Spacer()
            } else {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .frame(maxWidth: 250, alignment: .trailing)
                }
                .padding(.vertical, 5)
                .padding(.trailing, 0)
            }
        }
        .padding(.horizontal, 0)
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
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
