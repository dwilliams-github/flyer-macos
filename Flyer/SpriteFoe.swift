//
//  SpriteFoe.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import SpriteKit

/**
 A foe that is represented by a single sprite
 */
class SpriteFoe: Foe {
    let sprite: FoldingSprite
    
    /**
     Constructor
     - Parameter scene: The parent scene
     - Parameter sprite: The folding sprite
     */
    init( scene: SKScene, sprite: FoldingSprite ) {
        self.sprite = sprite
        super.init(bounds: scene.size)
    }

    /**
     Decide if a player is hit
     - Parameter target: Player target position
     - Note: It is assumed that the foe must directly intersect the player
     */
    override func hitsPlayer( target: CGPoint ) -> Bool {
        return sprite.foldedPosition().smallestSquareDistance(target: target) < 15*15
    }
    
    /**
     Prepare for respawning
     */
    override func reset() {
        self.sprite.hide()
        super.reset()
    }
    
    /**
     Begin fading
     
     For a sprite based foe, this means fading the sprite.
     */
    override func beginFading( currentTime: TimeInterval ) {
        self.sprite.run(SKAction.fadeOut(withDuration:0.25))
    }
}
