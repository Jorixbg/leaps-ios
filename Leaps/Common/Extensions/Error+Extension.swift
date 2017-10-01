//
//  Error+Extension.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/17/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
}
