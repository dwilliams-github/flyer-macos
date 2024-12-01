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
    var miniBossAward: Int = 1000
    var rockAward: Int = 50
    
    var foeSpeedFactor: Float = 0.8
}

class Hacker: Difficulty {
    var boxAward: Int = 200
    var mineAward: Int = 200
    var meanieAward: Int = 300
    var smartMineAward: Int = 500
    var miniBossAward: Int = 1400
    var rockAward: Int = 50

    var foeSpeedFactor: Float = 1.0
}

class Expert: Difficulty {
    var boxAward: Int = 400
    var mineAward: Int = 400
    var meanieAward: Int = 600
    var smartMineAward: Int = 900
    var miniBossAward: Int = 2500
    var rockAward: Int = 50

    var foeSpeedFactor: Float = 2
}

/**
 Game settings
 
 A singleton instance is provided for efficiency.
 */
@MainActor
class GameSettings: NSObject {
    enum Keys : String {
        case difficulty, keyLeft, keyRight, keyThrust, keyFire, keyPause, volume, fullScreen
    }
    
    enum DifficultyKeys : Int {
        case Beginner = 0
        case Hacker = 1
        case Expert = 2
    }
    
    /**
     Our singleton instance
     
     Functionally speaking, the singleton isn't needed. It is provided for
     the sake of efficiency.
     */
    static let standard = GameSettings()
    
    //
    // Default values. We load them on construction.
    //
    static private var defaultValues: [String:Any] = [
        GameSettings.Keys.difficulty.rawValue: DifficultyKeys.Hacker.rawValue,
        GameSettings.Keys.keyLeft.rawValue:    0x7b as UInt16,
        GameSettings.Keys.keyRight.rawValue:   0x7c as UInt16,
        GameSettings.Keys.keyThrust.rawValue:  0x7e as UInt16,
        GameSettings.Keys.keyFire.rawValue:    0x06 as UInt16,
        GameSettings.Keys.keyPause.rawValue:   0x31 as UInt16,
        GameSettings.Keys.volume.rawValue:     0.5 as Float,
        GameSettings.Keys.fullScreen.rawValue: false
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
    
    //
    // For the sake of modularity, we'll access the system level
    // UserDefaults singleton via this property variable.
    //
    private var defaults: UserDefaults = UserDefaults.standard
    
    
    /**
     Constructor
     */
    override init() {
        self.defaults.register(defaults: GameSettings.defaultValues)
    }
    
    /**
     Current game difficulty setting
     
     Note that the user can alter the setting at any point in the game, so that difficulty
     setting values should not be cached. This method is designed to impose a minimum
     overhead of resources.
     
     - ToDo: It might be wise to protect against corrupted settings
     */
    var difficulty: Difficulty {
        get {
            return GameSettings.difficultyStore[UserDefaults.standard.object(forKey: GameSettings.Keys.difficulty.rawValue) as! Int]!
        }
    }
    
    /**
     The difficulty key
     */
    var difficultyKey: Int {
        get {
            return defaults.object(forKey: GameSettings.Keys.difficulty.rawValue) as! Int
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.difficulty.rawValue)
        }
    }
    
    /**
     Keycode used by the player to indicate a counter-clockwise turn
     */
    var keyLeft: CGKeyCode {
        get {
            return defaults.object(forKey: GameSettings.Keys.keyLeft.rawValue) as! CGKeyCode
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.keyLeft.rawValue)
        }
    }
    
    /**
     Keycode used by the player to indicate a clockwise turn
     */
    var keyRight: CGKeyCode {
        get {
            return defaults.object(forKey: GameSettings.Keys.keyRight.rawValue) as! CGKeyCode
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.keyRight.rawValue)
        }
    }
    
    /**
     Keycode used by the player to indicate thrusting
     */
    var keyThrust: CGKeyCode {
        get {
            return defaults.object(forKey: GameSettings.Keys.keyThrust.rawValue) as! CGKeyCode
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.keyThrust.rawValue)
        }
    }
    
    /**
     Keycode used by the player to indicate a the firing of a missle
     */
    var keyFire: CGKeyCode {
        get {
            return defaults.object(forKey: GameSettings.Keys.keyFire.rawValue) as! CGKeyCode
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.keyFire.rawValue)
        }
    }
    
    /**
     Keycode used by the player to pause the game
     */
    var keyPause: CGKeyCode {
        get {
            return defaults.object(forKey: GameSettings.Keys.keyPause.rawValue) as! CGKeyCode
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.keyPause.rawValue)
        }
    }
    
    
    /**
     Number of keycode bindings used by the game
     */
    var numberKeyBindings: Int {
        get {
            return 5
        }
    }
    
    /**
     Description of given key binding
     - Parameter seq: The key binding sequence (counting from zero)
     - Returns: The description
     
     This method is useful for user settings interfaces (i.e. the preferences pane)
     */
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
    
    /**
     Return the given keycode value
     - Parameter seq:The key binding sequence (counting from zero)
     - Returns: The keycode
     
     This method is useful for user settings interfaces (i.e. the preferences pane)
     */
    func keyValue( seq: Int ) -> CGKeyCode? {
        switch seq {
        case 0:
            return defaults.object(forKey: GameSettings.Keys.keyLeft.rawValue) as? CGKeyCode
        case 1:
            return defaults.object(forKey: GameSettings.Keys.keyRight.rawValue) as? CGKeyCode
        case 2:
            return defaults.object(forKey: GameSettings.Keys.keyThrust.rawValue) as? CGKeyCode
        case 3:
            return defaults.object(forKey: GameSettings.Keys.keyFire.rawValue) as? CGKeyCode
        case 4:
            return defaults.object(forKey: GameSettings.Keys.keyPause.rawValue) as? CGKeyCode
        default:
            return nil
        }
    }
    
    /**
     Set given keycode value
     - Parameter seq: The key binding sequence (counting from zero)
     - Parameter keycode: The new value for the key binding
     
     This method is useful for user settings interfaces (i.e. the preferences pane)
     */
    func setKeyValue( seq: Int, keycode: CGKeyCode? ) {
        switch seq {
        case 0:
            defaults.set(keycode, forKey: GameSettings.Keys.keyLeft.rawValue)
        case 1:
            defaults.set(keycode, forKey: GameSettings.Keys.keyRight.rawValue)
        case 2:
            defaults.set(keycode, forKey: GameSettings.Keys.keyThrust.rawValue)
        case 3:
            defaults.set(keycode, forKey: GameSettings.Keys.keyFire.rawValue)
        case 4:
            defaults.set(keycode, forKey: GameSettings.Keys.keyPause.rawValue)
        default:
            break
        }
    }

    /**
     Current game volume.
     
     We only have one overall volume for all sounds.
     */
    var volume : Float {
        get {
            return defaults.float(forKey: GameSettings.Keys.volume.rawValue)
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.volume.rawValue)
        }
    }
    
    /**
     Full screen setting.
     
     This controls the default window state on startup only.
     */
    var fullScreen : Bool {
        get {
            return defaults.bool(forKey: GameSettings.Keys.fullScreen.rawValue)
        }
        set {
            defaults.set(newValue, forKey: GameSettings.Keys.fullScreen.rawValue)
        }
    }
}
