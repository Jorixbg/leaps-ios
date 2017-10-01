//
//  UIView+AllSubviews.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/4/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var allSubViews : [UIView] {
        
        var array = [self.subviews].flatMap {$0}
        
        array.forEach { array.append(contentsOf: $0.allSubViews) }
        
        return array
    }
}
