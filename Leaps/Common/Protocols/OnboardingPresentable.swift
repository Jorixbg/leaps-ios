//
//  OnboardingPresentable.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

import Foundation
import UIKit

protocol OnboardingPresentable: class {
    
}

extension OnboardingPresentable where Self: UIViewController {
    func presentOnboarding() {
        let storyboardName: String = .onboarding
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let storyboardFactory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let viewController = storyboardFactory.createOnboardingFlowViewController() else {
            print("guard failed \(#function), \(#line)")
            return
        }
        
        present(viewController, animated: true, completion: nil)
    }
}
