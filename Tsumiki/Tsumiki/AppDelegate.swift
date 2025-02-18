import UIKit
import AppTrackingTransparency
import AdSupport

//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestAppTrackingPermission()
        return true
    }
    
    func requestAppTrackingPermission() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("Tracking authorized")
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier
                        print("IDFA: \(idfa)")
                    case .denied:
                        print("Tracking denied")
                    case .notDetermined:
                        print("Tracking not determined")
                    case .restricted:
                        print("Tracking restricted")
                    @unknown default:
                        fatalError()
                    }
                }
            }
        }
    }
}
