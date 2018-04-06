//
//  GameViewController.swift
//  Pashalka
//
//  Created by Володимир Смульський on 4/6/18.
//  Copyright © 2018 Володимир Смульський. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGR.delegate = self as? UIGestureRecognizerDelegate
        tapGR.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapGR)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
