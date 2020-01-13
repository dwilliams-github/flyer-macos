//
//  Meanie.swift
//  Flyer
//
//  Created by David Williams on 11/22/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 The stronger version of a ramming type foe
 */
class Meanie: RamFoe {
    init( scene: SKScene ) {
        //
        // Our meanie is animated. Pull up the frames.
        //
        let atlas = SKTextureAtlas(named: "Sprites")
        var frames: [SKTexture] = []
        for i in 0..<16 {
            frames.append(atlas.textureNamed(String(format:"Meanie%03d", arguments:[i])))
        }

        //
        // Create base image
        //
        let baseSprite = SKSpriteNode(texture: frames[0])
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
                    SKAction.animate( with: frames, timePerFrame: 0.03 )
                )
            ])
        )
        
        super.init(
            scene: scene,
            sprite: FoldingSprite( scene: scene, sprite: baseSprite ),
            speed: 70,
            turn_speed: 2
        )
    }
    
    override func value( difficulty: Difficulty ) -> Int? {
        return difficulty.meanieAward
    }
}
