import SwiftUI

struct AddEditAlarmView: View {
    @Binding var alarm: CustomAlarm
    var onSave: (CustomAlarm) -> Void
    @State private var showingBarcodeScanner = false
    @State private var soundFiles: [String] = []
    @State private var selectedSound: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                DatePicker("時間", selection: $alarm.time, displayedComponents: .hourAndMinute)
                TextField("ラベル", text: $alarm.label)
                HStack {
                    Text("バーコード: \(alarm.barcode ?? "未設定")")
                    Spacer()
                    Button("スキャン") {
                        showingBarcodeScanner = true
                    }
                }
                Picker("Sound", selection: $selectedSound) {
                    ForEach(soundFiles, id: \.self) { sound in
                        Text(sound).tag(sound as String?)
                    }
                }
                .onAppear {
                    loadSoundFiles()
                    selectedSound = alarm.soundName ?? soundFiles.first
                }
                .onChange(of: selectedSound) { newValue in
                    alarm.soundName = newValue
                }
                .sheet(isPresented: $showingBarcodeScanner) {
                    BarcodeScannerViewControllerRepresentable { code in
                        alarm.barcode = code
                        showingBarcodeScanner = false
                    }
                
                }
            }
        }
        .navigationBarTitle("アラームを編集", displayMode: .inline)
        .navigationBarItems(leading: Button("キャンセル") {
            presentationMode.wrappedValue.dismiss()  // 画面を閉じる
        }, trailing: Button("保存") {
            print(alarm)
            onSave(alarm)
            presentationMode.wrappedValue.dismiss()  // 保存後に画面を閉じる
        })
    }
    
    private func loadSoundFiles() {
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                do {
                    let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
                    soundFiles = files.filter { $0.hasSuffix(".mp3") }
                    if soundFiles.isEmpty {
                        soundFiles.append("alarm_sound.mp3") // デフォルトのサウンドファイル名を追加
                    }
                    print("サウンドファイルが読み込まれました: \(soundFiles)")
                } catch {
                    print("Error loading sound files: \(error.localizedDescription)")
                }
            }
        }
}
