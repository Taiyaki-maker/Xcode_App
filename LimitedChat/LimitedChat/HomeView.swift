/*
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var sessions: [ChatSession] = []
    @State private var showingSettings = false
    @State private var navigateToChat = false
    @State private var sessionID: String? {
        didSet {
            if sessionID != nil {
                navigateToChat = true
            }
        }
    }
    @State private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            List(sessions) { session in
                NavigationLink(destination: ChatView(sessionID: session.id)) {
                    Text("Session with: \(session.participants.joined(separator: ", "))")
                }
            }
            .navigationBarTitle("Chats")
            .navigationBarItems(leading: Button(action: {
                appDelegate.logout()
            }) {
                Text("Logout")
            }, trailing: Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "plus")
            })
            .onAppear {
                fetchChatSessions()
                addListener()
            }
            .onDisappear {
                listener?.remove()
            }
            .sheet(isPresented: $showingSettings, onDismiss: handleSessionIDChange) {
                SettingsView(sessionID: $sessionID, showingSettings: $showingSettings)
            }
            .background(
                NavigationLink(destination: ChatView(sessionID: sessionID ?? ""), isActive: $navigateToChat) {
                    EmptyView()
                }
            )
        }
    }

    private func fetchChatSessions() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        db.collection("chatSessions").whereField("participants", arrayContains: user.uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching chat sessions: \(error)")
            } else {
                self.sessions = querySnapshot?.documents.map { ChatSession(document: $0) } ?? []
            }
        }
    }

    private func handleSessionIDChange() {
        if sessionID != nil {
            DispatchQueue.main.async {
                navigateToChat = true
            }
        }
    }

    private func addListener() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        var isInitialLoad = true

        listener = db.collection("chatSessions")
            .whereField("participants", arrayContains: user.uid)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening for session changes: \(error)")
                    return
                }

                if isInitialLoad {
                    isInitialLoad = false
                    return // 初回ロード時の変更を無視する
                }

                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        if let participants = data["participants"] as? [String], participants.contains(user.uid) {
                            self.sessionID = change.document.documentID
                        }
                    }
                }
            }
    }
}

struct ChatSession: Identifiable {
    var id: String
    var participants: [String]

    init(document: DocumentSnapshot) {
        self.id = document.documentID
        let data = document.data() ?? [:]
        self.participants = data["participants"] as? [String] ?? []
    }
}
*/

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var sessions: [ChatSession] = []
    @State private var showingSettings = false
    @State private var navigateToChat = false
    @State private var sessionID: String? {
        didSet {
            if sessionID != nil {
                navigateToChat = true
            }
        }
    }
    @State private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 0) { // VStackのスペースを0に設定
            HStack {
                Button(action: {
                    appDelegate.logout()
                }) {
                    Text("Logout")
                }
                Spacer()
                Text("Chats")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal)
            .frame(height: 50) // カスタムナビゲーションバーの高さを最小化

            Divider() // ナビゲーションバーとリストの間に区切り線を追加

            List(sessions) { session in
                NavigationLink(destination: ChatView(sessionID: session.id)) {
                    Text("Session with: \(session.participants.joined(separator: ", "))")
                }
            }
            .onAppear {
                fetchChatSessions()
                addListener()
            }
            .onDisappear {
                listener?.remove()
            }
            .sheet(isPresented: $showingSettings, onDismiss: handleSessionIDChange) {
                SettingsView(sessionID: $sessionID, showingSettings: $showingSettings)
            }
            .background(
                NavigationLink(destination: ChatView(sessionID: sessionID ?? ""), isActive: $navigateToChat) {
                    EmptyView()
                }
            )
        }
    }

    private func fetchChatSessions() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        db.collection("chatSessions").whereField("participants", arrayContains: user.uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching chat sessions: \(error)")
            } else {
                self.sessions = querySnapshot?.documents.map { ChatSession(document: $0) } ?? []
            }
        }
    }

    private func handleSessionIDChange() {
        if sessionID != nil {
            DispatchQueue.main.async {
                navigateToChat = true
            }
        }
    }

    private func addListener() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        var isInitialLoad = true

        listener = db.collection("chatSessions")
            .whereField("participants", arrayContains: user.uid)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening for session changes: \(error)")
                    return
                }

                if isInitialLoad {
                    isInitialLoad = false
                    return // 初回ロード時の変更を無視する
                }

                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        if let participants = data["participants"] as? [String], participants.contains(user.uid) {
                            self.sessionID = change.document.documentID
                        }
                    }
                }
            }
    }
}
struct ChatSession: Identifiable {
    var id: String
    var participants: [String]

    init(document: DocumentSnapshot) {
        self.id = document.documentID
        let data = document.data() ?? [:]
        self.participants = data["participants"] as? [String] ?? []
    }
}
