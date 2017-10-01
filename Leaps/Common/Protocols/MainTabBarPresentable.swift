//
//  MainTabBarPresentable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//
import UIKit

protocol MainTabBarPresentable {
    
}

extension MainTabBarPresentable where Self: UIViewController {
    func startMainTabBarController() {
        let storyboard = UIStoryboard(name: .main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "\(MainTabBarController.self)")
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            present(navigationController, animated: false, completion: nil)
        }   
    }
}
