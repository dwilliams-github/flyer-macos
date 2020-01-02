//
//  Foe.swift
//  
//
//  Created by David Williams on 11/23/19.
//
import SpriteKit

class FoeSlot: NSObject {
    static private let DORMANT_DURATION = 4.0   // seconds
    static private let APPEAR_DURATION  = 1.0
    static private let DYING_DURATION   = 1.0
    
    private var meanie: Meanie
    private var box: Box
    private var mine: Mine
    private var smartMine: SmartMine
    private var player: Player
    private var boom: Boom
    private var scene: SKScene
    
    private var active: Foe?
    
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
    
    init( scene: SKScene, player: Player, delay: TimeInterval ) {
        
        //
        // Preallocate potential animations
        //
        meanie = Meanie( scene: scene )
        box = Box( scene: scene )
        mine = Mine( scene: scene)
        smartMine = SmartMine( scene: scene )
        
        boom = Boom( scene: scene, name: "Boom", number: 4, size: 18 )

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
    
    func wakeUpDirection() -> CGPoint {
        let rotation = CGFloat.random( in: -CGFloat.pi ... CGFloat.pi )
        
        return CGPoint(
            x: cos(rotation),
            y: sin(rotation)
        )
    }
    
    func wakeUp(difficulty: Difficulty) {
        //
        // Select foe from our four foe types
        //
        let badder = CGFloat.random(in: 0 ..< 1) > 0.75

        if CGFloat.random(in: 0 ..< 1) < 0.25 {
            active = badder ? smartMine : mine
        }
        else {
            active = badder ? meanie : box
        }

        active!.spawn( start: wakeUpPoint(), direction: wakeUpDirection(), difficulty: difficulty )
    }
    
    func hitsPlayer( player: Player ) -> Bool {
        if let active = self.active, state == State.ACTIVE {
            return active.hitsPlayer(target: player.position)
        }
        else {
            return false
        }
    }
    
    private func changeState( newState: State, currentTime: TimeInterval ) {
        state = newState
        lastState = currentTime
    }
    
    private func currentValue(difficulty: Difficulty) -> Int? {
        switch active {
        case _ as Box:
            return difficulty.boxAward
        case _ as Mine:
            return difficulty.mineAward
        case _ as Meanie:
            return difficulty.meanieAward
        case _ as SmartMine:
            return difficulty.smartMineAward
        default:
            return nil
        }
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
                active.fade( currentTime: currentTime )
                boom.overlay( at: active.position, velocity: active.velocity!, currentTime: currentTime )
                return currentValue(difficulty: difficulty)
            }
        }
        return nil
    }
    
    func pausedTime( currentTime: TimeInterval ) {
        lastUpdate = currentTime
        active?.pausedTime( currentTime: currentTime )
        boom.pausedTime( currentTime: currentTime )
    }

    func update( currentTime: TimeInterval, difficulty: Difficulty ) {
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
                wakeUp(difficulty: difficulty)
                changeState( newState: .APPEARING, currentTime: currentTime )
            }
        }
        else if (state == .APPEARING) {
            //
            // Methought I heard a voice cry 'Sleep no more!'
            //
            if let active = self.active {
                active.update( currentTime: currentTime, player: self.player )
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
                active.update( currentTime: currentTime, player: self.player )
            }
        }
        else if (state == .DYING) {
            //
            // Alas, poor Yorick! I knew him
            //
            if let active = self.active {
                active.update( currentTime: currentTime, player: self.player )
                
                if currentTime - lastState! > FoeSlot.DYING_DURATION {
                    changeState( newState: .DORMANT, currentTime: currentTime )
                    active.hide( currentTime: currentTime )
                }
            }
        }

        boom.update( currentTime: currentTime )
        lastUpdate = currentTime
    }
    
}
