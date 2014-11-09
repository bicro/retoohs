//
//  GameScene.swift
//  retoohs
//
//  Created by Rohit Swamy on 11/8/14.
//  Copyright (c) 2014 AlexRohit. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    
    
    //background music
    var musicPlayer: AVAudioPlayer!
    var bulletFired = 1
    
    
    //background
    let myBackground: SKSpriteNode = SKSpriteNode(imageNamed: "background1")
    let bgNode: SKSpriteNode = SKSpriteNode(imageNamed: "cheerio")
    
    //player
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    //particle
    let myParticle: SKEmitterNode = SKEmitterNode(fileNamed: "MyParticle")
    private let bulletCategory: UInt32 = 0x1 << 0
    private let enemyCategory: UInt32 = 0x1 << 1



    
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
        self.addChild(player)
        createEnemy2(CGPointMake(1024, 500))

        
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
    func fireGun(){
        let bullet: SKSpriteNode = SKSpriteNode(imageNamed: "missile")
        bullet.setScale(CGFloat(0.3))
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true

        
        bullet.position = self.player.position
        self.addChild(bullet)
        let bullet_End_Position = CGFloat(bullet.position.y + 750)
        let bullet_Duration = NSTimeInterval(0.8)
        
        let bullet_Move = SKAction.moveToY(bullet_End_Position, duration: bullet_Duration)
        if bullet.position.y < self.size.width - 270 {
            let bullet_Move_Done = SKAction.removeFromParent()
            bullet.runAction(SKAction.sequence([bullet_Move, bullet_Move_Done]))
        }
        
    }
    
    func createEnemy1(position1:CGPoint){
        let enemy: SKSpriteNode = SKSpriteNode(imageNamed: "enemy")
        enemy.setScale(CGFloat(1))
        self.addChild(enemy)
        enemy.position = position1

        let enemy_End_Position_1 = CGFloat(enemy.position.y - 600)
        let enemy_duration_1 = NSTimeInterval(1.0)
        let enemy_Move_1 = SKAction.moveToY(enemy_End_Position_1, duration:enemy_duration_1)
        
        
        let enemy_End_Position_2 = CGFloat(enemy.position.y)
        let enemy_duration_2 = NSTimeInterval(1.0)
        let enemy_Move_2 = SKAction.moveToY(enemy_End_Position_2, duration:enemy_duration_2)

        let enemy_Move_Done = SKAction.removeFromParent()

        enemy.runAction(SKAction.sequence([enemy_Move_1,enemy_Move_2,enemy_Move_Done]))

        
    }

    func createEnemy2(position1:CGPoint){
        let enemy: SKSpriteNode = SKSpriteNode(imageNamed: "enemy")
        enemy.setScale(CGFloat(1))
        self.addChild(enemy)
        enemy.position = position1

        let enemy_End_Position_1 = CGPoint(x: enemy.position.x-512, y: enemy.position.y-75)
        let enemy_duration_1 = NSTimeInterval(1.5)
        let enemy_Move_1 = SKAction.moveTo(enemy_End_Position_1, duration: enemy_duration_1)
        
        let enemy_End_Position_2 = CGPoint(x: enemy.position.x-300, y: enemy.position.y-20)
        let enemy_duration_2 = NSTimeInterval(2)
        let enemy_Move_2 = SKAction.moveTo(enemy_End_Position_2, duration: enemy_duration_2)
        
        let enemy_End_Position_3 = CGPoint(x: enemy.position.x-1024, y: enemy.position.y)
        let enemy_duration_3 = NSTimeInterval(2.5)
        let enemy_Move_3 = SKAction.moveTo(enemy_End_Position_3, duration: enemy_duration_3)


        
        let enemy_Move_Done = SKAction.removeFromParent()

        enemy.runAction(SKAction.sequence([enemy_Move_1,enemy_Move_2,enemy_Move_3,enemy_Move_Done]))



        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        if bulletFired == 1{
            bulletFired = 2
        }else if bulletFired == 2{
            bulletFired = 3
        }else if bulletFired == 3{
            bulletFired = 4
        }else{
            fireGun()
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

