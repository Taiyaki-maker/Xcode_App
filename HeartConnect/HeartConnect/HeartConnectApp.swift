/*
import SwiftUI

@main
struct HeartConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate)
        }
    }
}
*/

import SwiftUI

@main
struct HeartConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(appDelegate)
        }
    }
}
