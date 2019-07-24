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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    private func commonInit() {
        let storyboard = UIStoryboard(name: Storyboard.nameIdentifier.main.rawValue, bundle: nil)
        let mainContentVC = storyboard.instantiateViewController(withIdentifier: MainViewController.storyboardidentifier()) as! MainViewController
        let bottomVC = storyboard.instantiateViewController(withIdentifier: PlayListViewController.storyboardidentifier()) as! PlayListViewController
        
        contentViewController = mainContentVC
        bottomViewController = bottomVC
        bottomVC.pullUpController = self
        contentDelegate = mainContentVC
        sizingDelegate = bottomVC
        stateDelegate = bottomVC
    }
}
