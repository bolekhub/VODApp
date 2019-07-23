//
//  PlayListItem.swift
//  VODApp
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

/// used to parse the incoming playlist, its excpected that instances are equal due to the value of
// their properties in this case the id wich corresponde with a hash coming on the notification payload.
struct PlayListItemVO: Codable, Equatable, Hashable, Comparable {

    /// title of the song
    var title: String
    
    /// description about video
    var subtitle: String?
    
    /// url of the video
    var url: String
    
    /// hash identifying the video
    var id: String?
    
    /// convert url from string to instance of URL
    ///
    /// - Returns: URL object
    func sourceURL() -> URL? {
        return URL(string: self.url)
    }
    
    //Equatable. Needed to compare two objects. are equally if both have same identifier(id) value
    static func == (lhs: PlayListItemVO, rhs: PlayListItemVO) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: PlayListItemVO, rhs: PlayListItemVO) -> Bool {
        return lhs.title < rhs.title
    }
    
    //Hashable. Used to identify object singularity in collections.
    func hash(into hasher: inout Hasher) {
        var hasher = Hasher()
        hasher.combine(id)
        let _ = hasher.finalize()
    }
    
    /// create a new instance of PlayListItemVO from specified parameters
    ///
    /// - Parameters:
    ///   - dict: dictionary containing elements that can be mapped to PlayListItemVO
    ///   - identifier: the key used to identify the singularity of this instance
    /// - Returns: PlayListItemVO
    static func fromDictionary(_ dict: NSDictionary, identifier: String) -> PlayListItemVO? {
        
        let decoder = JSONDecoder.init()

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            var decodedPlItem = try decoder.decode(PlayListItemVO.self, from: jsonData)
            decodedPlItem.id = identifier
            return decodedPlItem
        } catch {
            debugPrint("Error converting playlistItem \(error.localizedDescription)")
            return nil
        }
    }
}
