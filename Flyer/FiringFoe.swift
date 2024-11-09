//
//  FiringFoe.swift
//  Flyer
//
//  Created by David Williams on 11/8/24.
//  Copyright © 2024 David Williams. All rights reserved.
//
import SpriteKit

/**
 A Foe that moves at constant velocity but can fire bullets
 */
class FiringFoe: PewFoe {
    private let baseSpeed: CGFloat
    private let range: CGFloat
    private let rate: CGFloat
    private var lastShot: TimeInterval?

    init( scene: SKScene, sprite: FoldingSprite, speed: CGFloat, range: CGFloat, rate: CGFloat ) {
        self.baseSpeed = speed
        self.range = range
        self.rate = rate
        self.lastShot = nil
        super.init(scene: scene, sprite: sprite, arsenal: (Int)(2.0*rate+1.5))
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

        super.launch( start: start, velocity: CGPoint(x: speed*direction.x, y: speed*direction.y ))
        sprite.fadeIn( duration: 1 )
    }

    private func leadingDirection( targetPosition: CGPoint, targetVelocity: CGPoint ) -> CGPoint {
        let line = sprite.closestLine( target: targetPosition )
        let lineDistance = line.magnitude()
        
        return CGPoint(
            x: (250.0 / lineDistance) * line.x,
            y: (250.0 / lineDistance) * line.y
        )
    }

    override func update( currentTime: TimeInterval, player: Player? ) {
        updatePosition( currentTime: currentTime )
        updatePews( currentTime: currentTime )
        
        self.sprite.position = self.position.position
        
        if let p = player, player!.active() {
            if sprite.foldedPosition().smallestSquareDistance(target: p.position) < self.range*self.range {
                if self.lastShot == nil || currentTime - self.lastShot! > 1/self.rate {
                    fire(
                        start: self.sprite.position,
                        velocity: leadingDirection(
                            targetPosition: p.position,
                            targetVelocity: p.velocity
                        ),
                        duration: 2.0
                    )
                    self.lastShot = currentTime
                }
            }
        }
    }
}
