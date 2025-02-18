/*
 import SwiftUI
 
 struct WakeUpView: View {
 var stopAlarm: () -> Void
 @State private var showBarcodeScanner = false
 var barcode: String?
 
 var body: some View {
 VStack {
 Text("アラーム停止")
 .font(.largeTitle)
 .padding()
 
 if let barcode = barcode, !barcode.isEmpty {
 Button(action: {
 showBarcodeScanner = true
 }) {
 Text("バーコードをスキャンする")
 .padding()
 .background(Color.blue)
 .foregroundColor(.white)
 .cornerRadius(8)
 }
 .fullScreenCover(isPresented: $showBarcodeScanner) {
 BarcodeScannerViewControllerRepresentable(onScan: { code in
 // バーコードが設定した値と一致する場合にアラームを停止
 if code == barcode {
 print("Scanned code matches: \(code)")
 stopAlarm()
 } else {
 print("Scanned code does not match: \(code)")
 }
 })
 }
 } else {
 Button(action: {
 stopAlarm()
 }) {
 Text("アラームを停止する")
 .padding()
 .background(Color.red)
 .foregroundColor(.white)
 .cornerRadius(8)
 }
 }
 }
 .frame(maxWidth: .infinity, maxHeight: .infinity)
 .background(Color.white)
 .edgesIgnoringSafeArea(.all)
 .navigationBarHidden(true) // ナビゲーションバーを非表示にする
 }
 }
 */

import SwiftUI

struct WakeUpView: View {
    var stopAlarm: () -> Void
    @State private var showBarcodeScanner = false
    var barcode: String?

    var body: some View {
        VStack {
            Text("アラーム停止")
                .font(.largeTitle)
                .padding()

            if let barcode = barcode, !barcode.isEmpty {
                Button(action: {
                    showBarcodeScanner = true
                }) {
                    Text("バーコードをスキャンする")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .fullScreenCover(isPresented: $showBarcodeScanner) {
                    BarcodeScannerViewControllerRepresentable(onScan: { code in
                        // バーコードが設定した値と一致する場合にアラームを停止
                        if code == barcode {
                            print("Scanned code matches: \(code)")
                            stopAlarm()
                        } else {
                            print("Scanned code does not match: \(code)")
                        }
                    })
                }
            } else {
                Button(action: {
                    stopAlarm()
                }) {
                    Text("アラームを停止する")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
