//
//  Injectable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

protocol Injectable: class {
    associatedtype T
    func inject(_: T)
}

extension Injectable where Self: UIViewController {
    func asserDependencies(viewModel: BaseViewModel?) {
        assert(viewModel != nil)
    }
}
