//
//  PewPew.swift
//  Flyer
//
//  Created by David Williams on 11/17/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit

class PewPew: NSObject {
    private var sprite: FoldingSprite
    
    let spinRate: CGFloat = 4
    
    private var lastUpdate: TimeInterval?
    
    private var velocity: CGPoint?
    private var expiration: TimeInterval?
    
    init( scene: SKScene ) {
        let baseSprite = SKSpriteNode(imageNamed: "pew")
        baseSprite.scale(to: CGSize(width: 8, height: 8))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.sprite = FoldingSprite( scene: scene, sprite: baseSprite )
    }
    
    func launch( start: CGPoint, velocity: CGPoint, expires: TimeInterval ) {
        self.sprite.position = start
        self.velocity = velocity
        self.expiration = expires
    }
    
    func available() -> Bool {
        return self.velocity == nil
    }
    
    var position: CGPoint? {
        get {
            self.velocity == nil ? nil : self.sprite.position
        }
    }
    
    func halt() {
        self.velocity = nil
        self.sprite.hide()
    }
    
    func update( currentTime: TimeInterval ) {
        if let last = self.lastUpdate, let vel = velocity, let expir = expiration {
            if currentTime > expir {
                self.velocity = nil
                self.sprite.hide()
                return
            }
            
            let delta = CGFloat(currentTime - last)

            self.sprite.zRotation = sprite.zRotation + CGFloat.pi*spinRate*delta
            
            // Update position
            self.sprite.position.x += vel.x*delta
            self.sprite.position.y += vel.y*delta
        }
        
        self.lastUpdate = currentTime
    }
}
