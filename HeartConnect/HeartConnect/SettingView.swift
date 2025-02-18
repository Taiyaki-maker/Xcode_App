/*
import SwiftUI
import CoreImage.CIFilterBuiltins

struct SettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Binding var sendToToken: String?
    @State private var isShowingScanner = false
    @State private var qrCodeImage: UIImage?

    var body: some View {
        VStack {
            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text("QRコードを生成できません")
                    .foregroundColor(.red)
                    .padding()
            }

            Button("QRコードをスキャン") {
                isShowingScanner = true
            }
            .padding()
            .sheet(isPresented: $isShowingScanner) {
                QRCodeScannerView { result in
                    sendToToken = result
                }
            }
            if let token = sendToToken {
                Text("送信先デバイストークン: \(token)")
                    .padding()
            } else {
                Text("送信先デバイストークンが設定されていません")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            if let token = appDelegate.deviceTokenString {
                generateQRCode(from: token)
            }
        }
    }

    func generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                qrCodeImage = UIImage(cgImage: cgImage)
            }
        }
    }
}
*/

import SwiftUI
import CoreImage.CIFilterBuiltins

struct SettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Binding var sendToToken: String?
    @State private var isShowingScanner = false
    @State private var qrCodeImage: UIImage?

    var body: some View {
        VStack {

            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text("QRコードを生成できません")
                    .foregroundColor(.red)
                    .padding()
            }

            Button("QRコードをスキャン") {
                isShowingScanner = true
            }
            .padding()
            .sheet(isPresented: $isShowingScanner) {
                QRCodeScannerView { result in
                    sendToToken = result
                }
            }
            if let token = sendToToken, !token.isEmpty {
                Text("送信先デバイストークン: \(token)")
                    .padding()
            } else {
                Text("送信先デバイストークンが設定されていません")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            if let token = appDelegate.deviceTokenString {
                generateQRCode(from: token)
            }
        }
    }

    func generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                qrCodeImage = UIImage(cgImage: cgImage)
            }
        }
    }
}
