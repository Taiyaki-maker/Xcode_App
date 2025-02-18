import SwiftUI
import QRCodeReader
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, QRCodeReaderViewControllerDelegate {
        var parent: QRCodeScannerView

        init(parent: QRCodeScannerView) {
            self.parent = parent
        }

        func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
            parent.didFindCode(result.value)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func readerDidCancel(_ reader: QRCodeReaderViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    var didFindCode: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> QRCodeReaderViewController {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton = true
            $0.showOverlayView = true
        }

        let viewController = QRCodeReaderViewController(builder: builder)
        viewController.delegate = context.coordinator

        return viewController
    }

    func updateUIViewController(_ uiViewController: QRCodeReaderViewController, context: Context) {}
}
