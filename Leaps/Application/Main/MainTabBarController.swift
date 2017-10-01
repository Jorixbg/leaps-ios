//
//  MainTabBarController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/13/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let selector = #selector(onLoggedOut)
        NotificationCenter.default.addObserver(self, selector: selector, name: .loggedOut, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard  let items  = tabBar.items else {
            return
        }
        
        for item in items {
            item.titlePositionAdjustment = UIOffsetMake(0, -6)
        }
    }
    
    func onLoggedOut() {
        selectedIndex = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        
        guard let loginRequiredIndex = index, loginRequiredIndex > 0 else {
            return true
        }
        
        let loggedIn = UserManager.shared.isLoggedIn
        
        if !loggedIn {
            presentLogin() { [weak self] successful in
                if successful {
                    print("logged in successful")
                    self?.selectedIndex = loginRequiredIndex
                } else {
                    print("login not successful")
                }
            }
        }
        
        return loggedIn
    }
}

extension MainTabBarController: LoginPresentable {}
