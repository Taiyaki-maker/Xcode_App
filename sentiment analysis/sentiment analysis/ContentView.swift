//
//  ContentView.swift
//  sentiment analysis
//
//  Created by ごんざれす on 2024/05/28.
//

import SwiftUI
import AVFoundation
import TensorFlowLite
import TensorFlowLiteTaskVision

struct ContentView: View {
    var body: some View {
        CameraView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No updates needed
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var emotionRecognitionModel: EmotionRecognitionModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        emotionRecognitionModel = EmotionRecognitionModel(modelName: "your_model_name")
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            session.addInput(input)
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        session.addOutput(videoOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            if let predictions = self.emotionRecognitionModel?.runModel(on: pixelBuffer) {
                DispatchQueue.main.async {
                    // 結果の処理
                    print("Predictions: \(predictions)")
                }
            }
        }
    }
}

class EmotionRecognitionModel {
    private var interpreter: Interpreter

    init?(modelName: String) {
        guard let modelPath = Bundle.main.path(forResource: modelName, ofType: "tflite") else {
            print("Failed to load model file.")
            return nil
        }
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch {
            print("Failed to create interpreter: \(error)")
            return nil
        }
    }

    func runModel(on pixelBuffer: CVPixelBuffer) -> [Float]? {
        guard let inputTensor = try? interpreter.input(at: 0) else { return nil }
        // Convert the pixel buffer to the appropriate tensor format
        // (details depend on your specific model's requirements)
        // ...

        do {
            try interpreter.invoke()
            let outputTensor = try interpreter.output(at: 0)
            return outputTensor.data.toArray(type: Float.self)
        } catch {
            print("Failed to invoke interpreter: \(error)")
            return nil
        }
    }
}

extension Data {
    func toArray<T>(type: T.Type) -> [T] {
        return withUnsafeBytes { Array(UnsafeBufferPointer<T>(start: $0.bindMemory(to: T.self).baseAddress!, count: self.count / MemoryLayout<T>.stride)) }
    }
}

