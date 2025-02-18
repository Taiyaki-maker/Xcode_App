//
//  voucher_sendApp.swift
//  voucher_send
//
//  Created by ごんざれす on 2024/05/26.
//

import SwiftUI
#if os(iOS)
import Speech
#endif

@main
struct voucher_sendApp: App {
    
    init() {
        // iOSのみで実行されるコード
        #if os(iOS)
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied:
                print("Speech recognition denied")
            case .restricted:
                print("Speech recognition restricted")
            case .notDetermined:
                print("Speech recognition not determined")
            @unknown default:
                fatalError("Unknown speech recognition authorization status")
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
