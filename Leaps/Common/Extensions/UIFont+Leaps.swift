//
//  UIFont+Leaps.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/4/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

extension UIFont {
    static func leapsCervoFont(size: CGFloat) -> UIFont? {
        return UIFont(name: .leapsCervoFont, size: size)
    }
    
    static func leapsSFFont(size: CGFloat) -> UIFont? {
        return UIFont(name: .leapsSFText, size: size)
    }
}
