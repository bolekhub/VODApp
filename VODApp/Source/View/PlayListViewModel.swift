//
//  PlayListViewModel.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// viewmodel feedback events.
protocol PlayListViewModelEvents: class {
    /// after updating the dataset
    func didUpdate()
}

/// get data from the store, adapt data to view friendly state and configure views
class PlayListViewModel {
    
    /// data store having video entities
    private var store: PlayListRepositoryConformable
    
    /// indicate when viewmodel is working
    private var isUpdating: Bool = false
    
    /// sequence that guarantee the uniqueness of items
    private var itemsSet : Set<PlayListItem> = Set<PlayListItem>() {
        didSet{
            self.delegate?.didUpdate()
        }
    }
    
    /// keep track of played items Id. It will be cleared once all videos are played. 
    private var playedItemId = [String]() {
        didSet {
            if (playedItemId.count == self.items.count) {
                do {
                    playedItemId.removeAll()
                }
            }
        }
    }
    
    /// notify about viewmodel changes
    weak var delegate: PlayListViewModelEvents?
    
    /// collection of items to be used for display
    var items: [PlayListItem] {
        get {
            return itemsSet.compactMap({$0})
        }
    }
    
    init(dataStore: PlayListRepositoryConformable) {
        self.store = dataStore
    }
    
    /// get data from the store
    func fetchData(){
        isUpdating = true
        if let v = store.getAll() {
            isUpdating = false
            itemsSet = Set(self.parseToModel(entityArray: v))
        }
    }
    
    /// Configure the cell with data to display
    ///
    /// - Parameters:
    ///   - cell: the reused cell from collectionview
    ///   - indexPath: index of the cell
    func configureCell(cell: VideoCell, atIndexPath indexPath: IndexPath) {
        let videoItem = items[indexPath.row]
        cell.configureCell(with: videoItem)
    }

    /// convert data in the model passed to an object that VersaPlayerView can handle to be played. It also update the title and subtitle of the played video.
    ///
    /// - Parameters:
    ///   - modelItem: PlayListItem
    ///   - playerView: VersaPlayerView
    /// - Returns: VersaPlayerItem
    fileprivate func playableItem(using modelItem: PlayListItem, for playerView: VersaPlayerView) -> VersaPlayerItem {
        playedItemId.append(modelItem.id!)
        let playerItem = VersaPlayerItem(url: modelItem.localUrl)
        playerView.controls?.videoTitle?.text = modelItem.title
        playerView.controls?.videoSubtitle.text = modelItem.subtitle
        return playerItem
    }
    
    /// configure player controls ( title, subtitle ) and create an instance of VersaPlayerItem
    ///
    /// - Parameters:
    ///   - playerView: the video player instance
    ///   - indexPath: collectionview selected index
    /// - Returns: new instance of VersaPlayerItem
    func configurePlayer(_ playerView :VersaPlayerView, forSelectedIndex indexPath : IndexPath) -> VersaPlayerItem {
        
        let modelItem = self.items[indexPath.row]
        return playableItem(using: modelItem, for: playerView)
    }
    
    
    /// pop a new video form the videos array. When all videos are played it start over by first. It configure the item to be played and title, subtitle as well
    ///
    /// - Parameter player: VersaPlayerItem
    /// - Returns: VersaPlayerItem
    func nextVideo(inPlayer player:VersaPlayerView) -> VersaPlayerItem? {

        let nextVideoCandidate = itemsSet.first { (plItem) -> Bool in
            return ( !(playedItemId.contains(plItem.id!)) )
        }
        guard let videoCandidate = nextVideoCandidate else {
            return nil
        }
        return playableItem(using: videoCandidate, for: player)
    }
    
    /// Convert Video entity to PlayListItem adpating Entity properties to View
    ///
    /// - Parameter entityArray: array of fetched Video Entities
    /// - Returns: array of [PlayListItem]
    private func parseToModel(entityArray: [Video]) -> [PlayListItem] {
        
        var result: [PlayListItem] = [PlayListItem]()
        entityArray.forEach { (video) in
            let videoUrl = documentsPath.appendingPathComponent(video.fileName!)
            let item = PlayListItem(id: video.identifier,
                                    title: video.title!,
                                    subtitle: video.subtitle,
                                    localUrl: videoUrl)
            result.append(item)
        }
        return result
    }
}
