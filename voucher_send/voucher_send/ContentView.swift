import SwiftUI
#if os(iOS)
import Speech
import AVFoundation
#endif

struct ContentView: View {
    @StateObject private var speechRecognitionManager = SpeechRecognitionManager()
    @State private var wordList: [String] = []

    var body: some View {
        VStack {
            List(wordList, id: \.self) { word in
                Text(word)
            }
            .padding()

            Button("Start Recording") {
                speechRecognitionManager.startRecording { words in
                    self.wordList.insert(contentsOf: words, at: 0)
                }
            }
            .padding()
        }
        .onAppear {
            speechRecognitionManager.startRecording { words in
                self.wordList.insert(contentsOf: words, at: 0)
            }
        }
        .padding()
    }
}

class SpeechRecognitionManager: NSObject, ObservableObject {
    #if os(iOS)
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var timer: Timer?
    private let silenceTimeout: TimeInterval = 0.5 // 空白時間を0.5秒に設定
    private var isCollectingWords = false
    private var collectedWords: [String] = []
    private var newWords: [String] = []
    #endif
    
    func startRecording(completion: @escaping ([String]) -> Void) {
        #if os(iOS)
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session properties weren't set because of an error.")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        let inputNode = audioEngine.inputNode
        let recognitionFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recognitionFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start because of an error.")
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                self.handleSpokenText(spokenText, completion: completion)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil

                // Restart recording
                self.startRecording(completion: completion)
            }
        }
        #else
        print("Speech recognition is not supported on this platform.")
        completion([])
        #endif
    }
    
    private func handleSpokenText(_ text: String, completion: @escaping ([String]) -> Void) {
        #if os(iOS)
        if let range = text.range(of: "お願いします") {
            let substring = text[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
            let words = substring.split(separator: " ").map { String($0) }
            
            if !words.isEmpty {
                newWords = words
                resetTimer(completion: completion)
            }
        }
        #endif
    }
    
    private func resetTimer(completion: @escaping ([String]) -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.newWords.isEmpty {
                completion(self.newWords)
                self.newWords.removeAll()
            }
        }
    }
}
