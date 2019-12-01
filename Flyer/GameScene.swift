//
//  GameScene.swift
//  Flyer
//
//  Created by David Williams on 10/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var difficulty: Difficulty?
    private var score: Score?
    private var label : SKLabelNode?
    private var player: Player?
    private var pews: [PewPew]?
    private var foes: [FoeSlot]?
    private var nextPew: Int = 0
        
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white

        self.difficulty = Hacker()
        self.score = Score(scene: self)

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
                difficulty: self.difficulty!,
                player: self.player!,
                delay: TimeInterval(i)*0.5
            ))
        }
    }
    
    private func Fire(currentTime: TimeInterval) {
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
    
    override func keyDown(with event: NSEvent) {
        if let player = self.player {
            switch event.keyCode {
            case 0x7b:
                player.startLeft(currentTime: event.timestamp)
            case 0x7c:
                player.startRight(currentTime: event.timestamp)
            case 0x7e:
                player.startThrust(currentTime: event.timestamp)
            case 0x06:
                Fire(currentTime: event.timestamp)
            default:
                break
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let player = self.player {
            switch event.keyCode {
            case 0x7b, 0x7c:
                player.stopTurn(currentTime: event.timestamp)
            case 0x7e:
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
                    if let award = f.checkHit( missle: p.position, currentTime: currentTime ), let score = self.score {
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
                if f.hitsPlayer(player: player) {
                    player.oops(when: currentTime)
                    player.spawn(when: currentTime+3)
                }
            }
        }
        
        if let player = self.player {
            //
            // Animate the player
            //
            if player.dead() {
                player.spawn(when: currentTime+1)   // initial spawn
            }
            else if player.tooFast() {
                player.oops(when: currentTime)
                player.spawn(when: currentTime+3)
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
