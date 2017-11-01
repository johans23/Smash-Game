//
//  GameViewController.swift
//  Smash Game
//
//  Created by Sajan Thomas on 12/4/14.
//  Copyright (c) 2014 Jojo Inc. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            var sceneData = Data.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
   
    @IBOutlet weak var gameTitle: UILabel!

    @IBAction func startGameButton(_ sender: UIButton) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let skView = self.view as! SKView
        
        if skView.scene == nil{
            
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            let gameScene = GameScene(size: skView.bounds.size)
            gameScene.scaleMode = .aspectFill
            
            skView.presentScene(gameScene)
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

   // override func supportedInterfaceOrientations() -> Int {
     //   if UIDevice.current.userInterfaceIdiom == .phone {
      //      return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
    //    } else {
     //       return Int(UIInterfaceOrientationMask.All.toRaw())
   //     }
   // }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}
