//
//  Mine.swift
//  Flyer
//
//  Created by David Williams on 11/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 Basic type of foe with less reactive blocking-type behavior
 */
class Mine: BlockFoe {
    
    init( scene: SKScene ) {
        //
        // Our meanie is animated. Pull up the frames.
        //
        let atlas = SKTextureAtlas(named: "Sprites")
        var frames: [SKTexture] = []
        for i in 0..<2 {
            frames.append(atlas.textureNamed(String(format:"Mine%03d", arguments:[i])))
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
                    SKAction.animate( with: frames, timePerFrame: 0.25 )
                )
            ])
        )
        
        super.init(
            scene: scene,
            sprite: FoldingSprite( scene: scene, sprite: baseSprite ),
            baseThrust: 10
        )
    }
    
    override func value( difficulty: Difficulty ) -> Int? {
        return difficulty.mineAward
    }
}
