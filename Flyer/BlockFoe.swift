//
//  BlockFoe.swift
//  Flyer
//
//  Created by David Williams on 11/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 A foe that attempts to place itself in the player path
 */
class BlockFoe: SpriteFoe {
    private let baseThrust: CGFloat
    private var thrust: CGFloat = 0
    private var active: Bool
    
    /**
     Constructor
     - Parameter scene: The game scene in which to place the foe
     - Parameter sprite: The sprite used to represent the foe
     - Parameter baseThrust: Base value of sprite's thrust, to be modified by difficulty on spawn
     - Note: Animations for the sprite should be setup outside this class
     */
    init( scene: SKScene, sprite: FoldingSprite, baseThrust: CGFloat ) {
        self.baseThrust = baseThrust
        self.active = false
        super.init(scene: scene, sprite: sprite)
    }
    
    /**
    Spawn the foe at given point and direction
    - Parameter start: Starting point
    - Parameter direction: Starting direction
    - Parameter difficulty: Current difficulty setting
    */
    override func spawn( start: CGPoint, direction: CGPoint, difficulty: Difficulty ) {
        super.launch( start: start, velocity: CGPoint(x: 0, y: 0 ))
        self.active = true
        self.thrust = CGFloat(difficulty.foeSpeedFactor) * self.baseThrust
        self.sprite.fadeIn( duration: 1 )
    }
    
    /**
    Reset, in preparation for respawning
    */
    override func reset() {
        self.active = false
        super.reset()
    }

    //
    // Return thrust vector
    //
    private func aim( targetPosition: CGPoint, targetVelocity: CGPoint ) -> CGPoint {
        //
        // Fetch relative velocity
        //
        let relative = CGPoint( x: targetVelocity.x - velocity!.x, y: targetVelocity.y - velocity!.y )
        
        //
        // Get target path direction
        //
        let relativeSpeed = relative.magnitude()
        if relativeSpeed < 0.000001 {
            //
            // If the target (the player) is not moving, we aren't either
            //
            return CGPoint(x:0, y:0)
        }
        
        //
        // Thrust at right angles, for quickest route to a blocking
        // position, assuming player does not change speed.
        //
        let line = sprite.closestLine( target: targetPosition )
        let lineDistance = line.magnitude()

        let cross = (line.x * relative.y - line.y * relative.x)
        let v = cross < 0 ? -thrust : +thrust
        
        return CGPoint(
            x: -v * line.y / lineDistance,
            y: +v * line.x / lineDistance
        )
    }
    
    /**
     Update animation
     - Parameter currentTime: Current game time
     - Parameter player: Current player
     */
    override func update( currentTime: TimeInterval, player: Player? ) {
        if let p = player, let last = self.lastUpdate, player!.active(), active {
            let delta = CGFloat(currentTime - last)
            let accel = aim( targetPosition: p.position, targetVelocity: p.velocity )
        
            velocity!.x += delta * accel.x
            velocity!.y += delta * accel.y
        }

        updatePosition( currentTime: currentTime )
        
        self.sprite.position = self.position.position
    }
}
