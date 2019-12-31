//
//  Lives.swift
//  Flyer
//
//  Created by David Williams on 11/30/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit

class Lives: NSObject {
    var markers : [SKSpriteNode] = []
    var value: Int

    init( scene: SKScene, startAt: Int, max: Int ) {
        value = startAt
        let coastTexture = SKTexture(imageNamed: "Player000")
        
        for i in 0..<max {
            let sprite = SKSpriteNode(texture: coastTexture)
            sprite.scale(to: CGSize(width: 20, height: 20))
            sprite.alpha = 0.5
            sprite.zPosition = -1
            sprite.position = CGPoint(
                x: CGFloat(20 + 30*i) - scene.size.width/2,
                y: scene.size.height/2 - CGFloat(20)
            )
            sprite.isHidden = i >= startAt
            scene.addChild(sprite)
            
            markers.append(sprite)
        }
    }
    
    @discardableResult func increment() -> Bool {
        if value < markers.count {
            markers[value].isHidden = false
            value += 1
            return true
        }
        return false
    }
    
    func decrement() -> Int {
        value -= 1
        markers[value].isHidden = true
        return value
    }
    
    func anyLeft() -> Bool {
        return value > 0
    }
}
