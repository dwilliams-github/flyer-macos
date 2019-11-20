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
    var coastTexture: SKTexture
    var thrustTexture: SKTexture
    
    let spinRate: CGFloat = 2
    let thrust: CGFloat = 120
    
    //
    // We'll handle animation directly. To do so,
    // we need the last time of update.
    //
    private var lastUpdate: TimeInterval?
    
    enum Turning {
        case coast
        case left
        case right
    }
    
    private var turning: Turning
    private var thrusting: Bool

    private var velocity: CGPoint = CGPoint(x:0, y:0)
    
    init( scene: SKScene ) {
        coastTexture = SKTexture(imageNamed: "player coast")
        thrustTexture = SKTexture(imageNamed: "player thrust")

        let baseSprite = SKSpriteNode(texture: coastTexture)
        baseSprite.scale(to: CGSize(width: 20, height: 20))
        baseSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        sprite = FoldingSprite( scene: scene, sprite: baseSprite )
        
        turning = Turning.coast
        thrusting = false
    }
    
    func launchPosition() -> CGPoint {
        return CGPoint(
            x: sprite.position.x - 10*sin(sprite.zRotation),
            y: sprite.position.y + 10*cos(sprite.zRotation)
        )
    }
    
    func launchVelocity() -> CGPoint {
        return CGPoint(
            x: velocity.x - 250*sin(sprite.zRotation),
            y: velocity.y + 250*cos(sprite.zRotation)
        )
    }
    
    func startLeft( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        turning = Turning.left
    }
    
    func startRight( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        turning = Turning.right
    }
    
    func stopTurn( currentTime: TimeInterval ) {
        update(currentTime: currentTime);
        turning = Turning.coast
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
        if let last = lastUpdate {
            let delta = CGFloat(currentTime - last)
            
            // Deal with turning
            switch(turning) {
            case .left:
                sprite.zRotation = sprite.zRotation + CGFloat.pi*spinRate*delta
            case .right:
                sprite.zRotation = sprite.zRotation - CGFloat.pi*spinRate*delta
            case .coast:
                break
            }

            // Deal with thrusting
            if thrusting {
                velocity = CGPoint(
                    x: velocity.x - thrust*delta*sin(sprite.zRotation),
                    y: velocity.y + thrust*delta*cos(sprite.zRotation)
                )
            }
            
            // Update position
            sprite.position.x += velocity.x * delta
            sprite.position.y += velocity.y * delta
        }
        
        lastUpdate = currentTime
    }
}
