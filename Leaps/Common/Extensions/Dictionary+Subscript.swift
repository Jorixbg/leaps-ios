//
//  Dictionary+Subscript.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/14/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)]
        }
    }
}
