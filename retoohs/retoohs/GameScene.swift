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
    let myBackground: SKSpriteNode!
    let bgNode: SKSpriteNode!
    
    //player
    let player: SKSpriteNode!
    
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
        let myBackground = SKSpriteNode(imageNamed: "background1")
        myBackground.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(myBackground)
        
        //draw background nodes
        let bgnode = SKSpriteNode(imageNamed: "cheerio")
        bgnode.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgnode)
        
        //draw player
        let player = SKSpriteNode(imageNamed: "player")
        player.position = CGPointMake(self.size.width/2, 40)
        self.addChild(player)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location

            
            self.addChild(sprite)
        }
    }
   
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //player.update
        //enemy.update
        //background.update
    }
}
