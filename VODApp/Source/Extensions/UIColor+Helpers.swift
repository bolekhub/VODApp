//
//  UIColor+Helpers.swift
//  VODApp
//
//  Created by Boris Chirino on 23/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

// Credits: http://www.seemuapps.com/swift-custom-uicolor-extension-add-custom-colors

import UIKit

extension UIColor {
    
    // Create a UIColor from RGB
    private convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    // Create a UIColor from a hex value (E.g 0x000000)
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
