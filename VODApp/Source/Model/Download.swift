//
//  DownloadItem.swift
//  VODApp
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// Represent the object that need download and track its state.
class Download: Equatable, Hashable {
    
    /// item to be downloaded
    var item : PlayListItemVO
    
    /// Download task
    var task : URLSessionDownloadTask?
    
    /// everytime the download start this property is set to true. On failing or complete is set to false
    var inProgress = false
    
    /// download complete
    var complete = false
    
    /// download fail
    var failed = false
    
    /// if this download exceed limitations imposed by download service
    var oversized = false
    
    /// contain data to resume in cas of any interruption.
    var resumeData: Data?
    
    init(item: PlayListItemVO) {
        self.item = item
    }
    
    //Equatable. Needed to compare two objects. are equally if both have same identifier(id) value
    static func == (lhs: Download, rhs: Download) -> Bool {
        return lhs.item.id == rhs.item.id
    }
    
    
    //Hashable. Used to identify object singularity in collections.
    func hash(into hasher: inout Hasher) {
        var hasher = Hasher()
        hasher.combine(item.id)
        let _ = hasher.finalize()
    }
    
    func cancel(oversized: Bool = false){
        self.inProgress = false
        self.oversized = oversized
        self.task?.cancel()
    }
}
