//
//  SpriteFoe.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import SpriteKit

/**
 A foe that is represented by one main sprite and any number of missles
 */
class PewFoe: Foe {
    let sprite: FoldingSprite
    private var pews: [PewPew]?
    private var nextPew: Int = 0

    /**
     Constructor
     - Parameter scene: The parent scene
     - Parameter sprite: The folding sprite
     - Parameter arsenal: Max number of active missles
     */
    init( scene: SKScene, sprite: FoldingSprite, arsenal: Int ) {
        self.sprite = sprite
        super.init(bounds: scene.size)

        self.pews = (0..<arsenal).map({_ in PewPew(scene: scene, imageNamed: "altpew")})
    }

    /**
     Decide if a player is hit
     - Parameter target: Player target position
     - Note: Either the main sprite or any activie missle can hit a player
     */
    override func hitsPlayer( target: CGPoint ) -> Bool {
        //
        // Like any foe, hitting the main sprite is fatal
        //
        if (sprite.foldedPosition().smallestSquareDistance(target: target) < 15*15) {
            return true
        }
        
        //
        // Now check missles
        //
        for pew in self.pews! {
            if pew.hitsPlayer(target: target) {
                return true
            }
        }
        
        return false
    }

    func fire(start: CGPoint, velocity: CGPoint, duration: TimeInterval) {
        if let pews = self.pews {
            if pews[nextPew].available() {
                pews[nextPew].launch(
                    start: start,
                    velocity: velocity,
                    duration: duration
                )
                nextPew = (nextPew + 1) % pews.count
            }
        }
    }
    
    func updatePews(currentTime: TimeInterval) {
        for pew in self.pews! {
            pew.update(currentTime: currentTime)
        }
    }

    /**
     Prepare for respawning
     */
    override func reset() {
        self.sprite.hide()
        super.reset()
    }
    
    /**
     Begin fading
     
     For a sprite based foe, this means fading the sprite.
     We leave the missles to fade by themselves.
     */
    override func beginFading( currentTime: TimeInterval ) {
        self.sprite.run(SKAction.fadeOut(withDuration:0.25))
    }
}
