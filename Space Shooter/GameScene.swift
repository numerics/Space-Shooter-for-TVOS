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
var lblMain = SKLabelNode?()
var lblScore = SKLabelNode?()


var playerSize      = CGSize(width: 50.0, height: 50.0)
var enemySize       = CGSize(width: 40.0, height: 40.0)
var projectileSize  = CGSize(width: 10.0, height: 10.0)
var starSize        = CGSize?()

var offBlackColor = UIColor(red: 20/255, green: 30/255, blue: 20/255, alpha: 1.0)
var offWhiteColor = UIColor(red: 140/255, green: 170/255, blue: 125/255, alpha: 1.0)

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
        
        resetVariablesOnStart()
        
        spawnPlayer()
        timerEnemySpawn()
        timerStarSpawn()
        timerProjectileSpawn()
        
        spawnLblMain()
        spawnLblScore()
        
        timerSetLblAlpha()
    }
    
    func resetVariablesOnStart()
    {
        isAlive = true
        score = 0
        lblScore?.alpha = 1.0
        lblScore?.text = "Score: \(score)"
        lblMain?.alpha = 1.0
        lblMain?.text = "Start"
    }
    
    
//MARK:- Touches
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches
        {
            touchLocation = touch.locationInNode(self)
            
            if isAlive{
                player?.position.y = (touchLocation?.y)!
            }
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

//MARK: - Spawning
    
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
    
    
    func spawnLblMain()
    {
        lblMain = SKLabelNode(fontNamed: "Futura")
        lblMain?.fontSize = 150
        lblMain?.fontColor = offWhiteColor
        lblMain?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 50 )
        lblMain?.text = "Start!"
        
        self.addChild(lblMain!)
    }

    func spawnLblScore()
    {
        lblScore = SKLabelNode(fontNamed: "Futura")
        lblScore?.fontSize = 40
        lblScore?.fontColor = offWhiteColor
        lblScore?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + 110 )
        lblScore?.text = "Score: \(score)"
        
        
        self.addChild(lblScore!)
    }
   
    //MARK: - Moving Nodes
    
    func moveEnemyForward()
    {
        let moveFoward = SKAction.moveToX(-100, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        enemy?.runAction(SKAction.sequence([moveFoward, destroy]))
        
    }
    
    func starMoveForward()
    {
        
        let randomSpeed     = Int(arc4random_uniform(3)+1)
        
        let moveFoward = SKAction.moveToX(-100, duration: Double(randomSpeed))
        let destroy = SKAction.removeFromParent()
        star?.runAction(SKAction.sequence([moveFoward, destroy]))
        
    }
    func moveProjectileFoward()
    {
        let moveFoward = SKAction.moveToX(1200, duration: projectileSpeed)
        let destroy = SKAction.removeFromParent()
        projectile?.runAction(SKAction.sequence([moveFoward, destroy]))
        
    }
    
    
    //MARK: - Timing Nodes
    
    func timerEnemySpawn()
    {
        let wait = SKAction.waitForDuration(enemySpawnRate)
        let spawn = SKAction.runBlock{
            if isAlive{
                self.spawnEnemy()
            }
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    

    
    func timerStarSpawn()
    {
        let wait = SKAction.waitForDuration(0.1)
        let spawn = SKAction.runBlock{
            // if we wanted to remove all the stars when game over, we have stop spawning them
            if isAlive{
                self.spawnStar()
            }
            //self.spawnStar()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    
    
    
    func timerProjectileSpawn()
    {
        let wait = SKAction.waitForDuration(projectileSpawnRate)
        let spawn = SKAction.runBlock{
            if isAlive == true {
                self.spawnProjectile()
            }
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    //MARK: - Collision Methods on Nodes
    
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
    
    //MARK: - Game Methods 
    
    
    func keepPlayerOnScreen()
    {
        if player?.position.y >= 640 {player?.position.y = 640}
        if player?.position.y <= 125 {player?.position.y = 125}
        player?.position.x = CGRectGetMinX(self.frame) + 100
    }
    
    func updateScore()
    {
        lblScore!.text = "Score: \(score)"
    }
    
    func resetTheGame()
    {
        let wait = SKAction.waitForDuration(1.0)
        let theGameScene = GameScene(size: self.size)
        theGameScene.scaleMode = SKSceneScaleMode.AspectFill
        let theTransition = SKTransition.crossFadeWithDuration(0.4)
        let changeScene = SKAction.runBlock{
            self.scene?.view?.presentScene(theGameScene, transition: theTransition)
        }
        let sequence = SKAction.sequence([wait, changeScene])
        self.runAction(SKAction.repeatAction(sequence, count: 1))
    }
    
    func gameoverLogic()
    {
        lblMain?.text = "Game Over"
        lblMain?.alpha = 1.0
        lblScore?.alpha = 1.0
        
    // if we wanted to remove all the stars when game over, we have stop spawning them and clear out whats there on the screen
        
        self.enumerateChildNodesWithName("starName", usingBlock: {node, stop in if let sprite = node as? SKSpriteNode{sprite.removeFromParent()} })
        resetTheGame()
    }
    
    func movePlayerOffScreen()
    {
        if !isAlive{
            player?.position.y = -300
        }
    }
    
    func timerSetLblAlpha()
    {
        let wait = SKAction.waitForDuration(3.0)
        let changeAlpha = SKAction.runBlock{
            lblMain?.alpha = 0.0
            lblScore?.alpha = 0.3
        }
        
        let sequence = SKAction.sequence([wait, changeAlpha])
        self.runAction(SKAction.repeatAction(sequence, count: 1))
    }
    
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        keepPlayerOnScreen()
        
    }
}
