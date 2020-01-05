//
//  GameScene.swift
//  Flyer
//
//  Created by David Williams on 10/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneDelegate {
    func gameOver( score: Int )
    func newGame()
}

class GameScene: SKScene {
    
    private var settings: GameSettings = GameSettings.standard
    private var score: Score?
    private var lives: Lives?
    private var player: Player?
    private var pews: [PewPew]?
    private var foes: [FoeSlot]?
    private var nextPew: Int = 0
    private var finalDeath: TimeInterval?
    private var curtains: SKShapeNode?
    
    var gameDelegate: GameSceneDelegate?
    
    override func didMove(to view: SKView) {
        self.score = Score(scene: self)
        self.lives = Lives(scene: self, startAt: 4, max: 8)
        self.isPaused = false

        //
        // Our hero!
        //
        self.player = Player(scene: self)
        
        //
        // Our missles
        //
        self.pews = []
        for _ in 0..<8 {
            self.pews!.append(PewPew(scene: self))
        }
        
        //
        // The baddies
        //
        self.foes = []
        for i in 0..<4 {
            self.foes!.append(FoeSlot(
                scene: self,
                player: self.player!,
                delay: TimeInterval(i)*0.5
            ))
        }
        
        //
        // A shape created just to shade the whole play field
        // when the game finishes or is paused
        //
        self.curtains = SKShapeNode(rectOf: self.size)
        self.curtains!.position = CGPoint(x:0, y:0)
        self.curtains!.fillColor = self.backgroundColor
        self.curtains!.strokeColor = NSColor.clear
        self.curtains!.alpha = 0
        self.curtains!.zPosition = +10
        self.curtains!.isHidden = true
        self.addChild(self.curtains!)
    }
    
    private func fire(currentTime: TimeInterval) {
        if let player = self.player, let pews = self.pews {
            if pews[nextPew].available() {
                pews[nextPew].launch(
                    start: player.missleLaunchPosition(),
                    velocity: player.missleLaunchVelocity(),
                    expires: currentTime + 2.0
                )
                nextPew = (nextPew + 1) % pews.count
            }
        }
    }
    
    //
    // Oops.
    //
    // Tell our delegate that the game is over.
    //
    private func gameOver(currentTime: TimeInterval) {
        self.finalDeath = currentTime
        if let curtains = self.curtains {
            curtains.isHidden = false
            curtains.run(SKAction.fadeAlpha(to: 0.4, duration: 0.25))
        }
        if let gameDelegate = self.gameDelegate, let score = self.score {
            gameDelegate.gameOver(score: score.currentValue)
        }
    }
    
    
    //
    // To be invoked after a pause.
    //
    // Because our explicit animation is based off of delta time,
    // we need to reset the current time of our sprites.
    //
    // I suppose Sprite Kit does something similar under the
    // scenes (pun intended) since its animations don't need this.
    //
    private func unpause( currentTime: TimeInterval ) {
        curtains?.isHidden = true
        
        player?.pausedTime( currentTime: currentTime )
        
        foes?.forEach {
            $0.pausedTime( currentTime: currentTime )
        }
        
        pews?.forEach {
            $0.pausedTime( currentTime: currentTime )
        }
    }
    
    
    override func keyDown(with event: NSEvent) {
        if let finalDeath = self.finalDeath {
            //
            // Any keypress means a new game, but do wait a second to avoid
            // starting a game by accident
            //
            if let gameDelegate = self.gameDelegate, event.timestamp-finalDeath > 1 {
                gameDelegate.newGame()
            }
            return
        }
        
        if self.isPaused {
            if event.keyCode == settings.keyPause {
                unpause( currentTime: event.timestamp )
                self.isPaused = false
            }
            return
        }
        
        if let player = self.player {
            switch event.keyCode {
            case settings.keyLeft:
                player.startLeft(currentTime: event.timestamp)
            case settings.keyRight:
                player.startRight(currentTime: event.timestamp)
            case settings.keyThrust:
                player.startThrust(currentTime: event.timestamp)
            case settings.keyFire:
                fire(currentTime: event.timestamp)
            case settings.keyPause:
                self.isPaused = true
                curtains?.alpha = 0.4
                curtains?.isHidden = false
            default:
                break
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let player = self.player {
            switch event.keyCode {
            case settings.keyLeft, settings.keyRight:
                player.stopTurn(currentTime: event.timestamp)
            case settings.keyThrust:
                player.stopThrust(currentTime: event.timestamp)
            default:
                break
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let pews = self.pews, let foes = self.foes {
            //
            // Check for missle and foe collision
            //
            for p in pews {
                if p.available() { continue }
                for f in foes {
                    if let award = f.checkHit(
                        missle: p.position,
                        currentTime: currentTime,
                        difficulty: settings.difficulty
                    ), let score = self.score {
                        p.halt()
                        score.increment(amount: award)
                        break
                    }
                }
            }
        }
        
        if let foes = self.foes, let player = self.player {
            //
            // Check for foe and player collision
            //
            for f in foes {
                if player.active() && f.hitsPlayer(player: player) {
                    player.oops(when: currentTime)
                    if lives!.decrement() > 0 {
                        player.spawn(when: currentTime+3)
                    }
                    else {
                        gameOver(currentTime: currentTime)
                    }
                }
            }
        }
        
        if let player = self.player {
            //
            // Animate the player
            //
            if player.tooFast() {
                player.oops(when: currentTime)
                if lives!.decrement() > 0 {
                    player.spawn(when: currentTime+3)
                }
                else {
                    gameOver(currentTime: currentTime)
                }
            }
            player.update(currentTime: currentTime)
        }
        
        if let pews = self.pews {
            //
            // Animate missles
            //
            for p in pews {
                p.update(currentTime: currentTime)
            }
        }
        
        if let foes = self.foes {
            //
            // Animate foes
            //
            for f in foes {
                f.update(currentTime: currentTime)
            }
        }
    }
}
