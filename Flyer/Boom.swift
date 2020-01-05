//
//  Boom.swift
//  
//
//  Created by David Williams on 11/24/19.
//

import SpriteKit

class Boom: NSObject {
    private var boom: FoldingSprite
    private var sound: SKAudioNode
    private var frames: [SKTexture]
    private var settings = GameSettings.standard

    var start: TimeInterval?
    var lastUpdate: TimeInterval?
    var velocity: CGPoint?
    
    init( scene: SKScene, name: String, sound: String, number: Int, size: Int ) {
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
            SKAction.changeVolume( to: 0.2*settings.volume, duration: 0 ),
            SKAction.play()
        ]))
    }
    
    func pausedTime( currentTime: TimeInterval ) {
        self.lastUpdate = currentTime
    }
    
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
