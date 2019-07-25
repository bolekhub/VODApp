//
//  VideoCell.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    
    var filename: String!
    
    override func layoutSubviews() {
        self.thumbNailImageView.layer.cornerRadius = 10
        let videoUrl = documentsPath.appendingPathComponent(self.filename)
        let asset = AVAsset.init(url: videoUrl)
        thumbNailImageView.image = asset.generateThumbnail()
    }
    
    
    
    func configureCell(withData data: Video){
        self.filename = data.fileName
    }
}

