//
//  UIApplication+rootViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/22/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.topViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.navigationController?.presentedViewController {
            return topViewController(presented)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}
