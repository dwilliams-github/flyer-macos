//
//  Score.swift
//  Flyer
//
//  Created by David Williams on 11/30/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 Keeps track of the current game score
 
 Includes a label and sound to indicate the current
 score state.
 */
@MainActor
class Score: NSObject {
    private var label: SKLabelNode?
    private var tada: SKAudioNode
    private(set) var currentValue: Int
    private(set) var bonus: Int
    private(set) var bonusThreshold: Int
    
    /**
     Constructor
     - Parameter scene: The main game scene
     - Parameter bonusThreshold: The interval at which a bonus is awarded
     */
    init( scene: SKScene, bonusThreshold: Int ) {
        self.currentValue = 0
        self.bonus = 0
        self.bonusThreshold = bonusThreshold
        
        //
        // It's a little corny, but maybe we can indicate using
        // sound if a new player life is rewarded
        //
        self.tada = SKAudioNode(fileNamed: "newlife.m4a")
        self.tada.autoplayLooped = false
        self.tada.run(SKAction.changeVolume( to: 0.1 * GameSettings.standard.volume, duration: 0 ))
        scene.addChild(self.tada)
        
        //
        // Get label from scene configuration
        //
        self.label = scene.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let label = self.label {
            label.text = "0000"
            label.alpha = 0.0
            label.run(SKAction.fadeAlpha(to: 0.6, duration: 2.0))
        }
    }
    
    private func updateLabel() {
        if let label = self.label {
            label.text = String(format:"%4.4d", currentValue)
            label.alpha = 1.0
            label.run(SKAction.fadeAlpha(to: 0.6, duration: 0.25))
        }
    }
    
    /**
     Increment current score by given amount
     - Parameter amount: Amount to increase score
     - Returns: true if a bonus is to be rewarded
     
     The game display and bonus award sound are automatically updated.
     */
    func increment( amount: Int ) -> Bool {
        let lastBonus = bonus
        currentValue += amount
        bonus = currentValue / bonusThreshold

        updateLabel()
        
        let answer = bonus > lastBonus
        if answer {
            self.tada.run(SKAction.play())
        }
        
        return answer
    }
}
