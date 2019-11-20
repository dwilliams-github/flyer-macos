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
    private var nextPew: Int = 0
        
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white

        // Get label node from scene and store it for use later
        label = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }

        player = Player(scene: self)
        
        pews = []
        for _ in 0...8 {
            pews!.append(PewPew(scene: self))
        }
    }
    
    private func Fire(currentTime: TimeInterval) {
        if let livePlayer = player, let pews = self.pews {
            if pews[nextPew].available() {
                pews[nextPew].launch(
                    start: livePlayer.launchPosition(),
                    velocity: livePlayer.launchVelocity(),
                    expires: currentTime + 2.0
                )
                nextPew = (nextPew + 1) % pews.count
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let livePlayer = player {
            switch event.keyCode {
            case 0x7b:
                livePlayer.startLeft(currentTime: event.timestamp)
            case 0x7c:
                livePlayer.startRight(currentTime: event.timestamp)
            case 0x7e:
                livePlayer.startThrust(currentTime: event.timestamp)
            case 0x06:
                Fire(currentTime: event.timestamp)
            default:
                break
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let livePlayer = player {
            switch event.keyCode {
            case 0x7b, 0x7c:
                livePlayer.stopTurn(currentTime: event.timestamp)
            case 0x7e:
                livePlayer.stopThrust(currentTime: event.timestamp)
            default:
                break
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let livePlayer = player {
            livePlayer.update(currentTime: currentTime)
        }
        if let pews = self.pews {
            for p in pews {
                p.update(currentTime: currentTime)
            }
        }
    }
}
