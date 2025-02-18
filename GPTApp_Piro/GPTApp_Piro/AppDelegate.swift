import UIKit
import AppTrackingTransparency
import AdSupport

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        requestTrackingAuthorization()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // 縦向きのみを許可
        return .portrait
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
}
