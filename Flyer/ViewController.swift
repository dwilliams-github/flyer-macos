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

class ViewController: NSViewController, GameSceneDelegate, IntroSceneDelegate {

    @IBOutlet var skView: SKView!
    @IBOutlet var gameOverView: NSView!
    @IBOutlet var scoreTable: NSTableView!
    
    private var topScores: TopScores?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topScores = TopScores(table: scoreTable)

        if let view = self.skView {
            //
            // Bring up introductory scene
            //
            if let scene = IntroScene(fileNamed: "IntroScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Watch
                scene.gameDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func beginGame() {
        if let view = self.skView {
            //
            // Bring up the game!
            //
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Watch
                scene.gameDelegate = self
                
                // Fade in
                let transition = SKTransition.fade(with: scene.backgroundColor, duration: 1)
                
                // Present the scene
                view.presentScene(scene, transition: transition)
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "getInitials" {
            if let modal = segue.destinationController as? SaveScore, let score = sender as? Int {
                modal.topScores = self.topScores
                modal.score = score
            }
        }
    }
    
    func newGame() {
        if let gameOverView = self.gameOverView {
            //
            // Fade out the GameOver view.
            // Note that this runs on top of a scene transition
            // (invoked by "beginGame").
            //
            NSAnimationContext.runAnimationGroup({(context) -> Void in
                context.duration = 1
                gameOverView.animator().alphaValue = 0
            },completionHandler: {() -> Void in
                gameOverView.isHidden = true
            })
        }
        
        beginGame()
    }
    
    func gameOver( score: Int ) {
        //
        // Check top scores
        //
        if self.topScores?.scoreInTopFive(score: score) ?? false {
            performSegue(withIdentifier: "getInitials", sender: score)
        }
        
        //
        // Rather than change scenes, overlay a title view.
        // This way, the existing game (without a player) continues to
        // run underneath, and we can use ordinary input controls
        //
        if let gameOverView = self.gameOverView {
            gameOverView.alphaValue = 1
            gameOverView.isHidden = false
        }
    }
    
    func fetchInitials() {
        
    }
    
}

