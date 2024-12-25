//
//  FoeSlot.swift
//  Flyer
//
//  Created by David Williams on 11/23/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 Generic allocation of a set of foes
 
 All sprite animations are loaded at the start of the game, for performance
 reasons. This class is used to store a collection of foes, only one of which
 will be active at a time. The collection allows each instance to represent
 a possible variety of foe types that could be activated during game play.
 */
@MainActor
class FoeSlot: NSObject {
    static private let DORMANT_DURATION = 4.0   // seconds
    static private let APPEAR_DURATION  = 1.0
    static private let DYING_DURATION   = 1.0
    
    let settings: GameSettings = GameSettings.standard
    private var player: Player
    private let defaultBoom: Boom
    private let bigBoom: Boom
    private var boom: Boom
    private var scene: SKScene
    
    var active: Foe?
    
    /**
     Current foe state
     - DORMANT: Not doing anything and not in the game scene, perhaps waiting to be spawned
     - APPEARING: In the process of spawning, cannot hurt the player yet
     - ACTIVE: Active (and dangerous)
     - DYING: In the process of being destroyed
     */
    enum State {
        case DORMANT
        case APPEARING
        case ACTIVE
        case DYING
    }
    
    var state: State
    
    private var lastUpdate: TimeInterval?
    private var lastState: TimeInterval?
    private var startDelay: TimeInterval
    
    /**
     Constructor
     - Parameter scene: Main game scene
     - Parameter player: The player object
     - Parameter delay: Delay in initial spawn
     */
    init( scene: SKScene, player: Player, delay: TimeInterval ) {
        //
        // Everything blows up
        //
        defaultBoom = Boom( scene: scene, name: "Boom", number: 4, sound: "boom", size: 18 )
        bigBoom = Boom( scene: scene, name: "BigBoom", number: 6, sound: "crunchy", size: 24 )
        boom = defaultBoom

        //
        // We'll need to keep track of the player and scene
        //
        self.player = player
        self.scene = scene
        
        //
        // We begin dormant
        //
        state = .DORMANT
        startDelay = delay
    }
    
    /**
     Find a fair place to wake up
     - Returns: The place
     */
    func wakeUpPoint() -> CGPoint {
        //
        // Find a random point in space that isn't
        // unfairly close to the player
        //
        let xbound = scene.size.width/2
        let ybound = scene.size.height/2
        
        let safePlace = player.safePosition()
        
        for _ in 0...10000 {
            let answer = CGPoint(
                x: CGFloat.random(in: -xbound ... xbound),
                y: CGFloat.random(in: -ybound ... ybound)
            )

            if safePlace.smallestSquareDistance( target: answer ) > 10000 {
                return answer
            }
        }
        
        assertionFailure( "Failure to generate a safe location for a foe" )
        return CGPoint()
    }
    
    /**
     Establish a random wakeup direction
     - Returns: The direction
     
     It is up to subclasses to decide how to use the direction (i.e. what initial velocity,
     if any, to give the foe).
     */
    func wakeUpDirection() -> CGPoint {
        let rotation = CGFloat.random( in: -CGFloat.pi ... CGFloat.pi )
        
        return CGPoint(
            x: cos(rotation),
            y: sin(rotation)
        )
    }

    /**
     Use a big baboom
     */
    func makeBigBoom() {
        boom = bigBoom
    }

    /**
     Use a normal baboom
     */
    func makeNormalBoom() {
        boom = defaultBoom
    }

    /**
     Wake up
     
     Subclasses should override this function to handle their assets on foe activation.
     */
    func wakeUp() {
        makeNormalBoom()
    }
    
    /**
     Decide if a player has been hit
     - Returns: True if the player has been hit
     */
    func hitsPlayer() -> Bool {
        if let active = self.active, state == State.ACTIVE {
            return active.hitsPlayer(target: self.player.position)
        }
        else {
            return false
        }
    }
    
    private func changeState( newState: State, currentTime: TimeInterval ) {
        state = newState
        lastState = currentTime
    }

    /**
     Check if a foe has been destroyed
     - Parameter missle The missle being used
     - Parameter currentTime Current game time
     - Returns: nil if nothing hit, otherwise the award for the foe dispatched
     */
    func checkHit( missle: CGPoint?, currentTime: TimeInterval, difficulty: Difficulty ) -> Int? {
        if let active = self.active, let mis = missle, state == .ACTIVE {
            if active.position.smallestSquareDistance(target: mis) < 300 {
                changeState( newState: .DYING, currentTime: currentTime )
                active.beginFading( currentTime: currentTime )
                boom.overlay( at: active.position, velocity: active.velocity!, currentTime: currentTime )
                return active.value(difficulty: difficulty)
            }
        }
        return nil
    }
    
    /**
    Wake up from a pause
    - Parameter currentTime: Current game time
    To be invoked after a pause is lifted
    */
    func pausedTime( currentTime: TimeInterval ) {
        lastUpdate = currentTime
        active?.pausedTime( currentTime: currentTime )
        boom.pausedTime( currentTime: currentTime )
    }
    
    func updateBackground( currentTime: TimeInterval ) {}

    /**
    Update animation
    - Parameter currentTime: Current game time
    */
    func update( currentTime: TimeInterval ) {
        if lastUpdate == nil {
            //
            // First update. Set beginning of current state, and do nothing else
            //
            lastState = currentTime + startDelay
        }
        else if (state == .DORMANT) {
            //
            // Innocent sleep. Sleep that soothes away all our worries.
            //
            if currentTime - lastState! > FoeSlot.DORMANT_DURATION {
                wakeUp()
                changeState( newState: .APPEARING, currentTime: currentTime )
            }
        }
        else if (state == .APPEARING) {
            //
            // Methought I heard a voice cry 'Sleep no more!'
            //
            if let active = self.active {
                active.update( currentTime: currentTime, player: self.player, responsive: false )
            }
            
            if currentTime - lastState! > FoeSlot.APPEAR_DURATION {
                changeState( newState: .ACTIVE, currentTime: currentTime )
            }
        }
        else if (state == .ACTIVE) {
            //
            // Suit the action to the word, the word to the action
            //
            if let active = self.active {
                active.update( currentTime: currentTime, player: self.player, responsive: true )
            }
        }
        else if (state == .DYING) {
            //
            // Alas, poor Yorick! I knew him
            //
            if let active = self.active {
                active.update( currentTime: currentTime, player: self.player, responsive: false )
                
                if currentTime - lastState! > FoeSlot.DYING_DURATION {
                    changeState( newState: .DORMANT, currentTime: currentTime )
                    active.reset()
                }
            }
        }

        updateBackground( currentTime: currentTime )
        boom.update( currentTime: currentTime )
        lastUpdate = currentTime
    }
    
}
