//
//  IntroScene.swift
//  Flyer
//
//  Created by David Williams on 12/26/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit
import GameplayKit


/**
 Introductory scene delegate
 
 This protocol allows high level game assets (i.e. view controller) to
 recieve important events controlled by the introduction scene.
 */
protocol IntroSceneDelegate {
    func beginGame();
}

/**
 Introduction scene
 
 A SpriteKit scene is used because it is so convenient to design them
 in the Xcode scene editor. Note that this class name is specified in
 the Xcode scene editor which allows Xcode to insert all the necessary
 details automatically.
 */
class IntroScene: SKScene {
    var gameDelegate: IntroSceneDelegate?
    
    /**
     React to key down event
     
     We need some method to tell someone else (i.e. view controller) that
     it is time to start the game.
     */
    override func keyDown(with event: NSEvent) {
        if let gameDelegate = self.gameDelegate {
            gameDelegate.beginGame()
        }
    }
}
