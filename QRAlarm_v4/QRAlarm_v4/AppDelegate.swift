import UIKit
import UserNotifications
import AVFoundation

//@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var player: AVAudioPlayer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 通知センターのデリゲートを設定
        UNUserNotificationCenter.current().delegate = self
        
        // 通知の許可をリクエスト
        requestNotificationAuthorization()
        
        return true
    }

    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知が許可されました")
            } else {
                print("通知が許可されませんでした: \(String(describing: error))")
            }
        }
    }

    // 通知がフォアグラウンドで受信されたときに呼び出される
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        playSound()
        completionHandler([.banner, .sound])
    }

    // 通知がバックグラウンドまたはロック画面で受信されたときに呼び出される
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        playSound()
        completionHandler()
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("音声ファイルが見つかりません")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // 無限ループ
            player?.prepareToPlay()
            player?.play()
        } catch let error {
            print("音声の再生に失敗しました: \(error.localizedDescription)")
        }
    }
}
