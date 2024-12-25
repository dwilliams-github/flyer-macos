//
//  PewPew.swift
//  Flyer
//
//  Created by David Williams on 11/17/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 The player's missle
 */
@MainActor
class PewPew: NSObject {
    private var sprite: FoldingSprite
    private var launchSound: SKAudioNode
    private let settings: GameSettings = GameSettings.standard
    
    let spinRate: CGFloat = 4
    
    private var lastUpdate: TimeInterval?
    
    private var velocity: CGPoint?
    private var remaining: TimeInterval = 0
    
    /**
     Constructor
     - Parameter scene: The main game scene
     */
    init( scene: SKScene, imageNamed: String = "pew" ) {
        let baseSprite = SKSpriteNode(imageNamed: imageNamed)
        baseSprite.scale(to: CGSize(width: 8, height: 8))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.sprite = FoldingSprite( scene: scene, sprite: baseSprite )
        
        launchSound = SKAudioNode( fileNamed: "pew.m4a" )
        launchSound.isPositional = true
        launchSound.autoplayLooped = false
        scene.addChild(launchSound)
    }
    
    /**
     Launch a missle with given parameters
     - Parameter start: The start point
     - Parameter velocity: The velocity
     - Parameter duration: The lifetime
     
     Once launched, the missle will handle its animations and lifetime internally.
     */
    func launch( start: CGPoint, velocity: CGPoint, duration: TimeInterval ) {
        self.sprite.position = start
        self.velocity = velocity
        self.remaining = duration
        
        launchSound.position = start
        launchSound.run(SKAction.sequence([
            SKAction.changeVolume( to: 0.1*settings.volume, duration: 0 ),
            SKAction.play()
        ]))
    }
    
    /**
     True, if a missle is not currently active
     - Returns: True if available for launch
     */
    func available() -> Bool {
        return self.velocity == nil
    }
    
    /**
     Current position of the missle
     */
    var position: CGPoint? {
        get {
            self.velocity == nil ? nil : self.sprite.position
        }
    }

    /**
     Decide if a player is hit
     - Parameter target: Player target position
     */
    func hitsPlayer( target: CGPoint ) -> Bool {
        return self.velocity != nil && self.sprite.foldedPosition().smallestSquareDistance(target: target) < 300
    }

    /**
     Halt the missle early
     
     This is useful to end the flight of the missle in case it contacted something.
     */
    func halt() {
        self.velocity = nil
        self.sprite.hide()
    }
    
    /**
    Wake up from a pause
    - Parameter currentTime: Current game time
    To be invoked after a pause is lifted
    */
    func pausedTime( currentTime: TimeInterval ) {
        self.lastUpdate = currentTime
    }
    
    /**
    Update animation
    - Parameter currentTime: Current game time
    */
    func update( currentTime: TimeInterval ) {
        if let last = self.lastUpdate, let vel = velocity {
            let deltaTime = currentTime - last

            if deltaTime > self.remaining {
                self.remaining = 0
                self.velocity = nil
                self.sprite.hide()
                return
            }
            else {
                self.remaining -= deltaTime
            }

            let delta = CGFloat(deltaTime)

            self.sprite.zRotation = sprite.zRotation + CGFloat.pi*spinRate*delta
            
            // Update position
            self.sprite.position.x += vel.x*delta
            self.sprite.position.y += vel.y*delta
        }
        
        self.lastUpdate = currentTime
    }
}
