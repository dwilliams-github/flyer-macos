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
    var boom: Boom
    var holdingSprite: SKSpriteNode
    var coastTexture: SKTexture
    var thrustTexture: SKTexture
    
    private let spinRate: CGFloat = 2
    private let thrust: CGFloat = 120
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
        case WAITING    // Waiting to spawn
        case HOLDING    // Waiting to start
        case ACTIVE     // Reacts to controls
        case DEAD       // Coasting after death
    }
    
    private var spawnTime: TimeInterval?
    private var state: State
    
    private var turning: Turning
    private var thrusting: Bool

    private(set) var velocity: CGPoint = CGPoint(x:0, y:0)
    
    init( scene: SKScene ) {
        coastTexture = SKTexture(imageNamed: "player coast")
        thrustTexture = SKTexture(imageNamed: "player thrust")
        let holdingTexture = SKTexture(imageNamed: "Holding")

        let baseSprite = SKSpriteNode(texture: coastTexture)
        baseSprite.scale(to: CGSize(width: 20, height: 20))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //
        // We are going to assume that the spawn point is not
        // near the edge of a scene and will use an ordinary
        // SKSpriteNode for the holding animation
        //
        holdingSprite = SKSpriteNode(texture: holdingTexture)
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

        sprite = FoldingSprite( scene: scene, sprite: baseSprite )
        boom = Boom( scene: scene, name: "Kapow", number: 7, size: 30 )
        
        turning = Turning.COAST
        thrusting = false
        state = State.DEAD
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
        update(currentTime: currentTime);
        turning = Turning.LEFT
    }
    
    func startRight( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        turning = Turning.RIGHT
    }
    
    func stopTurn( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        turning = Turning.COAST
    }
    
    func startThrust( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        sprite.texture = thrustTexture;
        thrusting = true;
    }
    
    func stopThrust( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        sprite.texture = coastTexture;
        thrusting = false
    }

    func update( currentTime: TimeInterval ) {
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
                        x: velocity.x - thrust*delta*sin(sprite.zRotation),
                        y: velocity.y + thrust*delta*cos(sprite.zRotation)
                    )
                }
            }
        
            // Update position
            sprite.position.x += velocity.x * delta
            sprite.position.y += velocity.y * delta
        }
        
        boom.update(currentTime: currentTime)
        
        lastUpdate = currentTime
    }
}
