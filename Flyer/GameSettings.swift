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
    
    var foeSpeedFactor: Float = 0.8
}

class Hacker: Difficulty {
    var boxAward: Int = 200
    var mineAward: Int = 200
    var meanieAward: Int = 300
    var smartMineAward: Int = 500
    
    var foeSpeedFactor: Float = 1.0
}

class Expert: Difficulty {
    var boxAward: Int = 400
    var mineAward: Int = 400
    var meanieAward: Int = 600
    var smartMineAward: Int = 900
    
    var foeSpeedFactor: Float = 2
}


class GameSettings: NSObject {
    enum Keys : String {
        case difficulty, keyLeft, keyRight, keyThrust, keyFire, keyPause
    }
    
    enum DifficultyKeys : Int {
        case Beginner = 0
        case Hacker = 1
        case Expert = 2
    }
    
    static private var defaultValues: [String:Any] = [
        GameSettings.Keys.difficulty.rawValue: DifficultyKeys.Hacker.rawValue,
        GameSettings.Keys.keyLeft.rawValue:    0x7b as UInt16,
        GameSettings.Keys.keyRight.rawValue:   0x7c as UInt16,
        GameSettings.Keys.keyThrust.rawValue:  0x7e as UInt16,
        GameSettings.Keys.keyFire.rawValue:    0x06 as UInt16,
        GameSettings.Keys.keyPause.rawValue:   0x31 as UInt16
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
    
    var difficultyKey: Int {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.difficulty.rawValue) as! Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.difficulty.rawValue)
        }
    }
    
    var keyLeft: CGKeyCode {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyLeft.rawValue) as! CGKeyCode
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyLeft.rawValue)
        }
    }
    
    var keyRight: CGKeyCode {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyRight.rawValue) as! CGKeyCode
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyRight.rawValue)
        }
    }
    
    var keyThrust: CGKeyCode {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyThrust.rawValue) as! CGKeyCode
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyThrust.rawValue)
        }
    }
    
    var keyFire: CGKeyCode {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyFire.rawValue) as! CGKeyCode
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyFire.rawValue)
        }
    }
    
    var keyPause: CGKeyCode {
        get {
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyPause.rawValue) as! CGKeyCode
        }
        set {
            UserDefaults.standard.set(newValue, forKey: GameSettings.Keys.keyPause.rawValue)
        }
    }
    
    
    var numberKeyBindings: Int {
        get {
            return 5
        }
    }
    
    func keyDescription( seq: Int ) -> String? {
        switch seq {
        case 0:
            return "Spin counter-clockwise"
        case 1:
            return "Spin clockwise"
        case 2:
            return "Thrust"
        case 3:
            return "Fire"
        case 4:
            return "Pause game"
        default:
            return nil
        }
    }
    
    func keyValue( seq: Int ) -> CGKeyCode? {
        switch seq {
        case 0:
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyLeft.rawValue) as? CGKeyCode
        case 1:
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyRight.rawValue) as? CGKeyCode
        case 2:
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyThrust.rawValue) as? CGKeyCode
        case 3:
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyFire.rawValue) as? CGKeyCode
        case 4:
            return UserDefaults.standard.object(forKey: GameSettings.Keys.keyPause.rawValue) as? CGKeyCode
        default:
            return nil
        }
    }
    
    func setKeyValue( seq: Int, keycode: CGKeyCode? ) {
        switch seq {
        case 0:
            UserDefaults.standard.set(keycode, forKey: GameSettings.Keys.keyLeft.rawValue)
        case 1:
            UserDefaults.standard.set(keycode, forKey: GameSettings.Keys.keyRight.rawValue)
        case 2:
            UserDefaults.standard.set(keycode, forKey: GameSettings.Keys.keyThrust.rawValue)
        case 3:
            UserDefaults.standard.set(keycode, forKey: GameSettings.Keys.keyFire.rawValue)
        case 4:
            UserDefaults.standard.set(keycode, forKey: GameSettings.Keys.keyPause.rawValue)
        default:
            break
        }
    }

    
}
