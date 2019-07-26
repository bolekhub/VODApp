//
//  ContainerViewController.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import ISHPullUp

class ContainerViewController: ISHPullUpViewController {
    
    private weak var mainViewController: MainViewController?
    private weak var playListViewController: PlayListViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        self.dimmingColor = nil
        let storyboard = UIStoryboard(name: Storyboard.nameIdentifier.main.rawValue, bundle: nil)
        let mainContentVC = storyboard.instantiateViewController(withIdentifier: MainViewController.storyboardidentifier()) as! MainViewController
        let bottomVC = storyboard.instantiateViewController(withIdentifier: PlayListViewController.storyboardidentifier()) as! PlayListViewController
        
        mainViewController = mainContentVC
        playListViewController = bottomVC
        
        contentViewController = mainContentVC
        bottomViewController = bottomVC
        bottomVC.pullUpController = self
        contentDelegate = mainContentVC
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playListViewController?.videoPlayerView = mainViewController?.playerView

    }
}
