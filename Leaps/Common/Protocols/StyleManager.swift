//
//  StyleManager.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/28/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

struct StyleManager {
    static func applyDefaultStyle() {
        UITabBar.appearance().tintColor = .leapsOnboardingBlue
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
    }
}
