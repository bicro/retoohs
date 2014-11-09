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



    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
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
        
        //draw background nodes
        bgNode.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgNode)
        
        //draw player
        player.position = CGPointMake(self.size.width/2, 40)
        self.addChild(player)
        
        
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
        self.addChild(bullet)
        bullet.position = self.player.position
        let bullet_End_Position = CGFloat(bullet.position.y + 750)
        let bullet_Duration = NSTimeInterval(0.8)
        
        let bullet_Move = SKAction.moveToY(bullet_End_Position, duration: bullet_Duration)
        if bullet.position.y < self.size.width - 270 {
            let bullet_Move_Done = SKAction.removeFromParent()
            bullet.runAction(SKAction.sequence([bullet_Move, bullet_Move_Done]))
        }
        
    }
    
   
    
    
    override func update(currentTime: CFTimeInterval) {
        if bulletFired == 1{
            bulletFired = 2
        }else if bulletFired == 2{
            bulletFired = 3
        }else{
            fireGun()
            bulletFired = 1
        }

       
        /* Called before each frame is rendered */
        //player.update
        //enemy.update
        //background.update
    }
    
}

class enemy {
    let enemy1: SKSpriteNode = SKSpriteNode(imageNamed: "Spaceship")
    func init_enemy(){
        enemy1.position = CGPointMake(500, 500)
    }
}

