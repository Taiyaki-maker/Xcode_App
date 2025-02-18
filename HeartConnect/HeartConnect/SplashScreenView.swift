import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var fadeOut = false

    var body: some View {
        VStack {
            if isActive {
                ContentView() // メインのコンテンツビュー
            } else {
                Image(uiImage: UIImage(named: "firock.png")!) // ここに表示するロゴの画像名を入力
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
                    .opacity(fadeOut ? 0 : 1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 1)) {
                                self.fadeOut = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isActive = true
                            }
                        }
                    }
            }
        }
    }
}
