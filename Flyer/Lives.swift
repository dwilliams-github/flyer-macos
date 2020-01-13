//
//  Lives.swift
//  Flyer
//
//  Created by David Williams on 11/30/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 Store and present current number of player lives
 */
class Lives: NSObject {
    var markers : [SKSpriteNode] = []
    var value: Int

    /**
     Constructor
     - Parameter scene: The main game scene
     - Parameter startAt: Beginning number of lives
     - Parameter max: Maximum number of lives
     */
    init( scene: SKScene, startAt: Int, max: Int ) {
        value = startAt
        let coastTexture = SKTexture(imageNamed: "Player000")
        
        for i in 0..<max {
            let sprite = SKSpriteNode(texture: coastTexture)
            sprite.scale(to: CGSize(width: 20, height: 20))
            sprite.alpha = 0.5
            sprite.zPosition = -1
            sprite.position = CGPoint(
                x: CGFloat(20 + 30*i) - scene.size.width/2,
                y: scene.size.height/2 - CGFloat(20)
            )
            sprite.isHidden = i >= startAt
            scene.addChild(sprite)
            
            markers.append(sprite)
        }
    }
    
    /**
     Attempt to increment number of lives
     - Returns: True if successful
     
     It is not always possible to increment the number of lives because there
     is an explicit maximum.
     */
    @discardableResult func increment() -> Bool {
        if value < markers.count {
            markers[value].isHidden = false
            value += 1
            return true
        }
        return false
    }
    
    /**
     Decrement lives
     - Returns: The number of remaining lives
     */
    func decrement() -> Int {
        value -= 1
        markers[value].isHidden = true
        return value
    }
    
    /**
     Returns true if there any more lives remaining
     - Returns: True if there is still hope!
     */
    func anyLeft() -> Bool {
        return value > 0
    }
}
