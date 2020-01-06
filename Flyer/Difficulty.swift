//
//  Difficulty.swift
//  Flyer
//
//  Created by David Williams on 11/30/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

protocol Difficulty {
    
    var boxAward: Int { get }
    var meanieAward: Int { get }
    var mineAward: Int { get }
    var smartMineAward: Int { get }
    var rockAward: Int { get }
    
    var foeSpeedFactor: Float { get }
}
