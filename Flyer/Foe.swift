//
//  Foe.swift
//  
//
//  Created by David Williams on 11/23/19.
//

import Cocoa

class Foe: NSObject {
    var lastUpdate: TimeInterval?
    var velocity: CGPoint?
    var position: FoldingPoint
    
    init( bounds: CGSize ) {
        position = FoldingPoint( value: CGPoint(), bounds: bounds )
    }
    
    func spawn( start: CGPoint, direction: CGPoint ) {}
    
    func hitsPlayer( target: CGPoint ) -> Bool {
        return false
    }
    
    func launch( start: CGPoint, velocity: CGPoint ) {
        self.position.position = start
        self.velocity = velocity
    }
    
    func available() -> Bool {
        return self.velocity == nil
    }
    
    func update( currentTime: TimeInterval, player: Player? ) {}
    
    func fade( currentTime: TimeInterval ) {}
    
    func hide( currentTime: TimeInterval ) {}
    
    func updatePosition( currentTime: TimeInterval ) {
        if let last = self.lastUpdate, let velocity = self.velocity {
            
            let delta = CGFloat(currentTime - last)
            
            // Update position
            position.push( direction: velocity, magnitude: delta )
        }
        
        self.lastUpdate = currentTime
    }
}
