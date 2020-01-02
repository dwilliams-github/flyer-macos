//
//  BlockFoe.swift
//  Flyer
//
//  Created by David Williams on 11/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit

class BlockFoe: Foe {
    private var sprite: FoldingSprite
    private let speed: CGFloat
    private let sensitivity: CGFloat
    private let dampenSquared: CGFloat = 20*20
    private var active: Bool
    
    init( scene: SKScene, sprite: FoldingSprite, speed: CGFloat, sensitivity: CGFloat ) {
        self.sprite = sprite
        self.speed = speed
        self.sensitivity = sensitivity
        self.active = false
        super.init(bounds: scene.size)
    }
    
    override func spawn( start: CGPoint, direction: CGPoint, difficulty: Difficulty ) {
        super.launch( start: start, velocity: CGPoint(x: 0, y: 0 ))
        self.active = true
        self.sprite.fadeIn( duration: 1 )
    }
    
    override func hitsPlayer( target: CGPoint ) -> Bool {
        return sprite.foldedPosition().smallestSquareDistance(target: target) < 15*15
    }
    
    override func hide( currentTime: TimeInterval ) {
        self.sprite.hide()
        self.active = false
    }
    
    override func fade( currentTime: TimeInterval ) {
        self.sprite.run(SKAction.fadeOut(withDuration:0.25))
    }

    private func aim( targetPosition: CGPoint, targetVelocity: CGPoint, delta: TimeInterval ) -> CGPoint {
        //
        // Get target path direction
        //
        let targetSpeed = targetVelocity.magnitude()
        if targetSpeed < 0.0001 {
            //
            // If the target (the player) is not moving, we aren't either
            //
            return CGPoint(x:0, y:0)
        }
        
        //
        // Calculate cross product, which will be our direction,
        // and which also tells us how far we are from the players
        // current trajectory
        //
        let line = sprite.closestLine( target: targetPosition )
        let cross = (line.x * targetVelocity.y - line.y * targetVelocity.x) / targetSpeed
        
        //
        // Velocity increases the closest we are to the player's path,
        // but cushioned a bit to avoid oscillations, and within the
        // given speed limit
        //
        //var v = sensitivity * speed * cross / (cross*cross + dampenSquared)
        //v = min(v,speed)
        //v = max(v,-speed)
        
        var v = sensitivity * speed / cross
        
        if cross > 2 {
            if v > cross {
                v = cross
            }
            else if v < speed {
                v = speed
            }
        }
        else if cross < -2 {
            if v < cross {
                v = cross
            }
            else if v > -speed {
                v = -speed
            }
        }
        
        let lineDistance = line.magnitude()
        
        return CGPoint(
            x: -v * line.y / lineDistance,
            y: +v * line.x / lineDistance
        )
    }

    
    override func update( currentTime: TimeInterval, player: Player? ) {
        if let p = player, let last = self.lastUpdate, player!.active(), active {
            velocity! = aim( targetPosition: p.position, targetVelocity: p.velocity, delta: currentTime - last )
        }
        else if active {
            velocity! = CGPoint(x:0, y:0)
        }

        updatePosition( currentTime: currentTime )
        
        self.sprite.position = self.position.position
    }
}
