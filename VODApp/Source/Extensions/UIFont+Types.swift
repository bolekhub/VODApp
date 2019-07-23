//
//  UIFont+Types.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation

enum VODFont: String {
    
    case Bold = "Verdana"
    
    func of(style: UIFont.TextStyle) -> UIFont {
        let preferred = UIFont.preferredFont(forTextStyle: style).pointSize
        return UIFont(name: self.rawValue, size: preferred)!
    }
}
