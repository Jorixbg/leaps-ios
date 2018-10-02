//
//  MainTabBarController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/13/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

enum MainTab: Int {
    case home = 0
    case favorite = 1
    case calendar = 2
    case chat = 3
    case profile = 4
}

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let selector = #selector(onLoggedOut)
        let selector2 = #selector(onDestinationSet)
        NotificationCenter.default.addObserver(self, selector: selector, name: .loggedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: selector2, name: .notifiacationDestinationSet, object: nil)
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
    
    @objc func onLoggedOut() {
        go(to: .home)
    }
    
    @objc func onDestinationSet(_ notification: NSNotification) {
        if let destination = notification.userInfo?["destination"] as? NotificationDestination {
            go(to: destination.page)
            if destination.id == "" {
                AppDelegate.notificationDestination = nil
            }
        }
    }
    
    func go(to tab: MainTab) {
        selectedIndex = tab.rawValue
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
