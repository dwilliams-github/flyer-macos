//
//  SmartFoeSlot.swift
//  Flyer
//
//  Created by David Williams on 1/5/20.
//  Copyright © 2020 David Williams. All rights reserved.
//

import SpriteKit

class SmartFoeSlot: FoeSlot {
    private var meanie: Meanie
    private var box: Box
    private var mine: Mine
    private var smartMine: SmartMine

    override init( scene: SKScene, player: Player, delay: TimeInterval ) {
        
        //
        // Preallocate potential animations
        //
        meanie = Meanie( scene: scene )
        box = Box( scene: scene )
        mine = Mine( scene: scene)
        smartMine = SmartMine( scene: scene )

        super.init(scene: scene, player: player, delay: delay)
    }
    
    override func wakeUp() {
        //
        // Select foe from our four foe types
        //
        let badder = CGFloat.random(in: 0 ..< 1) > 0.75

        if CGFloat.random(in: 0 ..< 1) < 0.25 {
            active = badder ? smartMine : mine
        }
        else {
            active = badder ? meanie : box
        }

        active!.spawn( start: wakeUpPoint(), direction: wakeUpDirection(), difficulty: settings.difficulty )
    }
}
