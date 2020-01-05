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
        // We need up to three additional copies to draw all possible reflections
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
        // We assume this doesn't change.
        self.sceneSize = scene.size
    }
    
    func run(_ action: SKAction ) {
        primary.run(action)
        for r in reflections {
            r.run(action)
        }
    }
    
    func hide() {
        primary.isHidden = true
        for r in reflections {
            r.isHidden = true
        }
    }
    
    /**
     Fade from nothing
     - Parameter duration Time to fade in
     - Parameter to Target alpha at end of fade
     
     Alpha is set to zero immediately.
     */
    func fadeIn( duration: TimeInterval, to: CGFloat = 1 ) {
        alpha = 0
        run(SKAction.fadeAlpha(to: to, duration: duration))
    }
    
    func fadeAlpha( to: CGFloat, duration: TimeInterval ) {
        run(SKAction.fadeAlpha(to: to, duration: duration))
    }

    var alpha: CGFloat {
        get {
            primary.alpha
        }
        set {
            primary.alpha = newValue
            for r in reflections {r.alpha = newValue}
        }
    }

    private func wakeUpReflection( which: Int, dx: CGFloat = 0, dy: CGFloat = 0 ) {
        let current = self.reflections[which]
        current.zRotation  = primary.zRotation
        current.texture    = primary.texture
        current.position.x = primary.position.x + dx
        current.position.y = primary.position.y + dy
        current.isHidden   = false
    }
    
    private func wakeUpDoubleReflection( which: Int, base: Int, dx: CGFloat = 0, dy: CGFloat = 0 ) {
        let current = self.reflections[which]
        current.zRotation  = primary.zRotation
        current.texture    = primary.texture
        current.position.x = reflections[base].position.x + dx
        current.position.y = reflections[base].position.y + dy
        current.isHidden   = false
    }
    
    
    func closestLine( target: CGPoint ) -> CGPoint {
        return FoldingPoint( value: primary.position, bounds: sceneSize ).closestLine(target: target)
    }
    
    func foldedPosition() -> FoldingPoint {
        return FoldingPoint( value: primary.position, bounds: sceneSize )
    }
    

    /// The position of the object, which will be folded into the scene
    var position: CGPoint {
        get {
            primary.position
        }
        set {
            primary.position = FoldingPoint( value: newValue, bounds: sceneSize ).position
            if primary.isHidden {
                primary.isHidden = false
            }
            
            var nextRef = 0
            
            let halfWidth = sceneSize.width/2
            if primary.position.x > halfWidth - primary.size.width {
                wakeUpReflection( which: nextRef, dx: -sceneSize.width)
                nextRef += 1
            }
            else if primary.position.x < -halfWidth + primary.size.width {
                wakeUpReflection( which: nextRef, dx: +sceneSize.width)
                nextRef += 1
            }
            
            let halfHeight = sceneSize.height/2
            if primary.position.y > halfHeight - primary.size.height {
                wakeUpReflection( which: nextRef, dy: -sceneSize.height)
                nextRef += 1
                if nextRef > 1 {
                    wakeUpDoubleReflection( which: nextRef, base: 0, dy: -sceneSize.height)
                    nextRef += 1
                }
            }
            else if primary.position.y < -halfHeight + primary.size.height {
                wakeUpReflection( which: nextRef, dy: +sceneSize.height)
                nextRef += 1
                if nextRef > 1 {
                    wakeUpDoubleReflection( which: nextRef, base: 0, dy: +sceneSize.height)
                    nextRef += 1
                }
            }

            while nextRef < 4 {
                reflections[nextRef].isHidden = true
                nextRef += 1
            }
        }
    }
    
    var zRotation: CGFloat {
        get {
            primary.zRotation
        }
        set {
            primary.zRotation = newValue
        }
    }
    
    var texture: SKTexture? {
        get {
            primary.texture
        }
        set {
            primary.texture = newValue
        }
    }
}
