import SwiftUI

struct InformationView: View {
    var body: some View {
        VStack {
            Text("説明")
                .font(.largeTitle)
                .padding()
            Text("好きな人といつでも気持ちを伝えられる！ぼたんち。右上で接続設定をしてくださいね")
                .padding()
            Spacer()
        }
        .navigationBarTitle("Information", displayMode: .inline)
    }
}
