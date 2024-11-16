//
//  MiniBoss.swift
//  Flyer
//
//  Created by David Williams on 11/8/24.
//  Copyright © 2024 David Williams. All rights reserved.
//
import SpriteKit

/**
 Mini boss that fires missles
 */
class MiniBoss: FiringFoe {
    init( scene: SKScene ) {
        //
        // Fetch animation frames
        //
        let atlas = SKTextureAtlas(named: "Sprites")
        let frames: [SKTexture] = (0..<8).map({i in atlas.textureNamed(String(format:"MiniBoss%03d", arguments:[i]))})

        //
        // Create base image
        //
        let baseSprite = SKSpriteNode(texture: frames[0])
        baseSprite.scale(to: CGSize(width: 42, height: 42))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        //
        // Run animation, after random delay (so that not all copies
        // on the scene will be in sync)
        //
        baseSprite.run(
            SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval.random(in:0...1)),
                SKAction.repeatForever(
                    SKAction.animate( with: frames, timePerFrame: 0.08 )
                )
            ])
        )

        super.init(
            scene: scene,
            sprite: FoldingSprite( scene: scene, sprite: baseSprite ),
            speed: 400,
            range: 250,
            rate: 1.0
        )
    }
    
    override func value( difficulty: Difficulty ) -> Int? {
        return difficulty.smartMineAward
    }
}
