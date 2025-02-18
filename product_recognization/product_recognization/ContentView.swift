import SwiftUI
import AVFoundation
import Vision
import CoreML

struct ContentView: View {
    @StateObject private var cameraModel = CameraModel()

    var body: some View {
        ZStack {
            CameraPreview(cameraModel: cameraModel)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text(cameraModel.recognizedObject)
                    .font(.title)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .onAppear {
            cameraModel.startSession()
        }
    }
}

class CameraModel: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    @Published var recognizedObject: String = "Recognizing..."

    func startSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }

            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession?.canAddOutput(videoOutput!) == true {
                captureSession?.addOutput(videoOutput!)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill

            DispatchQueue.main.async {
                self.captureSession?.startRunning()
            }

        } catch {
            print("Error Unable to initialize back camera: \(error.localizedDescription)")
        }
    }

    func updatePreviewLayer(view: UIView) {
        if let previewLayer = previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }

            DispatchQueue.main.async {
                self.recognizedObject = "\(firstObservation.identifier) \(String(format: "%.2f", firstObservation.confidence * 100))%"
            }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraModel: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraModel.updatePreviewLayer(view: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        cameraModel.updatePreviewLayer(view: uiView)
    }
}

