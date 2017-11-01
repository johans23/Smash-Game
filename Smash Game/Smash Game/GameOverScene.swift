//
//  GameOverScene.swift
//  Smash Game
//
//  Created by Sajan Thomas on 12/26/14.
//  Copyright (c) 2014 Jojo Inc. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
 
    init(size: CGSize, playerWon:Bool){
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
        gameOverLabel.fontSize = 46
        gameOverLabel.position = CGPoint(dictionaryRepresentation: (self.frame.midX, self.frame.midY) as! CFDictionary)!
        
        if playerWon {
            gameOverLabel.text = "YOU WON!"
        }else{
            gameOverLabel.text = "GAME OVER!"
        }
      
        self.addChild(gameOverLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let breakoutGameScene = GameScene(size: self.size)
        self.view?.presentScene(breakoutGameScene)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
