//
//  Score.swift
//  Flyer
//
//  Created by David Williams on 11/30/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit

class Score: NSObject {
    private var label : SKLabelNode?
    private var currentValue : Int
    
    init( scene: SKScene ) {
        currentValue = 0
        
        //
        // Get label from scene configuration
        //
        self.label = scene.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let label = self.label {
            label.text = "000000"
            label.alpha = 0.0
            label.run(SKAction.fadeAlpha(to: 0.6, duration: 2.0))
        }
    }
    
    private func updateLabel() {
        if let label = self.label {
            label.text = String(format:"%4.4d", currentValue)
        }
    }
    
    
    func increment( amount: Int ) {
        currentValue += amount
        updateLabel()
    }
}
