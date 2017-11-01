//
//  GameScene.swift
//  Smash Game
//
//  Created by Sajan Thomas on 12/4/14.
//  Copyright (c) 2014 Jojo Inc. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fingerIsOnPaddle = false
    
    // Game Node Category Names
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    // AV Audio Player
    
    let backgroundMusicPlayer = AVAudioPlayer()
    
    // Game Node Category BitMasks
    
    let ballCategory:UInt32 = 0x1 << 0          // 000000001
    let bottomCategory: UInt32 = 0x1 << 1       // 000000010
    let brickCategory: UInt32 = 0x1 << 2        // 000000100
    let paddleCategory: UInt32 = 0x1 << 3       // 000001000
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.physicsWorld.contactDelegate = self
        
        // Background Music(Player)
        
        let backgroundMusicURL = Bundle.main.url(forResource: "Game Background Music", withExtension: "mp3")
        
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL, error: nil)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        
        // Game Background (with physicsBody)
        
        let backgroundImage = SKSpriteNode(imageNamed: "Background")
        backgroundImage.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.addChild(backgroundImage)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let worldBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        // Ball (with physicsBody)
        
        let ball = SKSpriteNode(imageNamed: "Ball")
        ball.name = ballCategoryName
        ball.position = CGPoint(x: self.frame.size.width / 3.75, y: self.frame.size.height / 3.5)
        self.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.applyImpulse(CGVector(dx: 2.25, dy: -1.25))
        
        
        // Paddle (with physicsBody)
        
        let paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.name = paddleCategoryName
        paddle.position = CGPoint(x: self.frame.midX, y: paddle.frame.size.height * 2)
        
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.isDynamic = false
        
        //Bottom (with physicsBody)
        
        let bottomRect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        
        self.addChild(bottom)
        
        // Assigning BitMasks to physicsBodies of Game Node Categories
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory
        
        // Brick Layout and Positioning in Game (with physicsBody)
        
        let numberofRows = 3
        let numberofBricks = 6
        let brickWidth = SKSpriteNode(imageNamed: "Brick").size.width
        let padding:Float = 30
        
        
        let offset:Float = (Float(self.frame.size.width) - (Float(brickWidth) * Float(numberofBricks) + padding * (Float(numberofBricks) - 1) ) ) / 2
        
        for index in 1 ... numberofRows {
            
            var yOffset: CGFloat{
                switch index {
                case 1:
                    return self.frame.size.height * 0.8
                case 2:
                    return self.frame.size.height * 0.6
                case 3:
                    return self.frame.size.height * 0.4
                    
                default:
                    return 0
                    }
            }
            
            for index in 1 ... numberofBricks {
                let brick = SKSpriteNode(imageNamed: "brick")
                let calc1:Float = Float(index) - 0.5
                let calc2:Float = Float(index) - 1
                brick.position = CGPoint(x: CGFloat(calc1 * Float(brick.frame.size.width) + calc2 * padding + offset), y: yOffset)
                
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.frame.size)
                brick.physicsBody?.allowsRotation = false
                brick.physicsBody?.friction = 0
                brick.name = brickCategoryName
                brick.physicsBody?.categoryBitMask = brickCategory
                
                self.addChild(brick)
                
                
            }
        }
        
    }
    
    // Paddle Touched Function(with physicsBody)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.anyObject() as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        if body?.node?.name == paddleCategoryName {
            //println("Paddle touched")
            fingerIsOnPaddle = true
        }
    }
    
    // Moving Paddle(When Touched) Function
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if fingerIsOnPaddle {
            let touch = touches.anyObject() as! UITouch
            let touchLocation = touch.locationInNode(self)
            let prevTouchLocation = touch.previousLocationInNode(self)
            
            let paddle = self.childNode(withName: paddleCategoryName) as! SKSpriteNode
            
            var newXPos = paddle.position.x + (touchLocation.x - prevTouchLocation.x)
            
            newXPos = max(newXPos, paddle.size.width / 2)
            newXPos = min(newXPos, self.size.width - paddle.size.width / 2)

            
            paddle.position = CGPoint(x: newXPos, y: paddle.position.y)
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        let ball = self.childNode(withName: ballCategoryName) as! SKSpriteNode!
        
        let minSpeed: CGFloat = 500.0
        let speed = sqrt((ball?.physicsBody!.velocity.dx)! * ball?.physicsBody!.velocity.dx + (ball?.physicsBody!.velocity.dy)! * ball?.physicsBody!.velocity.dy)
        
        if speed > minSpeed {
            ball?.physicsBody!.linearDamping = 5.0
        }
        else {
            ball?.physicsBody!.linearDamping = -0.1
        }
    }
    
    // Paddle Touched End Function
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerIsOnPaddle = false
    }
    
    // didBeginContact Function(with physicsBody)
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Ball and Bottom Contact If Statement
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory{
            let gameOverScene = GameOverScene(size: self.frame.size, playerWon:false)
            self.view?.presentScene(gameOverScene)
        }
        
        // Ball and Brick Contact If Statement
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory{
            secondBody.node?.removeFromParent()
            
            if isGameWon(){
                let youWinScene = GameOverScene(size: self.frame.size, playerWon: true)
                self.view?.presentScene(youWinScene)
            }
            
        }
        
    }
    
    func isGameWon() ->Bool{
        var numberofBricks = 0
        
        for nodeObject in self.children{
            let node = nodeObject as SKNode
            if node.name == brickCategoryName {
                numberofBricks += 1
            }
        }
        
        return numberofBricks <= 0
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
