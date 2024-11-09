//
//  Foe.swift
//  Flyer
//
//  Created by David Williams on 11/23/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import Cocoa

/**
 Base class for all opponents in the game.
 */
@MainActor
class Foe: NSObject {
    var lastUpdate: TimeInterval?
    var velocity: CGPoint?
    var position: FoldingPoint
    
    /**
     Constructor
     - Parameter bounds: Size of scene
     
     - Note: The foe is inert until spawned. Assets should be preallocated in the
     constructor.
     */
    init( bounds: CGSize ) {
        position = FoldingPoint( value: CGPoint(), bounds: bounds )
    }
    
    /**
     Spawn the foe at given point and direction
     - Parameter start: Starting point
     - Parameter direction: Starting direction
     - Parameter difficulty: Current difficulty setting
     */
    func spawn( start: CGPoint, direction: CGPoint, difficulty: Difficulty ) {}
    
    /**
     Reset, in preparation for respawning
     */
    func reset() {
        self.velocity = nil
    }

    /**
     Decide if a player is hit
     - Parameter target The position of the player
     - Returns: True if the player is hit
     */
    func hitsPlayer( target: CGPoint ) -> Bool {
        return false
    }
    
    /**
     Set spawn parameters
     - Parameter start: Position
     - Parameter velocity: Speed
     
     To be invoked inside spawn to initialize common parameters
     */
    func launch( start: CGPoint, velocity: CGPoint ) {
        self.position.position = start
        self.velocity = velocity
        self.lastUpdate = nil
    }
    
    /**
     Available for spawning
     - Returns True if this foe is available (not active)
     */
    func available() -> Bool {
        return self.velocity == nil
    }
    
    /**
     Update at each animation frame
     - Parameter currentTime: Current play time
     - Parameter player: Player
     - Note:Must be computationally simple.
     */
    func update( currentTime: TimeInterval, player: Player? ) {}
    
    /**
     Begin fade, to prepare to disappear (die)
     - Parameter currentTime current game time
     */
    func beginFading( currentTime: TimeInterval ) {}
    
    /**
     Wake up from a pause
     - Parameter currentTime: Current game time
     - Note:This is an opportunity to reset clocks for proper animation after pausing
     */
    func pausedTime( currentTime: TimeInterval ) {
        self.lastUpdate = currentTime
    }
    
    /**
     Update position
     - Parameter currentTime: Current game time (msec)
     - Note: To be invoked inside game update, after velocity and direction updated
     */
    func updatePosition( currentTime: TimeInterval ) {
        if let last = self.lastUpdate, let velocity = self.velocity {
            
            let delta = CGFloat(currentTime - last)
            
            // Update position
            position.push( direction: velocity, magnitude: delta )
        }
        
        self.lastUpdate = currentTime
    }
    
    /**
     Reward value
     - Returns: The game reward value, if any
     */
    func value( difficulty: Difficulty ) -> Int? {
        return nil
    }
}
