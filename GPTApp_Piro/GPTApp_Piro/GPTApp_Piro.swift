import SwiftUI

@main
struct GPTApp_Piro: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView().environmentObject(appDelegate)
        }
    }
}
