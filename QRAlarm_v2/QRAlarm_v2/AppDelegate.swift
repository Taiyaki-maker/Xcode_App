import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ObservableObject {

    var window: UIWindow?

    // アプリがフォアグラウンドに戻るときに呼び出される
    func applicationWillEnterForeground(_ application: UIApplication) {
        appDidEnterForeground()
    }

    // フォアグラウンドに戻ったときに実行する関数
    func appDidEnterForeground() {
        // ここに実行したい処理を記述します
        print("App has entered foreground")
    }
}
