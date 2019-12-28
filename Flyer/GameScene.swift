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
    
    private var settings: GameSettings?
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
        self.settings = GameSettings()
        self.score = Score(scene: self)
        self.lives = Lives(scene: self, startAt: 1, max: 8)

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
        // when the game finishes
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
        
        if let player = self.player, let settings = self.settings {
            switch event.keyCode {
            case settings.keyLeft:
                player.startLeft(currentTime: event.timestamp)
            case settings.keyRight:
                player.startRight(currentTime: event.timestamp)
            case settings.keyThrust:
                player.startThrust(currentTime: event.timestamp)
            case settings.keyFire:
                fire(currentTime: event.timestamp)
            default:
                break
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let player = self.player, let settings = self.settings {
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
        if let pews = self.pews, let foes = self.foes, let settings = self.settings {
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
        
        if let foes = self.foes, let settings = self.settings {
            //
            // Animate foes
            //
            for f in foes {
                f.update(currentTime: currentTime, difficulty: settings.difficulty)
            }
        }
    }
}
