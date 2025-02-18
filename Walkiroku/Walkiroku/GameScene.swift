import SpriteKit

class GameScene: SKScene {
    var character: SKSpriteNode!
    var walkFrames: [SKTexture] = []
    
    override func didMove(to view: SKView) {
        // スプライトシートからアニメーションフレームをロード
        let texture = SKTexture(imageNamed: "Alien") // スプライトシートの名前に変更してください
        let frameWidth = texture.size().width / 6
        let frameHeight = texture.size().height
        
        for i in 0..<6 {
            let frameRect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: frameHeight)
            let frameTexture = SKTexture(rect: frameRect, in: texture)
            walkFrames.append(frameTexture)
        }
        
        // キャラクタースプライトを初期化
        let firstFrameTexture = walkFrames[0]
        character = SKSpriteNode(texture: firstFrameTexture)
        character.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(character)
        
        // キャラクターを歩かせるアニメーションを実行
        walkCharacter()
    }
    
    func walkCharacter() {
        // 歩行アニメーションのアクションを作成
        let walkAction = SKAction.animate(with: walkFrames, timePerFrame: 0.1)
        character.run(SKAction.repeatForever(walkAction))
    }
}
