//
//  Boom.swift
//  Flyer
//
//  Created by David Williams on 11/24/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import SpriteKit

/**
 Death animation
 */
@MainActor
class Boom: NSObject {
    private var boom: FoldingSprite
    private var sound: SKAudioNode
    private var frames: [SKTexture]
    private var settings = GameSettings.standard

    var start: TimeInterval?
    var lastUpdate: TimeInterval?
    var velocity: CGPoint?
    
    /**
     Constructor
     - Parameter scene: The main game scene
     - Parameter name: Prefix of filename of sprite sequence
     - Parameter number: Number of sprites
     - Parameter sound: The sound played on death
     - Parameter size: The size to scale the sprites to
     - Important: It is assumed that the sprite filenames end in a sequence number formatted
     in a zero filled integer of width three
     */
    init( scene: SKScene, name: String, number: Int, sound: String, size: Int ) {
        self.frames = []
        let atlas = SKTextureAtlas(named: "Sprites")
        for i in 0..<number {
            self.frames.append(atlas.textureNamed(String(format:"%@%03d", arguments:[name,i])))
        }
        let boomSprite = SKSpriteNode(texture: self.frames[0])
        boomSprite.scale(to: CGSize(width: size, height: size))
        boomSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.boom = FoldingSprite( scene: scene, sprite: boomSprite )
        
        self.sound = SKAudioNode(fileNamed: sound+".m4a")
        self.sound.isPositional = true
        self.sound.autoplayLooped = false
        scene.addChild(self.sound)
    }
    
    /**
     Play the explosion animation and sound at given point and time
     - Parameter at: The position of the explosion
     - Parameter velocity: The velocity of the center of the explosion
     - Parameter currentTime: Current game time
     */
    func overlay( at: FoldingPoint, velocity: CGPoint, currentTime: TimeInterval ) {
        boom.position = at.position
        self.velocity = velocity

        start = currentTime
        boom.alpha = 1
        boom.run(
            SKAction.sequence([
                SKAction.animate( with: frames, timePerFrame: 0.1 ),
                SKAction.fadeOut( withDuration: 0.2 )
            ])
        )
        
        sound.position = at.position
        sound.run(SKAction.sequence([
            SKAction.changeVolume( to: 0.4*settings.volume, duration: 0 ),
            SKAction.play()
        ]))
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
     
     Should be invoked at all game updates. The explosion will complete and shut itself off
     automatically, after which the update is a null operation.
    */
    func update( currentTime: TimeInterval ) {
        if let last = self.lastUpdate, let velocity = self.velocity, let start = self.start {
            
            if currentTime - start > 0.1*TimeInterval(frames.count+3) {
                self.velocity = nil
                boom.hide()
            }
            else {
                let delta = CGFloat(currentTime - last)
            
                // Update position
                boom.position.x += velocity.x*delta
                boom.position.y += velocity.y*delta
            }
        }
        
        self.lastUpdate = currentTime
    }
}
