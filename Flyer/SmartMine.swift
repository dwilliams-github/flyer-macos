//
//  SmartMine.swift
//  Flyer
//
//  Created by David Williams on 11/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 A more aggressive version of a blocking type foe
 */
class SmartMine: BlockFoe {
    
    init( scene: SKScene ) {
        //
        // Our smart mine is animated, but not in sequence
        // Pull up the frames and arrange manually.
        //
        let atlas = SKTextureAtlas(named: "Sprites")
        var frames: [SKTexture] = []
        for i in 0...3 {
            frames.append(atlas.textureNamed(String(format:"SmartMine%03d", arguments:[i])))
        }
        frames.append(frames[3])
        frames.append(frames[3])
        frames.append(frames[3])
        frames.append(frames[2])
        frames.append(frames[1])
        frames.append(frames[0])
        frames.append(frames[0])
        frames.append(frames[0])

        //
        // Create base image
        //
        let baseSprite = SKSpriteNode(texture: frames[0])
        baseSprite.scale(to: CGSize(width: 24, height: 24))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //
        // Run animation, after random delay (so that not all copies
        // on the scene will be in sync)
        //
        baseSprite.run(
            SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval.random(in:0...1)),
                SKAction.repeatForever(
                    SKAction.group([
                        SKAction.animate( with: frames, timePerFrame: 0.03 ),
                        SKAction.rotate( byAngle: CGFloat.pi, duration: 2 )
                    ])
                )
            ])
        )
        
        super.init(
            scene: scene,
            sprite: FoldingSprite( scene: scene, sprite: baseSprite ),
            baseThrust: 25
        )
    }
    
    override func value( difficulty: Difficulty ) -> Int? {
        return difficulty.smartMineAward
    }
}
