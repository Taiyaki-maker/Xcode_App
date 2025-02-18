/*
import UIKit
import Firebase
import FirebaseMessaging
import SwiftUI

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {

    @Published var deviceTokenString: String?
    @Published var hearts: [UUID] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.deviceTokenString = fcmToken
        print("Firebase registration token: \(String(describing: fcmToken))")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        addHeart()
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        addHeart()
        completionHandler()
    }

    func addHeart() {
        let heartID = UUID()
        hearts.append(heartID)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // 3秒後にハートを削除
            if let index = self.hearts.firstIndex(of: heartID) {
                self.hearts.remove(at: index)
            }
        }
    }
}
*/

import UIKit
import Firebase
import FirebaseMessaging
import SwiftUI

struct Heart: Identifiable {
    let id = UUID()
    let position: CGPoint
}

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {

    @Published var deviceTokenString: String?
    @Published var hearts: [Heart] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.deviceTokenString = fcmToken
        print("Firebase registration token: \(String(describing: fcmToken))")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        addHeart()
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        addHeart()
        completionHandler()
    }

    func addHeart() {
        let heartPosition = CGPoint(x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                                    y: CGFloat.random(in: 50...UIScreen.main.bounds.height - 50))
        let heart = Heart(position: heartPosition)
        hearts.append(heart)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // 3秒後にハートを削除
            if let index = self.hearts.firstIndex(where: { $0.id == heart.id }) {
                self.hearts.remove(at: index)
            }
        }
    }
}
