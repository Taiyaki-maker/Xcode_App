/*
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var sendToToken: String?

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Button(action: {
                        sendPushNotification(to: sendToToken ?? "")
                    }) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                .navigationBarItems(trailing: NavigationLink(destination: SettingsView(sendToToken: $sendToToken).environmentObject(appDelegate)) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                })
                
                ForEach(appDelegate.hearts) { heart in
                    HeartView()
                        .position(heart.position)
                }
            }
        }
    }

    func sendPushNotification(to token: String) {
        guard !token.isEmpty else { return }

        let urlString = "https://sendpushnotification-rj4n4iw5na-uc.a.run.app"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "token": token,
            "title": "Hello",
            "body": "This is a test notification"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: \(error)")
                return
            }

            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Successfully sent push notification")
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            } else {
                print("Failed to send push notification")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppDelegate())
    }
}
*/
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var sendToToken: String?
    @State private var isShowingInformation = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Button(action: {
                        sendPushNotification(to: sendToToken ?? "")
                    }) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                .navigationBarItems(leading: Button(action: {
                    isShowingInformation = true
                }) {
                    Image(systemName: "info.circle")
                        .imageScale(.large)
                }, trailing: NavigationLink(destination: SettingsView(sendToToken: $sendToToken).environmentObject(appDelegate)) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                })
                
                ForEach(appDelegate.hearts) { heart in
                    HeartView()
                        .position(heart.position)
                }
            }
            .sheet(isPresented: $isShowingInformation) {
                InformationView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    func sendPushNotification(to token: String) {
        guard !token.isEmpty else { return }

        let urlString = "https://sendpushnotification-rj4n4iw5na-uc.a.run.app"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "token": token,
            "title": "Hello",
            "body": "This is a test notification"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: \(error)")
                return
            }

            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Successfully sent push notification")
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            } else {
                print("Failed to send push notification")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppDelegate())
    }
}
