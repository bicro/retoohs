//
//  GameScene.swift
//  retoohs
//
//  Created by Rohit Swamy on 11/8/14.
//  Copyright (c) 2014 AlexRohit. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    //background music
    var musicPlayer: AVAudioPlayer!
    var bulletFired = 1
    
    
    //background
    let myBackground: SKSpriteNode = SKSpriteNode(imageNamed: "background1")
    let bgNode: SKSpriteNode = SKSpriteNode(imageNamed: "cheerio")
    
    //player
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "PlayerA")
    
    //particle
    let myParticle: SKEmitterNode = SKEmitterNode(fileNamed: "MyParticle")
    let bulletCategory: UInt32 = 0x1 << 0
    let enemyCategory: UInt32 = 0x1 << 1
    let enemyBulletCategory: UInt32 = 0x1 << 2
    let playerCategory: UInt32 = 0x1 << 3
    
    var contactQueue = Array<SKPhysicsContact>()
    var active_Enemy: [SKSpriteNode] = []
    var isHit = false
    var levelList: [(type: Int, position: CGPoint)] = []
    var isBoss = false

    
   
    



    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //create enemy
        
        //setup particles
        myParticle.particlePosition = CGPointMake(512, 760);
        myParticle.particleBirthRate = 50;
        
        self.addChild(myParticle)
        
        
        
        //setup background music
        var e: NSError?
        let url = NSBundle.mainBundle().URLForResource("bgmusic", withExtension: "m4a")
        musicPlayer = AVAudioPlayer(contentsOfURL: url, error: &e)
        musicPlayer.numberOfLoops = -1
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        
        //self.addChild(enemy)
        
        //draw background
        myBackground.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(myBackground)

        
        //draw player
        
        player.position = CGPointMake(self.size.width/2, 40)
        
        
        player.userData = NSMutableDictionary()
        
        player.userData!.setValue(Int(3), forKey: "health")

        
        player.setScale(CGFloat(1))
        player.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(player.size.width/6))
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = enemyBulletCategory
        player.physicsBody?.collisionBitMask = 0

        self.addChild(player)
        
        generateLevel()
        spawnEnemies()
        
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
//        createEnemy1(CGPointMake(500, 700))
//        createEnemy1(CGPointMake(700, 700))


        
    }
    func spawnEnemies(){
        if levelList.count > 1 {
            for i in 0...1{
                if levelList[i].type == 1{
                    createEnemy1(levelList[i].position)
                }else if levelList[i].type == 2{
                    createEnemy2(levelList[i].position)
                }else if levelList[i].type == 3{
                    createEnemy3(levelList[i].position)
                }else{
                    createEnemy4(levelList[i].position)
                }
            }
            levelList.removeAtIndex(0)
            levelList.removeAtIndex(0)

        }
        if (levelList.count == 1){
            println(levelList[0].position)
            spawnBoss(levelList[0].position)
            isBoss = true
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.anyObject() as UITouch
//        for touch: AnyObject in touches {
//            let location = touch.locationInNode(self)
//            if(location.x < self.size.width/2){
//                println("RIGHTSIDE")
////                let v:CGVector = CGVectorMake(30,30)
////                let moveAction: SKAction = SKAction.moveBy(v, duration: 3.0)
////                if let action = moveAction as SKAction?{
////                    player.runAction(action)
//                }
//            }else{
//                println("LEFTSIDE")
//            }
//
//        }
    
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch = (touches.anyObject() as UITouch).locationInView(self.view!.superview)
        var prev_touch = (touches.anyObject() as UITouch).previousLocationInView(self.view!.superview)
        var currx = touch.x
        var curry = touch.y
        var prevx = prev_touch.x
        var prevy = prev_touch.y
        
        var x = currx - prevx
        var y = curry - prevy
        var playerX = self.player.position.x
        var playerY = self.player.position.y

        if ((playerX + x) < self.size.width - 330) && ((playerX + x) > 330){
            self.player.position.x += x
        }
        if ((playerY - y) < self.size.height - 100) && ((playerY - y) > 30){
            self.player.position.y -= y
        }
        
    
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
  
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 &&
            (secondBody.categoryBitMask & enemyCategory) != 0 {
                damageEnemy(firstBody.node as SKSpriteNode, enemy: secondBody.node as SKSpriteNode)
                
        }
        if (firstBody.categoryBitMask & enemyBulletCategory) != 0 &&
            (secondBody.categoryBitMask & playerCategory) != 0 && isHit == false{
                damagePlayer(firstBody.node as SKSpriteNode, player: secondBody.node as SKSpriteNode)
        }
    }
    func damagePlayer(enemyBullet: SKSpriteNode, player: SKSpriteNode){
        println("Player Hit! HP - 1")
        isHit = true
        var playerHP = player.userData?.valueForKey("health")!
        var hpValue = playerHP! as Int
        hpValue -= 1
        player.userData!.setValue(Int(hpValue), forKey: "health")
    }
    
    
    func damageEnemy(bullet: SKSpriteNode, enemy: SKSpriteNode){
        var enemy_count = active_Enemy.count
        var myString = enemy.userData?.valueForKey("health")!
        var healthValue = myString! as Int
        var myIndex = enemy.userData?.valueForKey("index")!
        var indexValue = myIndex! as Int
        healthValue -= 1
        enemy.userData!.setValue(Int(healthValue), forKey: "health")
        bullet.removeFromParent()
        if healthValue <= 0 {
            enemy.removeFromParent()
            active_Enemy.removeAtIndex(indexValue)
            var i = 0
            for item in active_Enemy{
                item.userData!.setValue(Int(i), forKey: "index")
            }
        }
 
    
    }
    func generateLevel(){
        
//        levelList.append(type: Int(1), position: CGPointMake(400, 500))
//        levelList.append(type: Int(1), position: CGPointMake(650, 550))
//        levelList.append(type: Int(1), position: CGPointMake(400, 700))
//        levelList.append(type: Int(1), position: CGPointMake(650, 650))
//        
//        levelList.append(type: Int(2), position: CGPointMake(700, 600))
//        levelList.append(type: Int(2), position: CGPointMake(500, 400))
//        levelList.append(type: Int(2), position: CGPointMake(750, 700))
//        levelList.append(type: Int(2), position: CGPointMake(500, 500))
//        
//        levelList.append(type: Int(3), position: CGPointMake(700, 770))
//        levelList.append(type: Int(4), position: CGPointMake(400, 670))
//        levelList.append(type: Int(3), position: CGPointMake(700, 670))
//        levelList.append(type: Int(4), position: CGPointMake(400, 570))
        
        levelList.append(type: Int(5), position: CGPointMake(355, 520))
        
       
    }
    
    
    
    func fireGun1(){
        let bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bulletA")
        bullet.setScale(CGFloat(0.5))
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true

        
        bullet.position = self.player.position
        self.addChild(bullet)
        let bullet_End_Position = CGFloat(bullet.position.y + 750)
        let bullet_Duration = NSTimeInterval(0.7)
        
        let bullet_Move = SKAction.moveToY(bullet_End_Position, duration: bullet_Duration)
        if bullet.position.y < self.size.height {
            let bullet_Move_Done = SKAction.removeFromParent()
            bullet.runAction(SKAction.sequence([bullet_Move, bullet_Move_Done]))
        }
        
    }
    
    func fireGun2(){
        let bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bulletA")
        bullet.setScale(CGFloat(0.4))
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        bullet.position = self.player.position
        self.addChild(bullet)
        let bullet_End_Position = CGPointMake(bullet.position.x+175, bullet.position.y+750)
        let bullet_Duration = NSTimeInterval(0.8)
        
        let bullet_Move = SKAction.moveTo(bullet_End_Position, duration: bullet_Duration)
        if bullet.position.y < self.size.height {
            let bullet_Move_Done = SKAction.removeFromParent()
            bullet.runAction(SKAction.sequence([bullet_Move, bullet_Move_Done]))
        }
        
    }
    func fireGun3(){
        let bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bulletA")
        bullet.setScale(CGFloat(0.4))
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        bullet.position = self.player.position
        self.addChild(bullet)
        let bullet_End_Position = CGPointMake(bullet.position.x-175, bullet.position.y+750)
        let bullet_Duration = NSTimeInterval(0.8)
        
        let bullet_Move = SKAction.moveTo(bullet_End_Position, duration: bullet_Duration)
        if bullet.position.y < self.size.height {
            let bullet_Move_Done = SKAction.removeFromParent()
            bullet.runAction(SKAction.sequence([bullet_Move, bullet_Move_Done]))
        }
        
    }
    
    
    func createEnemy1(position1:CGPoint){
      
        let enemy2: SKSpriteNode = SKSpriteNode(imageNamed: "enemyA")
        enemy2.userData = NSMutableDictionary()
        
        enemy2.userData!.setValue(Int(15), forKey: "health")
        var enemy_count = active_Enemy.count
        enemy2.userData!.setValue(Int(enemy_count), forKey: "index")
        enemy2.userData!.setValue(Int(1), forKey: "type")

        enemy2.setScale(CGFloat(1))
        enemy2.physicsBody = SKPhysicsBody(rectangleOfSize: enemy2.size)
        enemy2.physicsBody?.dynamic = true
        enemy2.physicsBody?.categoryBitMask = enemyCategory
        enemy2.physicsBody?.contactTestBitMask = bulletCategory
        enemy2.physicsBody?.collisionBitMask = 0
        
        
        enemy2.position = position1
        active_Enemy.append(enemy2)
        self.addChild(enemy2)
        let speed = Float(2.0)
        
        let enemy_End_Positon_1 = CGPoint(x: position1.x, y: (position1.y - 300))
        let enemy_duration_1 = NSTimeInterval(speed)
        let enemy_Move_1 = SKAction.moveTo(enemy_End_Positon_1, duration: enemy_duration_1)
        
        let enemy_End_Positon_2 = CGPoint(x: position1.x, y: position1.y)
        let enemy_duration_2 = NSTimeInterval(speed)
        let enemy_Move_2 = SKAction.moveTo(enemy_End_Positon_2, duration: enemy_duration_2)
        
        enemy2.runAction(SKAction.repeatAction(SKAction.sequence([enemy_Move_1,enemy_Move_2]), count: 100))
  
    }
    
    func createEnemy2(position1:CGPoint){
        
        let enemy2: SKSpriteNode = SKSpriteNode(imageNamed: "enemyB")
        enemy2.userData = NSMutableDictionary()
        
        enemy2.userData!.setValue(Int(15), forKey: "health")
        var enemy_count = active_Enemy.count
        enemy2.userData!.setValue(Int(enemy_count), forKey: "index")
        enemy2.userData!.setValue(Int(2), forKey: "type")
        
        enemy2.setScale(CGFloat(1))
        enemy2.physicsBody = SKPhysicsBody(rectangleOfSize: enemy2.size)
        enemy2.physicsBody?.dynamic = true
        enemy2.physicsBody?.categoryBitMask = enemyCategory
        enemy2.physicsBody?.contactTestBitMask = bulletCategory
        enemy2.physicsBody?.collisionBitMask = 0
        
        
        enemy2.position = position1
        active_Enemy.append(enemy2)
        self.addChild(enemy2)
        let speed = Float(1.5)
        
        let enemy_End_Positon_1 = CGPoint(x: position1.x - 200, y: position1.y)
        let enemy_duration_1 = NSTimeInterval(speed)
        let enemy_Move_1 = SKAction.moveTo(enemy_End_Positon_1, duration: enemy_duration_1)
        
        let enemy_End_Positon_2 = CGPoint(x: position1.x, y: position1.y)
        let enemy_duration_2 = NSTimeInterval(speed)
        let enemy_Move_2 = SKAction.moveTo(enemy_End_Positon_2, duration: enemy_duration_2)
        
        enemy2.runAction(SKAction.repeatAction(SKAction.sequence([enemy_Move_1,enemy_Move_2]), count: 100))
        
    }
    
    func createEnemy3(position1:CGPoint){
        
        let enemy2: SKSpriteNode = SKSpriteNode(imageNamed: "enemyC")
        enemy2.userData = NSMutableDictionary()
        
        enemy2.userData!.setValue(Int(20), forKey: "health")
        var enemy_count = active_Enemy.count
        enemy2.userData!.setValue(Int(enemy_count), forKey: "index")
        enemy2.userData!.setValue(Int(3), forKey: "type")
        
        enemy2.setScale(CGFloat(1))
        enemy2.physicsBody = SKPhysicsBody(rectangleOfSize: enemy2.size)
        enemy2.physicsBody?.dynamic = true
        enemy2.physicsBody?.categoryBitMask = enemyCategory
        enemy2.physicsBody?.contactTestBitMask = bulletCategory
        enemy2.physicsBody?.collisionBitMask = 0
        
        
        enemy2.position = position1
        active_Enemy.append(enemy2)
        self.addChild(enemy2)
        let speed = Float(1.5)
        
        let enemy_End_Positon_1 = CGPoint(x: position1.x - 200, y: position1.y-300)
        let enemy_duration_1 = NSTimeInterval(speed)
        let enemy_Move_1 = SKAction.moveTo(enemy_End_Positon_1, duration: enemy_duration_1)
        
        let enemy_End_Positon_2 = CGPoint(x: position1.x, y: position1.y)
        let enemy_duration_2 = NSTimeInterval(speed)
        let enemy_Move_2 = SKAction.moveTo(enemy_End_Positon_2, duration: enemy_duration_2)
        
        enemy2.runAction(SKAction.repeatAction(SKAction.sequence([enemy_Move_1,enemy_Move_2]), count: 100))
        
    }
    
    func createEnemy4(position1:CGPoint){
        
        let enemy2: SKSpriteNode = SKSpriteNode(imageNamed: "enemyC")
        enemy2.userData = NSMutableDictionary()
        
        enemy2.userData!.setValue(Int(20), forKey: "health")
        var enemy_count = active_Enemy.count
        enemy2.userData!.setValue(Int(enemy_count), forKey: "index")
        enemy2.userData!.setValue(Int(4), forKey: "type")
        
        enemy2.setScale(CGFloat(1))
        enemy2.physicsBody = SKPhysicsBody(rectangleOfSize: enemy2.size)
        enemy2.physicsBody?.dynamic = true
        enemy2.physicsBody?.categoryBitMask = enemyCategory
        enemy2.physicsBody?.contactTestBitMask = bulletCategory
        enemy2.physicsBody?.collisionBitMask = 0
        
        
        enemy2.position = position1
        active_Enemy.append(enemy2)
        self.addChild(enemy2)
        let speed = Float(1.5)
        
        let enemy_End_Positon_1 = CGPoint(x: position1.x + 200, y: position1.y-300)
        let enemy_duration_1 = NSTimeInterval(speed)
        let enemy_Move_1 = SKAction.moveTo(enemy_End_Positon_1, duration: enemy_duration_1)
        
        let enemy_End_Positon_2 = CGPoint(x: position1.x, y: position1.y)
        let enemy_duration_2 = NSTimeInterval(speed)
        let enemy_Move_2 = SKAction.moveTo(enemy_End_Positon_2, duration: enemy_duration_2)
        
        enemy2.runAction(SKAction.repeatAction(SKAction.sequence([enemy_Move_1,enemy_Move_2]), count: 100))
        
    }
    
    func spawnBoss(position1:CGPoint){
        let enemy2: SKSpriteNode = SKSpriteNode(imageNamed: "player-1")
        enemy2.userData = NSMutableDictionary()
        
        enemy2.userData!.setValue(Int(80), forKey: "health")
        var enemy_count = active_Enemy.count
        enemy2.userData!.setValue(Int(enemy_count), forKey: "index")
        enemy2.userData!.setValue(Int(5), forKey: "type")
        
        enemy2.setScale(CGFloat(1))
        enemy2.physicsBody = SKPhysicsBody(rectangleOfSize: enemy2.size)
        enemy2.physicsBody?.dynamic = true
        enemy2.physicsBody?.categoryBitMask = enemyCategory
        enemy2.physicsBody?.contactTestBitMask = bulletCategory
        enemy2.physicsBody?.collisionBitMask = 0
        
        enemy2.position = position1
        active_Enemy.append(enemy2)
        self.addChild(enemy2)
        
        let enemy_End_Positon_1 = CGPoint(x: position1.x + 150, y: position1.y + 200)
        let enemy_duration_1 = NSTimeInterval(speed)
        let enemy_Move_1 = SKAction.moveTo(enemy_End_Positon_1, duration: enemy_duration_1)
        
        let enemy_End_Positon_2 = CGPoint(x: position1.x + 300, y: position1.y)
        let enemy_duration_2 = NSTimeInterval(speed)
        let enemy_Move_2 = SKAction.moveTo(enemy_End_Positon_2, duration: enemy_duration_2)
        
        let enemy_End_Positon_3 = CGPoint(x: position1.x, y: position1.y)
        let enemy_duration_3 = NSTimeInterval(speed)
        let enemy_Move_3 = SKAction.moveTo(enemy_End_Positon_3, duration: enemy_duration_3)
        
        enemy2.runAction(SKAction.repeatAction(SKAction.sequence([enemy_Move_1,enemy_Move_2,enemy_Move_3]), count: 100))

    }

    
    
    func enemy_One_Spawn_Bullets(enemyPosition: CGPoint){
        var actionArray: [SKAction] = []
        for i in 0...7{
            var enemy_bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bulletB")
            enemy_bullet.setScale(CGFloat(0.35))
            enemy_bullet.physicsBody = SKPhysicsBody(circleOfRadius: enemy_bullet.size.width/2)
            enemy_bullet.physicsBody?.dynamic = true
            enemy_bullet.physicsBody?.categoryBitMask = enemyBulletCategory
            enemy_bullet.physicsBody?.contactTestBitMask = playerCategory
            enemy_bullet.physicsBody?.collisionBitMask = 0
            enemy_bullet.physicsBody?.usesPreciseCollisionDetection = true
            enemy_bullet.position = enemyPosition
            addChild(enemy_bullet)
            
            var dist = Int(700)
            var enemy_bullet_Duration = NSTimeInterval(3)
            switch i{
            
            case 0:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x - 700,y:enemy_bullet.position.y)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 1:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x + 700,y:enemy_bullet.position.y)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 2:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x,y:enemy_bullet.position.y - 700)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 3:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x,y:enemy_bullet.position.y + 700)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 4:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x - 495,y:enemy_bullet.position.y - 495)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 5:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x - 495,y:enemy_bullet.position.y + 495)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 6:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x + 495,y:enemy_bullet.position.y - 495)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 7:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x + 495,y:enemy_bullet.position.y + 495)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            default:
                break
            }
            let bullet_Move_Done = SKAction.removeFromParent()
//            if (enemy_bullet.position.y < 0) || (enemy_bullet.position.y > self.size.height) || (enemy_bullet.position.x < 0) || (enemy_bullet.position.x > self.size.width){
//                //enemy_bullet.removeFromParent()
//                let bullet_Move_Done = SKAction.removeFromParent()
//                //actionArray.append(bullet_Move_Done)
//            }
            enemy_bullet.runAction(SKAction.sequence([SKAction.group(actionArray),bullet_Move_Done]))
            //enemy_bullet.runAction(SKAction.group(actionArray))
        }
        
        
    }
    
    func bossBullets(enemyPosition: CGPoint){
        var actionArray: [SKAction] = []
        for i in 0...4{
            var enemy_bullet: SKSpriteNode = SKSpriteNode(imageNamed: "bulletB")
            enemy_bullet.setScale(CGFloat(0.35))
            enemy_bullet.physicsBody = SKPhysicsBody(circleOfRadius: enemy_bullet.size.width/2)
            enemy_bullet.physicsBody?.dynamic = true
            enemy_bullet.physicsBody?.categoryBitMask = enemyBulletCategory
            enemy_bullet.physicsBody?.contactTestBitMask = playerCategory
            enemy_bullet.physicsBody?.collisionBitMask = 0
            enemy_bullet.physicsBody?.usesPreciseCollisionDetection = true
            enemy_bullet.position = enemyPosition
            addChild(enemy_bullet)
            
            var dist = Int(700)
            var enemy_bullet_Duration = NSTimeInterval(2)
            switch i{
                
            case 0:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x - 200,y:enemy_bullet.position.y + 700)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 1:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x + 200,y:enemy_bullet.position.y + 700)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 2:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x + 100,y:enemy_bullet.position.y + 700)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 3:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x - 100,y:enemy_bullet.position.y + 700)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            case 4:
                var enemy_bullet_End_Position = CGPoint(x:enemy_bullet.position.x,y:enemy_bullet.position.y + 700)
                //var enemy_bullet_Duration = NSTimeInterval(3)
                var enemy_bullet_Move = SKAction.moveTo(enemy_bullet_End_Position, duration: enemy_bullet_Duration)
                actionArray.append(enemy_bullet_Move)
                break
            default:
                break
            }
            let bullet_Move_Done = SKAction.removeFromParent()
            //            if (enemy_bullet.position.y < 0) || (enemy_bullet.position.y > self.size.height) || (enemy_bullet.position.x < 0) || (enemy_bullet.position.x > self.size.width){
            //                //enemy_bullet.removeFromParent()
            //                let bullet_Move_Done = SKAction.removeFromParent()
            //                //actionArray.append(bullet_Move_Done)
            //            }
            enemy_bullet.runAction(SKAction.sequence([SKAction.group(actionArray),bullet_Move_Done]))
            //enemy_bullet.runAction(SKAction.group(actionArray))
        }
        
        
    }
    
    var enemy_One_Last_Update = NSTimeInterval(0)
    var time_Since_Enemy_One = NSTimeInterval(0)
    var time_Until_Next_Action_Enemy_One = NSTimeInterval(0.4)
    
    var player_Hit_Last_Update = NSTimeInterval(0)
    var time_Since_Hit = NSTimeInterval(0)
    var time_Until_Hittable = NSTimeInterval(2)
    
    override func update(currentTime: CFTimeInterval) {
        
        if(!levelList.isEmpty && active_Enemy.isEmpty){
            spawnEnemies()
        }
        
        let delta_Enemy_One = currentTime - enemy_One_Last_Update
        let last_Damaged_Player = currentTime - player_Hit_Last_Update
        
        enemy_One_Last_Update = currentTime
        player_Hit_Last_Update = currentTime
        
        time_Since_Enemy_One += delta_Enemy_One
        if (isHit){
            time_Since_Hit += last_Damaged_Player
        }
        
        if (time_Since_Hit >= time_Until_Hittable){
            isHit = false
            println("Invincibility faded")
            time_Since_Hit = NSTimeInterval(0)
            time_Until_Hittable = NSTimeInterval(2)
        }
        
        var attacked = Int(0)
        
        
        for enemy in active_Enemy{
            var myString = enemy.userData?.valueForKey("type")!
            var typeValue = myString! as Int
            if (time_Since_Enemy_One >= time_Until_Next_Action_Enemy_One) {
                if typeValue == Int(5){
                    bossBullets(enemy.position)
                }else{
                    enemy_One_Spawn_Bullets(enemy.position)
                    attacked = 1
                }
            }
        }
        if attacked == 1{
            time_Since_Enemy_One = NSTimeInterval(0)
            time_Until_Next_Action_Enemy_One = NSTimeInterval(0.4)
            attacked = 0
        }
        
        if bulletFired == 1{
            bulletFired = 2
        }else if bulletFired == 2{
            bulletFired = 3
        }else if bulletFired == 3{
            bulletFired = 4
        }else{
            fireGun1()
            //fireGun2()
            //fireGun3()
            
            bulletFired = 1
        }

       
        

    }
    
}



//class enemy {
//    let enemy1: SKSpriteNode = SKSpriteNode(imageNamed: "Spaceship")
//    func init_enemy(){
//        enemy1.position = CGPointMake(500, 500)
//        
//    }
//}

