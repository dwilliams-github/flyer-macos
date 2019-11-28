//
//  Boom.swift
//  
//
//  Created by David Williams on 11/24/19.
//

import SpriteKit

class Boom: NSObject {
    private var boom: FoldingSprite
    private var frames: [SKTexture]

    var start: TimeInterval?
    var lastUpdate: TimeInterval?
    var velocity: CGPoint?
    
    init( scene: SKScene ) {
        self.frames = []
        let atlas = SKTextureAtlas(named: "Sprites")
        for i in 0..<4 {
            self.frames.append(atlas.textureNamed(String(format:"Boom%03d", arguments:[i])))
        }
        let boomSprite = SKSpriteNode(texture: self.frames[0])
        boomSprite.scale(to: CGSize(width: 18, height: 18))
        boomSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.boom = FoldingSprite( scene: scene, sprite: boomSprite )
    }
    
    func overlay( foe: Foe, currentTime: TimeInterval ) {
        boom.position = foe.position.position
        velocity = foe.velocity

        start = currentTime
        boom.alpha = 1
        boom.run(
            SKAction.sequence([
                SKAction.animate( with: frames, timePerFrame: 0.1 ),
                SKAction.fadeOut( withDuration: 0.1 )
            ])
        )
    }
    
    func update( currentTime: TimeInterval ) {
        if let last = self.lastUpdate, let velocity = self.velocity, let start = self.start {
            
            if currentTime - start > 1 {
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
