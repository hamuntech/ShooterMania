//
//  GameOverScene.swift
//  ShooterApp
//
//  Created by Denis Panjuta on 06/08/15.
//  Copyright © 2015 panjutorials. All rights reserved.
//

import Foundation
import SpriteKit


class GameOverScene: SKScene{
    
    init(size: CGSize, won: Bool){
        super.init(size:size)
        
        backgroundColor = SKColor.white
        
        let message = won ? "YOU WON!" : "Sorry you lost!"
        
        let label = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run(){
                let transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
//                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene, transition: transition)
            }
            
            
            ]))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
