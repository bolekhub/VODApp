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

class PlayListViewModel {
    
    private var store: PlayListRepositoryConformable
    
    private var isUpdating: Bool = false
    
    weak var delegate: PlayListViewModelEvents?
    
    var items: [Video] = [Video]() {
        didSet{
            self.delegate?.didUpdate()
        }
    }
    
    init(dataStore: PlayListRepositoryConformable) {
        self.store = dataStore
        if let v = store.getAll() {
            items.append(contentsOf: v)
        }
    }
    
    func fetchData(){
        if let v = store.getAll() {
            items.removeAll()
            items.append(contentsOf: v)
        }
    }
    
    func configureCell(cell: VideoCell, atIndexPath indexPath: IndexPath) {
        let videoItem = items[indexPath.row]
        cell.configureCell(withData: videoItem)
    }
    
}
