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
    
    
    //background
    let myBackground: SKSpriteNode = SKSpriteNode(imageNamed: "background1")
    let bgNode: SKSpriteNode = SKSpriteNode(imageNamed: "cheerio")
    
    //player
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "player")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //setup background music
        var e: NSError?
        let url = NSBundle.mainBundle().URLForResource("bgmusic", withExtension: "m4a")
        musicPlayer = AVAudioPlayer(contentsOfURL: url, error: &e)
        musicPlayer.numberOfLoops = -1
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        
        
        
        //draw background
        myBackground.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(myBackground)
        
        //draw background nodes
        bgnode.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgnode)
        
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
        let touch = (touches.anyObject() as UITouch).locationInView(self.view!.superview)
        let prev_touch = (touches.anyObject() as UITouch).previousLocationInView(self.view!.superview)
        currx = touch.x
        curry = touch.y
        prevx = prev_touch.x
        prevy = prev_touch.y
        
        x = currx - prevx
        y = curry - prevy
        

    }
    
   
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //player.update
        //enemy.update
        //background.update
    }
}
