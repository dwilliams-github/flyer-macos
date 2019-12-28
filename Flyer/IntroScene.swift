//
//  IntroScene.swift
//  Flyer
//
//  Created by David Williams on 12/26/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit
import GameplayKit



protocol IntroSceneDelegate {
    func beginGame();
}


class IntroScene: SKScene {
    var gameDelegate: IntroSceneDelegate?
    
    override func keyDown(with event: NSEvent) {
        if let gameDelegate = self.gameDelegate {
            gameDelegate.beginGame()
        }
    }
}
