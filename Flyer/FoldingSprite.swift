//
//  FoldingSprite.swift
//  Flyer
//
//  Created by David Williams on 11/16/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit

/**
 A sprite that is contained within the scene.
 
 * Reflections are added as necessary if the sprite is near a scene boundary.
 * Modifications to the sprite are restricted to provided setters.
 */
class FoldingSprite: NSObject {
    private var primary: SKSpriteNode
    private var reflections: [SKSpriteNode] = []
    private(set) var sceneSize: CGSize
    
    
    /**
     Initializer
     
     - Parameter scene The scene in which the sprite will be drawn
     - Parameter sprite The sprite to draw
     
     # Notes
     * Assumes that the scene size does not change
     */
    init( scene: SKScene, sprite: SKSpriteNode ) {
        self.primary = sprite;
        self.primary.isHidden = true
        scene.addChild(self.primary)
        
        //
        // We need up to three copies to draw all possible reflections
        // (to appeciate why three are needed, consider an object in a corner)
        //
        // I assume copies are relatively expensive, so they are
        // preallocated here. Later we'll assume that only certain
        // specific properties need to be updated from the primary.
        //
        // Note that SKNode copies need to be added to the scene.
        //
        for _ in 0...3 {
            self.reflections.append(sprite.copy() as! SKSpriteNode);
            scene.addChild(reflections.last!)
        }
        
        // We'll need the size of the scene, so we can fold.
        // Assume this doesn't change.
        self.sceneSize = scene.size
    }
    
    private func foldedValue( value: CGFloat, span: CGFloat ) -> CGFloat {
        let halfSpan = span/2;
        if value > halfSpan {
            return (value + halfSpan).truncatingRemainder(dividingBy: span) - halfSpan
        }
        else if value < -halfSpan {
            return (value - halfSpan).truncatingRemainder(dividingBy: span) + halfSpan
        }
        return value
    }
    
    func Hide() {
        self.primary.isHidden = true
        for r in reflections {
            r.isHidden = true
        }
    }

    private func wakeUpReflection( which: Int, dx: CGFloat = 0, dy: CGFloat = 0 ) {
        let current = self.reflections[which]
        current.zRotation  = self.primary.zRotation
        current.texture    = self.primary.texture
        current.position.x = self.primary.position.x + dx
        current.position.y = self.primary.position.y + dy
        current.isHidden   = false
    }
    
    private func wakeUpDoubleReflection( which: Int, base: Int, dx: CGFloat = 0, dy: CGFloat = 0 ) {
        let current = self.reflections[which]
        current.zRotation  = self.primary.zRotation
        current.texture    = self.primary.texture
        current.position.x = self.reflections[base].position.x + dx
        current.position.y = self.reflections[base].position.y + dy
        current.isHidden   = false
    }

    /// The position of the object, which will be folded into the scene
    var position: CGPoint {
        get {
            self.primary.position
        }
        set {
            self.primary.position = CGPoint(
                x: foldedValue(value: newValue.x, span: sceneSize.width),
                y: foldedValue(value: newValue.y, span: sceneSize.height)
            )
            self.primary.isHidden = false
            
            var nextRef = 0
            
            let halfWidth = self.sceneSize.width/2
            if self.primary.position.x > halfWidth - self.primary.size.width {
                wakeUpReflection( which: nextRef, dx: -self.sceneSize.width)
                nextRef += 1
            }
            else if self.primary.position.x < -halfWidth + self.primary.size.width {
                wakeUpReflection( which: nextRef, dx: +self.sceneSize.width)
                nextRef += 1
            }
            
            let halfHeight = self.sceneSize.height/2
            if self.primary.position.y > halfHeight - self.primary.size.height {
                wakeUpReflection( which: nextRef, dy: -self.sceneSize.height)
                nextRef += 1
                if nextRef > 1 {
                    wakeUpDoubleReflection( which: nextRef, base: 0, dy: -self.sceneSize.height)
                    nextRef += 1
                }
            }
            else if self.primary.position.y < -halfHeight + self.primary.size.height {
                wakeUpReflection( which: nextRef, dy: +self.sceneSize.height)
                nextRef += 1
                if nextRef > 1 {
                    wakeUpDoubleReflection( which: nextRef, base: 0, dy: +self.sceneSize.height)
                    nextRef += 1
                }
            }

            while nextRef < 4 {
                self.reflections[nextRef].isHidden = true
                nextRef += 1
            }
        }
    }
    
    var zRotation: CGFloat {
        get {
            self.primary.zRotation
        }
        set {
            self.primary.zRotation = newValue
        }
    }
    
    var texture: SKTexture? {
        get {
            self.primary.texture
        }
        set {
            self.primary.texture = newValue
        }
    }
}
