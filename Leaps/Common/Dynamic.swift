//
//  Dynamic.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/13/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class Dynamic<T> {
    typealias Listener = (T) -> Void
    
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        self.listener?(value)
    }
}
