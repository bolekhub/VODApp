//
//  ViewController.swift
//  VODApp
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var playerControls: VersaPlayerControls!
    
    lazy var playlistVC: PlayListViewController = {
       return PlayListViewController.fromStoryboard()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
 
        playerView.layer.backgroundColor = UIColor.black.cgColor
        playerView.use(controls: self.playerControls)
        
        
        let videoUrl = documentsPath.appendingPathComponent("sample3.mp4")
        let item = VersaPlayerItem(url: videoUrl)
        //playerView.set(item: item)
        
        self.addChild(playlistVC)
        self.view.addSubview(playlistVC.view)
        playlistVC.didMove(toParent: self)
        
        playlistVC.view.translatesAutoresizingMaskIntoConstraints = false
        playlistVC.view.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -90).isActive = true
        playlistVC.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        playlistVC.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        playlistVC.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
 
    }


}

