import Foundation
import UIKit

class AppUsageTracker: ObservableObject {
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var currentAppTime: TimeInterval = 0
    @Published var otherAppsTime: TimeInterval = 0
    private var timer: Timer?
    
    func startTracking() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.trackUsage()
        }
    }
    
    func stopTracking() {
        endTime = Date()
        timer?.invalidate()
        timer = nil
    }
    
    private func trackUsage() {
        guard let startTime = startTime else { return }
        let totalTime = Date().timeIntervalSince(startTime)
        // 現在のアプリがフォアグラウンドにあるかどうかをチェック（シンプルなチェック）
        let isCurrentApp = UIApplication.shared.applicationState == .active
        if isCurrentApp {
            currentAppTime += 1
        } else {
            otherAppsTime = totalTime - currentAppTime
        }
    }
    
    func reset() {
        startTime = nil
        endTime = nil
        currentAppTime = 0
        otherAppsTime = 0
    }
}
