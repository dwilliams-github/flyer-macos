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
    private let missleSpeed: CGFloat
    private var lastShot: TimeInterval?

    init( scene: SKScene, sprite: FoldingSprite, speed: CGFloat, range: CGFloat, rate: CGFloat, missleSpeed: CGFloat ) {
        self.baseSpeed = speed
        self.range = range
        self.rate = rate
        self.missleSpeed = missleSpeed
        self.lastShot = nil
        super.init(scene: scene, sprite: sprite, arsenal: (Int)(2.0*rate+1.5))
    }
    
    override func spawn( start: CGPoint, direction: CGPoint, difficulty: Difficulty ) {
        let speed = self.baseSpeed * CGFloat.random( in: 0.5 ... 1.5 )

        super.launch( start: start, velocity: CGPoint(x: speed*direction.x, y: speed*direction.y ))
        sprite.fadeIn( duration: 1 )
    }

    private func leadingDirection( targetPosition: CGPoint, targetVelocity: CGPoint ) -> CGPoint {
        // First approximation: target at rest
        let line = sprite.closestLine( target: targetPosition )
        let lineDistance = line.magnitude()
        
        // First order correction: where target will be
        let flightTime = lineDistance / self.missleSpeed
        let leadingPosition = CGPoint(
            x: targetPosition.x + flightTime * targetVelocity.x,
            y: targetPosition.y + flightTime * targetVelocity.y
        )
        let leadingLine = sprite.closestLine( target: leadingPosition )
        let leadingDistance = leadingLine.magnitude()
        
        return CGPoint(
            x: (self.missleSpeed / leadingDistance) * leadingLine.x,
            y: (self.missleSpeed / leadingDistance) * leadingLine.y
        )
    }
    
    func updateBackground( currentTime: TimeInterval ) {
        updatePews( currentTime: currentTime )
    }

    override func update( currentTime: TimeInterval, player: Player?, responsive: Bool ) {
        updatePosition( currentTime: currentTime )
        
        self.sprite.position = self.position.position
        
        if let p = player, player!.active(), responsive {
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
