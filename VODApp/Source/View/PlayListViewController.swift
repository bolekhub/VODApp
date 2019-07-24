//
//  PlayListViewController.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

class PlayListViewController: UIViewController {
    
    
    class func fromStoryboard() -> PlayListViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PlayListViewController")
        return vc as! PlayListViewController
    }
}
