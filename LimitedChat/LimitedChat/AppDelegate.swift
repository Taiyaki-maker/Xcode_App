/*
import UIKit
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var isLoggedIn: Bool = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // ユーザーのログイン状態を確認
        if Auth.auth().currentUser != nil {
            self.isLoggedIn = true
        }

        return true
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
*/

import UIKit
import Firebase
import AppTrackingTransparency // 追加
import AdSupport // 追加

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var isLoggedIn: Bool = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // ユーザーのログイン状態を確認
        if Auth.auth().currentUser != nil {
            self.isLoggedIn = true
        }

        // トラッキング許可リクエストを実行
        requestTrackingAuthorization()

        return true
    }

    func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 1秒の遅延を設定
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("Tracking authorized")
                    case .denied:
                        print("Tracking denied")
                    case .restricted:
                        print("Tracking restricted")
                    case .notDetermined:
                        print("Tracking not determined")
                    @unknown default:
                        print("Unknown tracking authorization status")
                    }
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
