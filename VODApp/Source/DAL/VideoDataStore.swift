//
//  VideoDataManagerDAO.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// this class handle the storage of entities. Its aware of the moethod to persist
class VideoDataStore: PlayListRepositoryConformable {
    
    var dao: PlayListRepositoryConformable
    
    init(usingDAO dao: PlayListRepositoryConformable) {
        self.dao = dao
    }
    
    func batchSave(items: [PlayListItemVO]) {
        self.dao.batchSave(items: items)
    }
    
    func getBy(id: String) -> Video? {
        return self.dao.getBy(id: id)
    }
    
    func getAll() -> [Video]? {
        return self.dao.getAll()
    }
}
