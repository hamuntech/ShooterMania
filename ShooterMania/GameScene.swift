//
//  GameScene.swift
//  ShooterApp
//
//  Created by Denis Panjuta on 05/08/15.
//  Copyright (c) 2015 panjutorials. All rights reserved.
//

import SpriteKit


struct PhysicsCategory{
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Enemy        : UInt32 = 0b1 // 1
    static let Projectile   : UInt32 = 0b10 // 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player.png")
    var enemysDestroyed = 0
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.setScale(3)
         addChild(player)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        
        
       
        
        addEnemy()
        setProjectile()
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(addEnemy),
            SKAction.wait(forDuration: 1.5)
            ])
            ))
        
        run(SKAction.repeatForever(
            SKAction.sequence([
            SKAction.run(setProjectile),
            SKAction.wait(forDuration: 0.5)
            ])
            ))
        
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    func addEnemy(){
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/2)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        let randomY = random(min: enemy.size.height/2, max: size.height - enemy.size.height/2)
        
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: randomY)
        addChild(enemy)
        
        let enemySpeed = random(min: CGFloat(3.0), max: CGFloat(5.0))
        
        let moveEnemy = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y: randomY), duration: TimeInterval(enemySpeed))
        let removeEnemy = SKAction.removeFromParent()
        
        
        let loseAction = SKAction.run({
            
            let show = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: show)
            
        })
        
        
        enemy.run(SKAction.sequence([moveEnemy, loseAction, removeEnemy]))
        
        
    }
    
    func setProjectile(){
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.isDynamic = true
        
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(projectile)
        
        let moveAction = SKAction.moveTo(x: 1000, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        
        projectile.run(SKAction.sequence([moveAction, removeAction]))
        
    }
    
    func projectleHitEnemy(_ projectile: SKSpriteNode, enemy:SKSpriteNode){
        
        enemy.removeFromParent()
        projectile.removeFromParent()
        
        enemysDestroyed += 1
        
        if enemysDestroyed > 20 {
            let show = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: show)
        }
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
               
                let enemy: SKSpriteNode = secondBody.node as! SKSpriteNode
                if secondBody.allContactedBodies().count == 1 {
                    enemy.removeFromParent()
                    enemysDestroyed += 1
                }
                
                let projectile: SKSpriteNode? = firstBody.node as? SKSpriteNode
                projectile?.removeFromParent()
                
                
                if enemysDestroyed > 3 {
                    let show = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: true)
                    self.view?.presentScene(gameOverScene, transition: show)
                }
                
                
        }
        
    }
    
    
   

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        let timeToTravel = abs((touchLocation.y - player.position.y) / 500)
        
        let moveAction = SKAction.moveTo(y: touchLocation.y, duration: TimeInterval(timeToTravel))
        
        moveAction.timingMode = SKActionTimingMode.easeInEaseOut
        player.run(moveAction)
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
