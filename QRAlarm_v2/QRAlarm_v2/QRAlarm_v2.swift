import SwiftUI
import UserNotifications
import AVFoundation

@main
struct QRAlarm_v2: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        appDidEnterForeground()
                    }
                //.environmentObject(appDelegate)
                }
        }
    }
    
    func appDidEnterForeground() {
        // ここに実行したい処理を記述します
        print("App has entered foreground")
    }
}
