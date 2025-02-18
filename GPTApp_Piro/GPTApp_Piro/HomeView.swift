import SwiftUI

struct HomeView: View {
    let fallacies = [
        ("藁人形論法", "figure.walk"),
        ("アド・ホミネム", "person"),
        ("滑りやすい坂論法", "triangle"),
        ("偽りの二択", "divide"),
        ("循環論法", "arrow.triangle.2.circlepath"),
        ("レッド・ヘリング", "fish"),
        ("アピール・トゥ・アーソリティ", "crown"),
        ("アピール・トゥ・イグノランス", "questionmark.circle"),
        ("バンワゴン効果", "person.3"),
        ("アピール・トゥ・エモーション", "heart"),
        ("アポストレオリ", "exclamationmark.bubble"),
        ("相対論法", "arrow.2.squarepath")
    ]

    var body: some View {
        NavigationView {
            VStack {
                Text("詭弁対策")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], spacing: 20) {
                        ForEach(0..<fallacies.count, id: \.self) { index in
                            NavigationLink(destination: FallacyDetailView(fallacyIndex: index, fallacyName: fallacies[index].0)) {
                                VStack {
                                    Image(systemName: fallacies[index].1)
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text(fallacies[index].0)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.blue)
                                .cornerRadius(20)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
