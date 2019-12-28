//
//  GameSettings.swift
//  Flyer
//
//  Created by David Williams on 12/24/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

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


class GameSettings: NSObject {
    enum Keys : String {
        case difficulty, keyLeft, keyRight, keyThrust, keyFire
    }
    
    enum DifficultyKeys : Int {
        case Beginner
        case Hacker
        case Expert
    }
    
    static private var defaultValues: [String:Any] = [
        GameSettings.Keys.difficulty.rawValue: DifficultyKeys.Hacker.rawValue,
        GameSettings.Keys.keyLeft.rawValue:    0x7b as UInt16,
        GameSettings.Keys.keyRight.rawValue:   0x7c as UInt16,
        GameSettings.Keys.keyThrust.rawValue:  0x7e as UInt16,
        GameSettings.Keys.keyFire.rawValue:    0x06 as UInt16
    ]

    //
    // Keep a preallocated dictionary of difficulty settings,
    // to avoid overhead of creation/deletion
    //
    static private var difficultyStore: [Int: Difficulty] = [
        DifficultyKeys.Beginner.rawValue: Beginner(),
        DifficultyKeys.Hacker.rawValue: Hacker(),
        DifficultyKeys.Expert.rawValue: Expert()
    ]
    
    let defaults: UserDefaults
    
    override init() {
        self.defaults = UserDefaults.standard
        self.defaults.register(defaults: GameSettings.defaultValues)
    }
    
    var difficulty: Difficulty {
        get {
            return GameSettings.difficultyStore[UserDefaults.standard.object(forKey: GameSettings.Keys.difficulty.rawValue) as! Int]!
        }
    }
    
    var keyLeft: UInt16 {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyLeft.rawValue) as! UInt16
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyLeft.rawValue)
        }
    }
    
    var keyRight: UInt16 {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyRight.rawValue) as! UInt16
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyRight.rawValue)
        }
    }
    
    var keyThrust: UInt16 {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyThrust.rawValue) as! UInt16
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyThrust.rawValue)
        }
    }
    
    var keyFire: UInt16 {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyFire.rawValue) as! UInt16
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyFire.rawValue)
        }
    }
}
