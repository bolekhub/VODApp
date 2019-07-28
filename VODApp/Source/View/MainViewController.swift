//
//  ViewController.swift
//  VODApp
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import ISHPullUp

class MainViewController: UIViewController, ISHPullUpContentDelegate {
    
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var playerControls: VersaPlayerControls!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        playerView.layer.contents = UIImage(named: "rosalia_blured")?.cgImage
        playerView.use(controls: self.playerControls)
    }


    static func storyboardidentifier() -> String {
        
        return String(describing: MainViewController.self)
    }
    
    
    //MARK: - ISHPullUpContentDelegate
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets,
                              forContentViewController contentVC: UIViewController) {
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = edgeInsets
            playerView.layoutMargins = .zero
        } else {
            // update edgeInsets
            playerView.layoutMargins = edgeInsets
        }
        playerView.layoutIfNeeded()
    }
    
}
