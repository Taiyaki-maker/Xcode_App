//import SwiftUI
//import FirebaseAuth
//
//struct ContentView: View {
//    @EnvironmentObject var appDelegate: AppDelegate
//    @State private var isRegistering = true
//
//    var body: some View {
//        Group {
//            if appDelegate.isLoggedIn {
//                HomeView()
//                    .environmentObject(appDelegate)
//            } else if isRegistering {
//                RegisterView(isRegistering: $isRegistering)
//                    .environmentObject(appDelegate)
//            } else {
//                LoginView(isRegistering: $isRegistering)
//                    .environmentObject(appDelegate)
//            }
//        }
//        .onAppear {
//            // 初回起動時にログイン状態を確認
//            if Auth.auth().currentUser != nil {
//                appDelegate.isLoggedIn = true
//            }
//        }
//    }
//}
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var isRegistering = true

    var body: some View {
        NavigationView {
            Group {
                if appDelegate.isLoggedIn {
                    HomeView()
                        .environmentObject(appDelegate)
                } else if isRegistering {
                    RegisterView(isRegistering: $isRegistering)
                        .environmentObject(appDelegate)
                } else {
                    LoginView(isRegistering: $isRegistering)
                        .environmentObject(appDelegate)
                }
            }
        }
        .onAppear {
            // 初回起動時にログイン状態を確認
            if Auth.auth().currentUser != nil {
                appDelegate.isLoggedIn = true
            }
        }
    }
}
