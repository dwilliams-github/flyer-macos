//
//  RockFoeSlot.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import SpriteKit

/**
 Allocation of a drifting foe
 
 All drifting foes have the same generic behavior (random
 constant motion) but the appearance is randomly selected at wakup.
 */
class RockFoeSlot: FoeSlot {
    private var rocks: [DriftFoe]

    override init( scene: SKScene, player: Player, delay: TimeInterval ) {

        //
        // Preallocate our rocks
        //
        let atlas = SKTextureAtlas(named: "Sprites")
        
        rocks = []
        for i in 0..<3 {
            let texture = atlas.textureNamed(String(format:"Rock%03d", arguments:[i]))
            let baseSprite = SKSpriteNode(texture: texture)
            baseSprite.scale(to: CGSize(width: 24, height: 24))
            baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            rocks.append(DriftFoe(
                scene: scene,
                sprite: FoldingSprite( scene: scene, sprite: baseSprite ),
                speed: 60,
                rotation: 0.4
            ))
        }

        super.init(scene: scene, player: player, delay: delay)
    }
    
    override func wakeUp() {
        active = rocks.randomElement()
        active!.spawn( start: wakeUpPoint(), direction: wakeUpDirection(), difficulty: settings.difficulty )
    }
}
