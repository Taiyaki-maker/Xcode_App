import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        VStack {
            Button(action: {
                print("setAlarm")
            }) {
                Text("スタート")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                print("stopAlarm")
            }) {
                Text("ストップ")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
