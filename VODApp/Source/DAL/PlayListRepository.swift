//
//  PlayListRepository.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// class conforming this protocol must implement the specific storage . Ex CoreData, Memory, Realm, etc..
protocol PlayListRepositoryConformable: class {
    
    /// save an array of PlayListItemVO
    ///
    /// - Parameter items: array of PlayListItemVO
    func batchSave(items: [PlayListItemVO])
    
    /// get a video entity by its identifier
    ///
    /// - Parameter id: identifier
    /// - Returns: Video entity
    func getBy(id: String) -> Video?
    
    /// Get all entitiies, filtered by if is already cached.
    ///
    /// - Returns: array of cached videos
    func getAll() -> [Video]?
}
