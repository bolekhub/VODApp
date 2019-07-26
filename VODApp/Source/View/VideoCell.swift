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
    
    private var videoUrl: URL!
    
    override func layoutSubviews() {
        self.thumbNailImageView.layer.cornerRadius = 10
        let asset = AVAsset.init(url: videoUrl)
        thumbNailImageView.image = asset.generateThumbnail()
    }
    
    
    
    func configureCell(with model: PlayListItem){
        self.videoUrl = model.localUrl
    }
}

