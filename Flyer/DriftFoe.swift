//
//  DriftFoe.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import SpriteKit

class DriftFoe: SpriteFoe {
    private var baseSpeed: CGFloat
    private var baseRotation: CGFloat

    init( scene: SKScene, sprite: FoldingSprite, speed: CGFloat, rotation: CGFloat ) {
        self.baseSpeed = speed
        self.baseRotation = rotation
        super.init(scene: scene, sprite: sprite)
    }
    
    //
    // Aproximate Gaussian
    //
    private func cheezyGaus() -> CGFloat {
        var answer = CGFloat(0)
        for _ in 0...9 {
            answer += CGFloat.random( in: -1 ... 1 )
        }
        return answer / 2
    }
    
    override func spawn( start: CGPoint, direction: CGPoint, difficulty: Difficulty ) {
        let speed = abs(cheezyGaus() * self.baseSpeed / 2)
        let rotation = cheezyGaus() * self.baseRotation
        
        sprite.run (
            SKAction.repeatForever(
                SKAction.rotate( byAngle: CGFloat.pi * rotation, duration: 0.5  )
            )
        )

        super.launch( start: start, velocity: CGPoint(x: speed*direction.x, y: speed*direction.y ))
        sprite.fadeIn( duration: 1 )
    }
    
    override func update( currentTime: TimeInterval, player: Player? ) {
        updatePosition( currentTime: currentTime )
        self.sprite.position = self.position.position
    }
    
    override func value( difficulty: Difficulty ) -> Int? {
        return difficulty.rockAward
    }
}
