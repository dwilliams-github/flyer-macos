//
//  ViewController.swift
//  Flyer
//
//  Created by David Williams on 10/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController, GameSceneWatcher {

    @IBOutlet var skView: SKView!
    @IBOutlet weak var gameOverView: NSView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Watch
                scene.watcher = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func gameOver( score: Int ) {
        print("Game over...")
        if let gameOverView = self.gameOverView {
            gameOverView.isHidden = false
        }
    }
    
}

