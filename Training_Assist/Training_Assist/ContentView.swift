//
//  ContentView.swift
//  Training_Assist
//
//  Created by ごんざれす on 2025/08/13.
//

import SwiftUI
import UIKit

// MARK: - Models
struct RecognizedFood: Identifiable, Codable {
    let id = UUID()
    let name: String
    let calories: Double
    let servingDescription: String?
}

struct CalorieRecord: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let foods: [RecognizedFood]
}

// MARK: - Simple persistence with AppStorage
final class CalorieStore: ObservableObject {
    @AppStorage("calorie_records_v1") private var storedJSON: String = ""
    @Published var records: [CalorieRecord] = []

    init() {
        load()
    }

    func addRecord(_ record: CalorieRecord) {
        records.append(record)
        save()
    }

    private func load() {
        guard let data = storedJSON.data(using: .utf8), !storedJSON.isEmpty else { return }
        if let decoded = try? JSONDecoder().decode([CalorieRecord].self, from: data) {
            records = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(records), let json = String(data: data, encoding: .utf8) {
            storedJSON = json
        }
    }
}

// MARK: - FatSecret API client (image recognition)
struct FatSecretClient {
    // NOTE: ここに OAuth2 で取得したアクセストークンを設定してください。
    // 取得方法は FatSecret のドキュメント参照（Scopes: image-recognition）。
    // 開発中はテスト用のトークン文字列を入れてください。
    static var accessToken: String = "REPLACE_WITH_OAUTH2_ACCESS_TOKEN"

    struct Response: Decodable {
        let food_response: [FoodResponse]?
    }
    struct FoodResponse: Decodable {
        let food_entry_name: String?
        let eaten: Eaten?
        let suggested_serving: Serving?
        let food: FSFood?
    }
    struct Eaten: Decodable {
        let total_nutritional_content: TotalNutrition?
    }
    struct TotalNutrition: Decodable {
        let calories: String?
    }
    struct Serving: Decodable {
        let serving_description: String?
    }
    struct FSFood: Decodable {
        let food_name: String?
    }

    // Compress & resize to keep request payload small (avoid HTTP 413)
    private func base64JPEGUnderLimit(from image: UIImage, maxBytes: Int = 2_500_000) throws -> String {
        let targetLongSides: [CGFloat] = [1024, 900, 720, 640]
        let qualities: [CGFloat] = [0.8, 0.7, 0.6, 0.5, 0.4]

        for side in targetLongSides {
            guard let resized = image.resized(longSide: side) else { continue }
            for q in qualities {
                if let data = resized.jpegData(compressionQuality: q), data.count <= maxBytes {
                    return data.base64EncodedString()
                }
            }
        }
        // 最後の手段: 最小設定でも超える場合は一番小さいデータを返す
        let fallbackSide: CGFloat = 560
        let fallbackQuality: CGFloat = 0.35
        guard let resized = image.resized(longSide: fallbackSide),
              let data = resized.jpegData(compressionQuality: fallbackQuality) else {
            throw NSError(domain: "ImagePrep", code: -1, userInfo: [NSLocalizedDescriptionKey: "画像の圧縮に失敗しました"]);
        }
        return data.base64EncodedString()
    }

    // Simple resize keeping aspect ratio by longest side
    private func resizedDataInfo(_ image: UIImage) -> String {
        let size = image.size
        return "\(Int(size.width))x\(Int(size.height))"
    }

    func recognize(image: UIImage) async throws -> [RecognizedFood] {
        // Prepare smaller payload to avoid 413 (Payload Too Large)
        let b64 = try base64JPEGUnderLimit(from: image, maxBytes: 2_500_000)
        let url = URL(string: "https://platform.fatsecret.com/rest/image-recognition/v1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Self.accessToken)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = [
            "image_b64": b64,
            "region": "US",
            "language": "en",
            "include_food_data": true
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (respData, resp) = try await URLSession.shared.data(for: request)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
            if status == 413 {
                throw NSError(domain: "FatSecret", code: 413, userInfo: [NSLocalizedDescriptionKey: "APIエラー(413): 画像が大きすぎます。別の角度で撮る/余白を切る/再撮影して再試行してください。"])
            }
            throw NSError(domain: "FatSecret", code: status, userInfo: [NSLocalizedDescriptionKey: "APIエラー: \(status)"])
        }
        let decoded = try JSONDecoder().decode(Response.self, from: respData)
        let foods = (decoded.food_response ?? []).compactMap { item -> RecognizedFood? in
            let name = item.food?.food_name ?? item.food_entry_name ?? "(unknown)"
            let kcalStr = item.eaten?.total_nutritional_content?.calories ?? "0"
            let kcal = Double(kcalStr) ?? 0
            let serving = item.suggested_serving?.serving_description
            return RecognizedFood(name: name, calories: kcal, servingDescription: serving)
        }
        return foods
    }
}

private extension UIImage {
    func resized(longSide: CGFloat) -> UIImage? {
        let w = size.width, h = size.height
        guard w > 0 && h > 0 else { return nil }
        let scale = longSide / max(w, h)
        let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Camera wrapper for SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    enum Source { case camera, library }
    var source: Source = .camera
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = (source == .camera && UIImagePickerController.isSourceTypeAvailable(.camera)) ? .camera : .photoLibrary
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onImagePicked: onImagePicked) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        init(onImagePicked: @escaping (UIImage) -> Void) { self.onImagePicked = onImagePicked }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = (info[.originalImage] as? UIImage)
            if let image { onImagePicked(image) }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - UI
struct ContentView: View {
    @StateObject private var store = CalorieStore()

    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var pickedImage: UIImage?
    @State private var recognized: [RecognizedFood] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let image = pickedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ContentUnavailableView("写真を撮って分析", systemImage: "camera", description: Text("食事を撮影すると推定カロリーを表示します"))
                        .frame(maxHeight: 240)
                }

                if isLoading {
                    ProgressView("分析中…")
                }

                if !recognized.isEmpty {
                    List(recognized) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.body)
                                if let s = item.servingDescription { Text(s).foregroundStyle(.secondary).font(.caption) }
                            }
                            Spacer()
                            Text("\(Int(item.calories)) kcal")
                                .bold()
                        }
                    }
                    .frame(maxHeight: 260)

                    let total = Int(recognized.map { $0.calories }.reduce(0, +))
                    Text("合計: \(total) kcal")
                        .font(.title3.weight(.semibold))

                    Button {
                        let record = CalorieRecord(date: Date(), foods: recognized)
                        store.addRecord(record)
                        recognized.removeAll()
                        pickedImage = nil
                    } label: {
                        Label("この記録を保存", systemImage: "tray.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let msg = errorMessage {
                    Text(msg).foregroundStyle(.red).font(.footnote)
                }

                HStack {
                    Button { showCamera = true } label: {
                        Label("写真を撮る", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button { showLibrary = true } label: {
                        Label("写真を選ぶ", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("カロリー・スナップ")
            .toolbar {
                NavigationLink {
                    HistoryView(records: store.records)
                } label: {
                    Label("履歴", systemImage: "list.bullet")
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(source: .camera) { img in
                    pickedImage = img
                    analyze(img)
                }
            }
            .sheet(isPresented: $showLibrary) {
                ImagePicker(source: .library) { img in
                    pickedImage = img
                    analyze(img)
                }
            }
        }
    }

    private func analyze(_ image: UIImage) {
        errorMessage = nil
        recognized.removeAll()
        isLoading = true
        Task {
            do {
                let foods = try await FatSecretClient().recognize(image: image)
                await MainActor.run {
                    self.recognized = foods
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    if (error as NSError).code == 413 {
                        self.errorMessage = "画像サイズが大き過ぎる可能性があります。被写体を中央に寄せて余白を減らす・ズームを使わない・明るい場所で撮る（圧縮効率が上がる）などを試してください。\n詳細: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = "分析に失敗しました: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - History
struct HistoryView: View {
    let records: [CalorieRecord]
    var body: some View {
        List {
            ForEach(records.sorted(by: { $0.date > $1.date })) { rec in
                Section(header: Text(rec.date.formatted(date: .abbreviated, time: .shortened))) {
                    let total = Int(rec.foods.map { $0.calories }.reduce(0, +))
                    HStack {
                        Text("合計")
                        Spacer()
                        Text("\(total) kcal").bold()
                    }
                    ForEach(rec.foods) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(Int(item.calories)) kcal")
                        }
                    }
                }
            }
        }
        .navigationTitle("履歴")
    }
}

#Preview {
    ContentView()
}
