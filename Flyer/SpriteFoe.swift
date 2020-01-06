//
//  SpriteFoe.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import SpriteKit

class SpriteFoe: Foe {
    let sprite: FoldingSprite
    
    init( scene: SKScene, sprite: FoldingSprite ) {
        self.sprite = sprite
        super.init(bounds: scene.size)
    }

    override func hitsPlayer( target: CGPoint ) -> Bool {
        return sprite.foldedPosition().smallestSquareDistance(target: target) < 15*15
    }
    
    override func hide( currentTime: TimeInterval ) {
        self.sprite.hide()
        self.velocity = nil
    }
    
    override func fade( currentTime: TimeInterval ) {
        self.sprite.run(SKAction.fadeOut(withDuration:0.25))
    }
}
