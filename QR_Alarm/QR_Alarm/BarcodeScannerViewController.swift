/*
import SwiftUI
import UIKit
import AVFoundation

// BarcodeScannerViewControllerの定義
class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView!
    var cornerLength: CGFloat = 20.0 // 四隅の長さ
    var onScan: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Setup white corners
        setupCorners()

        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }

        captureSession.startRunning()
    }

    func setupCorners() {
        let rectSize = CGSize(width: view.frame.width * 0.6, height: view.frame.height * 0.3)
        let rectOrigin = CGPoint(x: (view.frame.width - rectSize.width) / 2, y: (view.frame.height - rectSize.height) / 2)
        let cornerFrame = CGRect(origin: rectOrigin, size: rectSize)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.minY + cornerLength))
        path.addLine(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.minY))
        path.addLine(to: CGPoint(x: cornerFrame.minX + cornerLength, y: cornerFrame.minY))
        
        path.move(to: CGPoint(x: cornerFrame.maxX - cornerLength, y: cornerFrame.minY))
        path.addLine(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.minY))
        path.addLine(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.minY + cornerLength))
        
        path.move(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.maxY - cornerLength))
        path.addLine(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.maxY))
        path.addLine(to: CGPoint(x: cornerFrame.maxX - cornerLength, y: cornerFrame.maxY))
        
        path.move(to: CGPoint(x: cornerFrame.minX + cornerLength, y: cornerFrame.maxY))
        path.addLine(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.maxY))
        path.addLine(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.maxY - cornerLength))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clear.cgColor

        view.layer.addSublayer(shapeLayer)
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)

            // QRコードの枠を更新
            let barCodeObject = previewLayer.transformedMetadataObject(for: readableObject)
            qrCodeFrameView?.frame = barCodeObject!.bounds
        }
    }

    func found(code: String) {
        print("Readable object found with string value: \(code)")
        onScan?(code) // onScanクロージャを呼び出す
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// SwiftUIで使えるようにUIViewControllerRepresentableを実装
struct BarcodeScannerViewControllerRepresentable: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.onScan = onScan
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // 特に更新は必要ありません
    }
}

*/

import SwiftUI
import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView!
    var cornerLength: CGFloat = 20.0
    var onScan: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        setupCorners()

        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }

        captureSession.startRunning()
    }

    func setupCorners() {
        let rectSize = CGSize(width: view.frame.width * 0.6, height: view.frame.height * 0.3)
        let rectOrigin = CGPoint(x: (view.frame.width - rectSize.width) / 2, y: (view.frame.height - rectSize.height) / 2)
        let cornerFrame = CGRect(origin: rectOrigin, size: rectSize)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.minY + cornerLength))
        path.addLine(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.minY))
        path.addLine(to: CGPoint(x: cornerFrame.minX + cornerLength, y: cornerFrame.minY))
        
        path.move(to: CGPoint(x: cornerFrame.maxX - cornerLength, y: cornerFrame.minY))
        path.addLine(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.minY))
        path.addLine(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.minY + cornerLength))
        
        path.move(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.maxY - cornerLength))
        path.addLine(to: CGPoint(x: cornerFrame.maxX, y: cornerFrame.maxY))
        path.addLine(to: CGPoint(x: cornerFrame.maxX - cornerLength, y: cornerFrame.maxY))
        
        path.move(to: CGPoint(x: cornerFrame.minX + cornerLength, y: cornerFrame.maxY))
        path.addLine(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.maxY))
        path.addLine(to: CGPoint(x: cornerFrame.minX, y: cornerFrame.maxY - cornerLength))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clear.cgColor

        view.layer.addSublayer(shapeLayer)
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)

            let barCodeObject = previewLayer.transformedMetadataObject(for: readableObject)
            qrCodeFrameView?.frame = barCodeObject!.bounds
        }
    }

    func found(code: String) {
        print("Readable object found with string value: \(code)")
        onScan?(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct BarcodeScannerViewControllerRepresentable: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.onScan = onScan
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
    }
}

