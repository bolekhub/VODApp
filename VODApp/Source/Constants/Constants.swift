//
//  Constants.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// limit download of files to this size. 20Mb
let maxDownloadSize = 20971520
let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

enum Storyboard {
    
    enum nameIdentifier: String {
        case main = "Main"
    }
}

enum cellIdentifiers {
    enum videoList: String {
        case cell = "videoCellIdentifier"
    }
}
