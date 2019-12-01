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
}


class Beginner: Difficulty {
    var boxAward: Int = 100
    var mineAward: Int = 100
    var meanieAward: Int = 200
    var smartMineAward: Int = 300
}



class Hacker: Difficulty {
    var boxAward: Int = 200
    var mineAward: Int = 200
    var meanieAward: Int = 300
    var smartMineAward: Int = 500
}



class Expert: Difficulty {
    var boxAward: Int = 400
    var mineAward: Int = 400
    var meanieAward: Int = 600
    var smartMineAward: Int = 900
}
