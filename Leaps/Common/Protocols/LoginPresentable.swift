//
//  LoginPresentable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

protocol LoginPresentable: class {
    
}

extension LoginPresentable where Self: UIViewController {
    func presentLogin(completion: (() -> Void)? = nil, onLogin: ((Bool) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: .login, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createLoginNavigationController(onLogin: onLogin) else {
            return
        }
        
        present(vc, animated: true, completion: completion)
    }
}

