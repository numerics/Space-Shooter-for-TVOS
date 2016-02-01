//
//  GameScene.swift
//  Space Shooter
//
//  Created by John Basile on 1/31/16.
//  Copyright (c) 2016 John Basile. All rights reserved.
//

import SpriteKit

var player = SKSpriteNode?()
var enemy = SKSpriteNode?()
var projectile = SKSpriteNode?()

var star = SKSpriteNode?()

var playerSize      = CGSize(width: 50.0, height: 50.0)
var enemySize       = CGSize(width: 40.0, height: 40.0)
var projectileSize  = CGSize(width: 10.0, height: 10.0)
var starSize        = CGSize?()

var offBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
var offWhiteColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

var touchLocation = CGPoint?()

var enemySpeed : Double = 2.0
var enemySpawnRate : Double = 1.0

var projectileSpeed : Double = 1.0
var projectileSpawnRate : Double = 0.1

var isAlive = true
var score  =  0

struct physicsCategory{
    static let player : UInt32 = 1
    static let projectile : UInt32 = 2
    static let enemy : UInt32 = 3
    
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    override func didMoveToView(view: SKView)
    {
        self.backgroundColor = offBlackColor
        physicsWorld.contactDelegate = self
        
        spawnPlayer()
        timerEnemySpawn()
        timerStarSpawn()
        timerProjectileSpawn()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            touchLocation = touch.locationInNode(self)
            player?.position.y = (touchLocation?.y)!
            
            
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        /* Called when a touch begins */
        
        for touch in touches
        {
            touchLocation = touch.locationInNode(self)
            
        }
    }
    
    func spawnEnemy()
    {
        var randomY = Int(arc4random_uniform(500) + 140)
        
        
        enemy  = SKSpriteNode(color: offWhiteColor, size: enemySize)
        enemy?.position = CGPoint(x: 1200, y: randomY)
        enemy?.name = "enemyName"
        
        enemy?.physicsBody = SKPhysicsBody(rectangleOfSize: (enemy?.size)!)
        enemy?.physicsBody?.affectedByGravity = false
        enemy?.physicsBody?.allowsRotation = false
        enemy?.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy?.physicsBody?.contactTestBitMask = physicsCategory.player
        enemy?.physicsBody?.dynamic = true
        
        moveEnemyForward()
        self.addChild(enemy!)
    }
   
    func moveEnemyForward()
    {
        let moveFoward = SKAction.moveToX(-100, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        enemy?.runAction(SKAction.sequence([moveFoward, destroy]))
        
    }
    
    func timerEnemySpawn()
    {
        let wait = SKAction.waitForDuration(enemySpawnRate)
        let spawn = SKAction.runBlock{
            self.spawnEnemy()
            
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func spawnPlayer()
    {
        player  = SKSpriteNode(color: offWhiteColor, size: playerSize)
        player?.position = CGPoint(x: CGRectGetMinX(self.frame) + 100, y: CGRectGetMidY(self.frame))
        player?.name = "playerName"
        
        player?.physicsBody = SKPhysicsBody(rectangleOfSize: (player?.size)!)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player?.physicsBody?.dynamic = true
        
        
        self.addChild(player!)
    }
    
    func spawnStar()
    {
        let randomWidth     = Int(arc4random_uniform(3)+1)
        let randomHeight    = Int(arc4random_uniform(3)+1)
        var randomY         = Int(arc4random_uniform(500) + 125)
       
        starSize = CGSize(width: randomWidth, height: randomHeight)
        
        star  = SKSpriteNode(color: offWhiteColor, size: starSize!)
        star?.position = CGPoint(x: 1200, y: randomY)
        star?.zPosition = -1
        
        starMoveForward()
        self.addChild(star!)
    }
    
    func starMoveForward()
    {
        
        let randomSpeed     = Int(arc4random_uniform(3)+1)
       
        let moveFoward = SKAction.moveToX(-100, duration: Double(randomSpeed))
        let destroy = SKAction.removeFromParent()
        star?.runAction(SKAction.sequence([moveFoward, destroy]))
        
    }
    func timerStarSpawn()
    {
        let wait = SKAction.waitForDuration(0.1)
        let spawn = SKAction.runBlock{
            self.spawnStar()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    
    func spawnProjectile()
    {
        projectile  = SKSpriteNode(color: offWhiteColor, size: projectileSize)
        projectile?.position.y = (player?.position.y)!
        projectile?.position.x = (player?.position.x)! + 50
        projectile?.name = "projectileName"

        projectile?.physicsBody = SKPhysicsBody(rectangleOfSize: (projectile?.size)!)
        projectile?.physicsBody?.affectedByGravity = false
        projectile?.physicsBody?.allowsRotation = false
        projectile?.physicsBody?.categoryBitMask = physicsCategory.projectile
        projectile?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        projectile?.physicsBody?.dynamic = true

        moveProjectileFoward()
        self.addChild(projectile!)
    }
    
    
    func moveProjectileFoward()
    {
        let moveFoward = SKAction.moveToX(1200, duration: projectileSpeed)
        let destroy = SKAction.removeFromParent()
        projectile?.runAction(SKAction.sequence([moveFoward, destroy]))
        
    }
    func timerProjectileSpawn()
    {
        let wait = SKAction.waitForDuration(projectileSpawnRate)
        let spawn = SKAction.runBlock{
            self.spawnProjectile()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func keepPlayerOnScreen()
    {
        if player?.position.y >= 640 {player?.position.y = 640}
        if player?.position.y <= 125 {player?.position.y = 125}
        player?.position.x = CGRectGetMinX(self.frame) + 100
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if( (firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy) ||
            (firstBody.categoryBitMask == physicsCategory.enemy)  && (secondBody.categoryBitMask == physicsCategory.player)
            )
        {
            playerEnemyCollision(firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
            
        }
        
        if( (firstBody.categoryBitMask == physicsCategory.projectile) && (secondBody.categoryBitMask == physicsCategory.enemy) ||
            (firstBody.categoryBitMask == physicsCategory.enemy)  && (secondBody.categoryBitMask == physicsCategory.projectile)
            )
        {
            projectileEnemyCollision(firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
            
        }
    }
    
    func playerEnemyCollision(contactA: SKSpriteNode, contactB:SKSpriteNode )
    {
        if contactA.name == "enemyName"
        {
            contactA.removeFromParent()
            isAlive = false
            gameoverLogic()
        }
        if contactB.name == "enemyName"
        {
            contactA.removeFromParent()
            isAlive = false
            gameoverLogic()
        }
        
    }

    func projectileEnemyCollision(contactA: SKSpriteNode, contactB:SKSpriteNode )
    {
        if contactA.name == "enemyName"
        {
            score = score + 1
            updateScore()
            contactA.removeFromParent()
        }
        if contactB.name == "enemyName"
        {
            score = score + 1
            updateScore()
            contactB.removeFromParent()
        }

    }
    
    func updateScore(){
        
    }
    
    func gameoverLogic(){
        
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        keepPlayerOnScreen()
        
    }
}
