import UIKit
import AVFoundation
import UserNotifications
import SwiftUI

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, ObservableObject {

    @Published var window: UIWindow?
    @Published var audioPlayer: AVAudioPlayer?
    @Published var alarms: [CustomAlarm] = [] {
        didSet {
            saveAlarms()
        }
    }
    @Published var currentAlarm: CustomAlarm?
    @Published var showWakeUpView = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate didFinishLaunchingWithOptions")
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        loadAlarms()
        return true
    }

    func requestNotificationAuthorization() {
        print("Requesting notification authorization")
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Notification authorization request failed: \(error.localizedDescription)")
            }
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification authorization denied")
            }
        }
    }

    private func loadAlarms() {
        print("Loading alarms")
        if let savedAlarmsData = UserDefaults.standard.data(forKey: "alarms"),
           let savedAlarms = try? JSONDecoder().decode([CustomAlarm].self, from: savedAlarmsData) {
            alarms = savedAlarms
            print("Loaded alarms: \(alarms.map { $0.id.uuidString })")
        }
    }

    func saveAlarms() {
        print("Saving alarms")
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: "alarms")
        }
        print("Alarms saved")
    }

    func configureAudioSession() {
        print("Configuring audio session")
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    func playAlarmSound(soundName: String?) {
        configureAudioSession()

        guard let soundName = soundName else {
            print("サウンド名が指定されていません")
            return
        }

        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("アラーム音が見つかりません: \(soundName)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            print("アラーム音が再生されました: \(soundName)")
        } catch {
            print("アラーム音の再生に失敗しました: \(error.localizedDescription)")
        }
    }

    func stopAlarmSound() {
        audioPlayer?.stop()
        print("アラーム音が停止されました")
    }

    func startAlarm(for alarm: CustomAlarm) {
        print("Start alarm")
        currentAlarm = alarm

        // アラーム音の再生を先に行う
        playAlarmSound(soundName: alarm.soundName)

        DispatchQueue.main.async {
            if !self.showWakeUpView {
                self.showWakeUpView = true
                print("Show wake up view set to true")

                if let window = UIApplication.shared.windows.first {
                    let rootViewController = window.rootViewController
                    let wakeUpViewController = UIHostingController(rootView: WakeUpView(stopAlarm: {
                        self.stopAlarm()
                    }, barcode: self.currentAlarm?.barcode))
                    wakeUpViewController.modalPresentationStyle = .fullScreen
                    rootViewController?.present(wakeUpViewController, animated: true, completion: nil)
                    print("Wake up view presented")
                }
            } else {
                print("Wake up view is already presented")
            }
        }
    }

    func stopAlarm() {
        stopAlarmSound()
        print("Stop alarm")
        if let currentAlarm = currentAlarm, let index = alarms.firstIndex(where: { $0.id == currentAlarm.id }) {
            alarms[index].isOn = false
            saveAlarms()
        }
        currentAlarm = nil
        self.showWakeUpView = false
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController?.dismiss(animated: true, completion: {
                    print("Wake up view dismissed")
                })
            }
        }
    }

    func cancelAlarm(for alarm: CustomAlarm) {
        print("アラームがキャンセルされました: \(alarm.id.uuidString)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }

    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will present")
        let userInfo = notification.request.content.userInfo
        if let alarmID = userInfo["id"] as? String {
            currentAlarm = alarms.first { $0.id.uuidString == alarmID }
            if let alarm = currentAlarm {
                startAlarm(for: alarm)
            }
        }
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification did receive")
        let userInfo = response.notification.request.content.userInfo
        if let alarmID = userInfo["id"] as? String {
            currentAlarm = alarms.first { $0.id.uuidString == alarmID }
            if let alarm = currentAlarm {
                startAlarm(for: alarm)
            }
        }
        completionHandler()
    }
    */
}
