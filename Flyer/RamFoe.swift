//
//  RamFoe.swift
//  Flyer
//
//  Created by David Williams on 11/28/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 A foe that attempts to collide head-on with the player.
 
 Note that this behavior is relatively weak beause the velocity
 of the player is not accounted for.
 */
class RamFoe: SpriteFoe {
    private let baseSpeed: CGFloat
    private let turn_speed: CGFloat
    
    init( scene: SKScene, sprite: FoldingSprite, speed: CGFloat, turn_speed: CGFloat ) {
        self.baseSpeed = speed
        self.turn_speed = turn_speed
        super.init(scene: scene, sprite: sprite)
    }
    
    override func spawn( start: CGPoint, direction: CGPoint, difficulty: Difficulty ) {
        let speed = CGFloat(difficulty.foeSpeedFactor) * self.baseSpeed
        super.launch( start: start, velocity: CGPoint(x: speed*direction.x, y: speed*direction.y ))
        sprite.fadeIn( duration: 1 )
    }

    private func aim( target: CGPoint, max_turn: CGFloat ) {
        if velocity != nil {
            let line = sprite.closestLine( target: target )

            var deltaAngle = atan2( line.y, line.x ) - atan2( velocity!.y, velocity!.x );
            if deltaAngle > CGFloat.pi {
                deltaAngle -= 2*CGFloat.pi
            }
            else if deltaAngle < -CGFloat.pi {
                deltaAngle += 2*CGFloat.pi
            }
            
            deltaAngle = min( deltaAngle, +max_turn )
            deltaAngle = max( deltaAngle, -max_turn )
            
            let sint = sin(deltaAngle)
            let cost = cos(deltaAngle)
            
            velocity! = CGPoint(
                x: velocity!.x * cost - velocity!.y * sint,
                y: velocity!.x * sint + velocity!.y * cost
            )
        }
    }
    
    override func update( currentTime: TimeInterval, player: Player? ) {
        if let p = player, let last = self.lastUpdate, player!.active() {
            aim( target: p.position, max_turn: turn_speed*CGFloat(currentTime - last) )
        }

        updatePosition( currentTime: currentTime )
        
        self.sprite.position = self.position.position
    }
}
