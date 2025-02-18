import SwiftUI

struct HeartView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .frame(width: 70, height: 70)
            .foregroundColor(.red)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 5)) {
                    self.scale = 1.5
                    self.opacity = 0.0
                }
            }
    }
}
