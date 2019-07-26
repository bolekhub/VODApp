//
//  PlayListItem.swift
//  VODApp
//
//  Created by Boris Chirino on 26/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

struct PlayListItem: Hashable {
    
    var id: String?
    
    /// title of the song
    var title: String
    
    /// description about video
    var subtitle: String?
    
    /// url of the video
    var localUrl: URL

    //Hashable. Used to identify object singularity in collections.
    func hash(into hasher: inout Hasher) {
        var hasher = Hasher()
        hasher.combine(id)
        let _ = hasher.finalize()
    }
}

