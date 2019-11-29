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
    
    private var label : SKLabelNode?
    private var player: Player?
    private var pews: [PewPew]?
    private var foes: [FoeSlot]?
    private var nextPew: Int = 0
        
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white

        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }

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
            self.foes!.append( FoeSlot(scene: self, player: self.player!, delay: TimeInterval(i)*0.5) )
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
                    if f.checkHit( missle: p.position, currentTime: currentTime ) {
                        p.halt()
                        break
                    }
                }
            }
        }
        
        if let foes = self.foes, let player = self.player {
            for f in foes {
                if f.hitsPlayer(player: player) {
                    player.oops(when: currentTime)
                    player.spawn(when: currentTime+3)
                }
            }
        }
        
        if let player = self.player {
            if player.dead() {
                player.spawn(when: currentTime+1)
            }
            player.update(currentTime: currentTime)
        }
        if let pews = self.pews {
            for p in pews {
                p.update(currentTime: currentTime)
            }
        }
        if let foes = self.foes {
            for f in foes {
                f.update(currentTime: currentTime)
            }
        }
    }
}
