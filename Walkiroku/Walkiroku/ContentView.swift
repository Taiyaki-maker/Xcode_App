import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 800)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 400, height: 800)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
