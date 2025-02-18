/*
import SwiftUI
import FirebaseAuth
import CoreImage.CIFilterBuiltins
import FirebaseFirestore

struct SettingsView: View {
    @Binding var sessionID: String?
    @Binding var showingSettings: Bool
    @State private var qrCode: UIImage?
    @State private var showingScanner = false
    @State private var isCheckingSession = false

    var body: some View {
        VStack {
            if let qrCode = qrCode {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
            }

            Button(action: {
                showingScanner = true
            }) {
                Text("Scan QR Code")
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $showingScanner) {
                QRCodeScannerView { result in
                    handleScan(result: result)
                }
            }
        }
        .onAppear(perform: generateQRCode)
    }

    private func generateQRCode() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let data = Data(user.uid.utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        if let qrImage = filter.outputImage {
            if let cgimg = context.createCGImage(qrImage, from: qrImage.extent) {
                self.qrCode = UIImage(cgImage: cgimg)
            }
        }
    }

    private func handleScan(result: Result<String, QRCodeScannerView.ScanError>) {
        showingScanner = false
        switch result {
        case .success(let scannedID):
            if !isCheckingSession {
                isCheckingSession = true
                checkAndCreateChatSession(with: scannedID)
            }
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }

    private func checkAndCreateChatSession(with scannedID: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        let db = Firestore.firestore()
        db.collection("chatSessions")
            .whereField("participants", arrayContains: user.uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error checking for existing sessions: \(error)")
                    isCheckingSession = false
                    return
                }

                if let documents = querySnapshot?.documents {
                    for document in documents {
                        let participants = document.data()["participants"] as? [String] ?? []
                        if participants.contains(scannedID) {
                            self.sessionID = document.documentID
                            self.isCheckingSession = false
                            self.showingSettings = false // シートを閉じる
                            return
                        }
                    }
                }

                // If no existing session is found, create a new one
                createChatSession(with: scannedID)
            }
    }

    private func createChatSession(with scannedID: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        let db = Firestore.firestore()
        let newSessionID = UUID().uuidString
        let sessionData: [String: Any] = [
            "created": Timestamp(date: Date()),
            "participants": [user.uid, scannedID]
        ]

        db.collection("chatSessions").document(newSessionID).setData(sessionData) { error in
            isCheckingSession = false
            if let error = error {
                print("Error creating chat session: \(error)")
            } else {
                self.sessionID = newSessionID
                self.showingSettings = false // シートを閉じる
            }
        }
    }
}
*/
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreImage.CIFilterBuiltins

struct SettingsView: View {
    @Binding var sessionID: String?
    @Binding var showingSettings: Bool
    @State private var qrCode: UIImage?
    @State private var showingScanner = false
    @State private var isCheckingSession = false

    var body: some View {
        VStack {
            if let qrCode = qrCode {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
            }

            Button(action: {
                showingScanner = true
            }) {
                Text("Scan QR Code")
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $showingScanner) {
                QRCodeScannerView { result in
                    handleScan(result: result)
                }
            }
        }
        .onAppear(perform: generateQRCode)
    }

    private func generateQRCode() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let data = Data(user.uid.utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        if let qrImage = filter.outputImage {
            if let cgimg = context.createCGImage(qrImage, from: qrImage.extent) {
                self.qrCode = UIImage(cgImage: cgimg)
            }
        }
    }

    private func handleScan(result: Result<String, QRCodeScannerView.ScanError>) {
        showingScanner = false
        switch result {
        case .success(let scannedID):
            if !isCheckingSession {
                isCheckingSession = true
                checkAndCreateChatSession(with: scannedID)
            }
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }

    private func checkAndCreateChatSession(with scannedID: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        let db = Firestore.firestore()
        db.collection("chatSessions")
            .whereField("participants", arrayContains: user.uid)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error checking for existing sessions: \(error)")
                    isCheckingSession = false
                    return
                }

                if let documents = querySnapshot?.documents {
                    for document in documents {
                        let participants = document.data()["participants"] as? [String] ?? []
                        if participants.contains(scannedID) {
                            self.sessionID = document.documentID
                            self.isCheckingSession = false
                            self.showingSettings = false // シートを閉じる
                            return
                        }
                    }
                }

                // If no existing session is found, create a new one
                createChatSession(with: scannedID)
            }
    }

    private func createChatSession(with scannedID: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        let db = Firestore.firestore()
        let newSessionID = UUID().uuidString
        let sessionData: [String: Any] = [
            "created": Timestamp(date: Date()),
            "participants": [user.uid, scannedID]
        ]

        db.collection("chatSessions").document(newSessionID).setData(sessionData) { error in
            isCheckingSession = false
            if let error = error {
                print("Error creating chat session: \(error)")
            } else {
                self.sessionID = newSessionID
                self.showingSettings = false // シートを閉じる
            }
        }
    }
}
