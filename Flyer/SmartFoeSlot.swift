//
//  SmartFoeSlot.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import SpriteKit

/**
 Allocation of a smart foe
 
 On wakeup, a random selection of foe type is spawned.
 
 Four type of possible foes are included (and preallocated)
 * Box: a generic foe with ramming behavior
 * Mine:  a generic foe with blocking behavior
 * Meanie: more aggressive ramming
 * SmartMine: more aggressive blocking
 */
class SmartFoeSlot: FoeSlot {
    private var meanie: Meanie
    private var box: Box
    private var mine: Mine
    private var smartMine: SmartMine
    private var miniBoss: MiniBoss
    private var generation: Int

    override init( scene: SKScene, player: Player, delay: TimeInterval ) {
        //
        // Preallocate potential animations
        //
        meanie = Meanie( scene: scene )
        box = Box( scene: scene )
        mine = Mine( scene: scene)
        smartMine = SmartMine( scene: scene )
        miniBoss = MiniBoss( scene: scene )
        
        generation = 0

        super.init(scene: scene, player: player, delay: delay)
    }
    
    override func updateBackground(currentTime: TimeInterval) {
        miniBoss.updateBackground(currentTime: currentTime)
    }
    
    override func wakeUp() {
        //
        // Select foe from our four foe types
        //  * 1/4 of the time we get a mine
        //  * Some fraction of the time we get a badder version
        //
        // Badder fraction is zero at n = 0, increases
        // to 1/4 at n = 50, and asymptotically approaches 3/4
        // at n = infinity
        //
        let floatGeneration = CGFloat(self.generation)
        let badderFraction = 0.75 * floatGeneration / (50.0 + floatGeneration)
//        let bossLikelihood = 0.05 * floatGeneration / (100.0 + floatGeneration)
        let bossLikelihood = 0.2 * floatGeneration / (2.0 + floatGeneration)

        let badder = CGFloat.random(in: 0 ..< 1) < badderFraction
        
        let toss = CGFloat.random(in: 0 ..< 1)

        if toss < 0.25 {
            active = badder ? smartMine : mine
        }
        else if toss < 0.25 + bossLikelihood {
            active = miniBoss
        }
        else {
            active = badder ? meanie : box
        }
        
        self.generation += 1

        active!.spawn( start: wakeUpPoint(), direction: wakeUpDirection(), difficulty: settings.difficulty )
    }
}
