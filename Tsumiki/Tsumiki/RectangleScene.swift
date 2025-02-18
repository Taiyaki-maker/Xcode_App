import SpriteKit

class RectangleScene: SKScene {
    var isTracking = false
    var rectangleHeight: CGFloat = 0
    var rectangleNode: SKShapeNode?
    var timer: Timer?

    override func didMove(to view: SKView) {
        print("Scene did move to view")
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = .white
    }

    func startTracking() {
        print("Start tracking")
        isTracking = true
        rectangleHeight = 0
        rectangleNode?.removeFromParent()
        rectangleNode = SKShapeNode(rectOf: CGSize(width: 100, height: rectangleHeight))
        rectangleNode?.fillColor = .blue
        rectangleNode?.position = CGPoint(x: frame.midX, y: frame.height - rectangleHeight / 2)
        if let rectangleNode = rectangleNode {
            addChild(rectangleNode)
        }
        startTimer()
    }

    func stopTracking() {
        print("Stop tracking")
        isTracking = false
        stopTimer()
        let finalHeight = rectangleHeight
        let finalRectangleNode = SKShapeNode(rectOf: CGSize(width: 100, height: finalHeight))
        finalRectangleNode.fillColor = .blue
        finalRectangleNode.position = CGPoint(x: frame.midX, y: frame.height - finalHeight / 2)
        finalRectangleNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: finalHeight))
        finalRectangleNode.physicsBody?.isDynamic = true
        finalRectangleNode.physicsBody?.restitution = 0.2
        addChild(finalRectangleNode)
        rectangleNode?.removeFromParent()
    }

    internal func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.isTracking {
                print("Increasing rectangle height: \(self.rectangleHeight)")
                self.rectangleHeight += 1
                self.rectangleNode?.path = CGPath(rect: CGRect(x: -50, y: -self.rectangleHeight / 2, width: 100, height: self.rectangleHeight), transform: nil)
                self.rectangleNode?.position = CGPoint(x: self.frame.midX, y: self.frame.height - self.rectangleHeight / 2)
            }
        }
    }

    internal func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
