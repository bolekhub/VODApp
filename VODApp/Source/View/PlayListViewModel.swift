//
//  PlayListViewModel.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

protocol PlayListViewModelEvents: class {
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
        fetchData()
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
