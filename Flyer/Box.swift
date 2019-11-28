//
//  Box.swift
//  
//
//  Created by David Williams on 11/28/19.
//

import SpriteKit

class Box: RamFoe {
    init( scene: SKScene ) {
        //
        // Create base image
        //
        let baseSprite = SKSpriteNode(texture: SKTexture(imageNamed: "Square"))
        baseSprite.scale(to: CGSize(width: 18, height: 18))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //
        // Run animation, after random delay (so that not all copies
        // on the scene will be in sync)
        //
        baseSprite.run(
            SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval.random(in:0...1)),
                SKAction.repeatForever(
                    SKAction.rotate( byAngle: CGFloat.pi, duration: 0.5 )
                )
            ])
        )
        
        super.init(
            scene: scene,
            sprite: FoldingSprite( scene: scene, sprite: baseSprite ),
            speed: 40,
            turn_speed: 1
        )
    }
}
