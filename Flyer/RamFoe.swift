//
//  RamFoe.swift
//  
//
//  Created by David Williams on 11/28/19.
//
import SpriteKit

class RamFoe: Foe {
    private var sprite: FoldingSprite
    private let speed: CGFloat
    private let turn_speed: CGFloat
    
    init( scene: SKScene, sprite: FoldingSprite, speed: CGFloat, turn_speed: CGFloat ) {
        self.sprite = sprite
        self.speed = speed
        self.turn_speed = turn_speed
        super.init(bounds: scene.size)
    }
    
    override func spawn( start: CGPoint, direction: CGPoint ) {
        super.launch( start: start, velocity: CGPoint(x: speed*direction.x, y: speed*direction.y ))
        self.sprite.fadeIn( duration: 1 )
    }
    
    override func hitsPlayer( target: CGPoint ) -> Bool {
        return sprite.foldedPosition().smallestSquareDistance(target: target) < 15*15
    }
    
    override func hide( currentTime: TimeInterval ) {
        self.sprite.hide()
        self.velocity = nil
    }
    
    override func fade( currentTime: TimeInterval ) {
        self.sprite.run(SKAction.fadeOut(withDuration:0.25))
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
