//
//  Player.swift
//  Flyer
//
//  Created by David Williams on 11/15/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit

class Player: NSObject {
    var sprite: FoldingSprite
    var thrust: FoldingSprite
    var boom: Boom
    var holdingSprite: SKSpriteNode
    var thrustSound: SKAudioNode
    private let settings = GameSettings.standard
    
    private let spinRate: CGFloat = 2
    private let thrustRate: CGFloat = 120
    private let spawnPoint: CGPoint = CGPoint(x:0, y:0)
    
    
    //
    // We'll handle animation directly. To do so,
    // we need the last time of update.
    //
    private var lastUpdate: TimeInterval?
    
    enum Turning {
        case COAST
        case LEFT
        case RIGHT
    }
    
    enum State {
        case INITIALIZED // Yet to appear
        case WAITING     // Waiting to spawn
        case HOLDING     // Waiting to start
        case ACTIVE      // Reacts to controls
        case DEAD        // Coasting after death
    }
    
    private var spawnTime: TimeInterval?
    private var state: State
    
    private var turning: Turning
    private var thrusting: Bool

    private(set) var velocity: CGPoint = CGPoint(x:0, y:0)
    
    init( scene: SKScene ) {

        //
        // Make our player
        //
        let playerTextures = [SKTexture(imageNamed: "Player000"),SKTexture(imageNamed: "Player001")]

        let baseSprite = SKSpriteNode(texture: playerTextures[0])
        baseSprite.scale(to: CGSize(width: 20, height: 20))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        baseSprite.run(
            SKAction.repeatForever(
                SKAction.animate( with: playerTextures, timePerFrame: 1 )
            )
        )
        
        sprite = FoldingSprite( scene: scene, sprite: baseSprite )
        
        //
        // We have a separate sprite for the thrust animation
        //
        let thrustSprite = SKSpriteNode(texture: SKTexture(imageNamed: "Thrust"))
        thrustSprite.scale(to: CGSize(width: 20, height: 20))
        thrustSprite.anchorPoint = CGPoint(x: 0.5, y: 0.9)

        thrust = FoldingSprite( scene: scene, sprite: thrustSprite )
        thrust.hide()

        
        //
        // We are going to assume that the spawn point is not
        // near the edge of a scene and will use an ordinary
        // SKSpriteNode for the holding animation
        //
        holdingSprite = SKSpriteNode(texture: SKTexture(imageNamed: "Holding"))
        holdingSprite.scale(to: CGSize(width: 40, height: 40))
        holdingSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        holdingSprite.position = spawnPoint
        holdingSprite.run(
            SKAction.repeatForever(
                SKAction.rotate( byAngle: 2*CGFloat.pi, duration: 1 )
            )
        )
        holdingSprite.isHidden = true
        scene.addChild(holdingSprite)

        //
        // Boom!
        //
        boom = Boom( scene: scene, name: "Kapow", sound: "oops", number: 7, size: 30 )
        
        //
        // Vrooom!
        //
        thrustSound = SKAudioNode( fileNamed: "rocket-engine.m4a" )
        thrustSound.isPositional = true
        thrustSound.autoplayLooped = false
        thrustSound.run(SKAction.changeVolume( to: 0, duration: 0 ))
        scene.addChild(thrustSound)

        //
        // Initialize state
        //
        turning = Turning.COAST
        thrusting = false
        state = State.INITIALIZED
        sprite.alpha = 0
        sprite.hide()
    }
    
    var position : CGPoint {
        get {
            sprite.position
        }
    }
    
    func active() -> Bool {
        return state == State.ACTIVE
    }
    
    func dead() -> Bool {
        return state == State.DEAD
    }

    func spawn( when: TimeInterval ) {
        if state != State.WAITING {
            self.state = State.WAITING
            self.spawnTime = when
        }
    }
    
    func oops( when: TimeInterval ) {
        if state == State.ACTIVE {
            state = State.DEAD
            
            //
            // Make sure we turn off any action, in case a key
            // is being held down. This avoids early reactivation.
            //
            turning = Turning.COAST
            thrusting = false
            thrust.hide()
            
            //
            // Animate death
            //
            sprite.run(SKAction.fadeOut(withDuration:1))
            boom.overlay( at: sprite.foldedPosition(), velocity: velocity, currentTime: when )
        }
    }
    
    /**
     Position in which a foe should not appear.
     
     Nominally the player position, unless the player is dying or waiting to be reborn,
     in which case, the spawn location is returned
     */
    func safePosition() -> FoldingPoint {
        return state == State.ACTIVE ?
            sprite.foldedPosition() :
            FoldingPoint(value: spawnPoint, bounds: sprite.sceneSize)
    }
    
    func missleLaunchPosition() -> CGPoint {
        return CGPoint(
            x: sprite.position.x - 10*sin(sprite.zRotation),
            y: sprite.position.y + 10*cos(sprite.zRotation)
        )
    }
    
    func missleLaunchVelocity() -> CGPoint {
        return CGPoint(
            x: velocity.x - 250*sin(sprite.zRotation),
            y: velocity.y + 250*cos(sprite.zRotation)
        )
    }
    
    /**
     Decide if we are going too fast
     
     This is just to prevent the user from constantly accelerating willy nilly
     */
    func tooFast() -> Bool {
        return state == State.ACTIVE && velocity.magnitude() > 1000
    }
    
    func startLeft( currentTime: TimeInterval ) {
        update(currentTime: currentTime)
        turning = Turning.LEFT
    }
    
    func startRight( currentTime: TimeInterval ) {
        update(currentTime: currentTime)
        turning = Turning.RIGHT
    }
    
    func stopTurn( currentTime: TimeInterval ) {
        update(currentTime: currentTime)
        turning = Turning.COAST
    }
    
    func startThrust( currentTime: TimeInterval ) {
        update(currentTime: currentTime)
        thrust.position = sprite.position
        thrustSound.run(
            SKAction.sequence([
                SKAction.play(),
                SKAction.changeVolume( to: 0.2*settings.volume, duration: 0.1 ),
            ])
        )
        thrusting = true
    }
    
    func stopThrust( currentTime: TimeInterval ) {
        update(currentTime: currentTime)
        thrust.hide()
        thrustSound.run(
            SKAction.sequence([
                SKAction.changeVolume( to: 0, duration: 0.1 ),
                SKAction.stop()
            ])
        )
        thrusting = false
    }
    
    func pausedTime( currentTime: TimeInterval ) {
        lastUpdate = currentTime
    }

    func update( currentTime: TimeInterval ) {
        if state == State.INITIALIZED {
            spawn( when: currentTime )
        }
        
        if state == State.WAITING {
            //
            // We are between lives, waiting to respawn
            // When we respawn, we are in a "held" state,
            // until an action is received, to avoid untimely
            // death in case we are spawned in a bad place.
            //
            // Our held state is faded and overlaid with a "spawn" animation.
            //
            if currentTime > spawnTime! {
                state = State.HOLDING
                spawnTime = nil
                holdingSprite.alpha = 0
                holdingSprite.run(SKAction.fadeIn(withDuration: 0.5))
                holdingSprite.isHidden = false
                sprite.fadeIn(duration: 0.5, to: 0.35)
                sprite.position = spawnPoint
                sprite.zRotation = 0
                velocity = CGPoint(x:0,y:0)
            }
        }
        
        if state == State.HOLDING {
            //
            // Held until an action is received
            //
            if thrusting || turning != Turning.COAST {
                state = State.ACTIVE
                holdingSprite.isHidden = true
                sprite.fadeAlpha(to: 1, duration: 0.5)
            }
        }

        if let last = lastUpdate {
            let delta = CGFloat(currentTime - last)
            
            if state == State.ACTIVE {
                
                // Deal with turning
                switch(turning) {
                case .LEFT:
                    sprite.zRotation = sprite.zRotation + CGFloat.pi*spinRate*delta
                case .RIGHT:
                    sprite.zRotation = sprite.zRotation - CGFloat.pi*spinRate*delta
                case .COAST:
                    break
                }

                // Deal with thrusting
                if thrusting {
                    velocity = CGPoint(
                        x: velocity.x - thrustRate*delta*sin(sprite.zRotation),
                        y: velocity.y + thrustRate*delta*cos(sprite.zRotation)
                    )
                }
            }
        
            // Update position
            sprite.position.x += velocity.x * delta
            sprite.position.y += velocity.y * delta
            
            thrustSound.position = sprite.position
            
            if thrusting {
                thrust.position = sprite.position
                thrust.zRotation = sprite.zRotation
            }
        }
        
        boom.update(currentTime: currentTime)
        
        lastUpdate = currentTime
    }
}
