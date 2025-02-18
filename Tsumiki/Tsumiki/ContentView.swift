/*
import SwiftUI

struct ContentView: View {
    @StateObject private var appUsageTracker = AppUsageTracker()
    
    var body: some View {
        VStack {
            Text("アプリ使用時間トラッカー")
                .font(.largeTitle)
            
            Spacer()
            
            Text("総時間: \(timeString(from: totalTime))")
            Text("本アプリ使用時間: \(timeString(from: appUsageTracker.currentAppTime))")
            Text("他アプリ使用時間: \(timeString(from: appUsageTracker.otherAppsTime))")
            
            Spacer()
            
            HStack {
                Button(action: {
                    appUsageTracker.startTracking()
                }) {
                    Text("スタート")
                }
                .padding()
                
                Button(action: {
                    appUsageTracker.stopTracking()
                }) {
                    Text("ストップ")
                }
                .padding()
            }
        }
        .padding()
    }
    
    private var totalTime: TimeInterval {
        guard let startTime = appUsageTracker.startTime, let endTime = appUsageTracker.endTime else {
            return 0
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
*/
import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var scene: RectangleScene = {
        let scene = RectangleScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        print("Scene created")
        return scene
    }()
    @State private var isAppActive = true

    var body: some View {
        VStack {
            SpriteView(scene: scene)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 150) // Adjust height to leave space for buttons
                .ignoresSafeArea()
                .onAppear {
                    print("SpriteView appeared")
                    NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                        self.isAppActive = true
                        if self.scene.isTracking {
                            self.scene.startTimer()
                        }
                        print("App did become active")
                    }
                    NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
                        self.isAppActive = false
                        self.scene.stopTimer()
                        print("App will resign active")
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
                }

            HStack {
                Button(action: {
                    print("Start button pressed")
                    if self.isAppActive {
                        scene.startTracking()
                    }
                }) {
                    Text("スタート")
                        .frame(width: 100, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Button(action: {
                    print("Stop button pressed")
                    scene.stopTracking()
                }) {
                    Text("ストップ")
                        .frame(width: 100, height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
