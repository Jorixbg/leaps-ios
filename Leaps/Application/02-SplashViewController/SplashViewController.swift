//
//  SplashViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/14/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import UIKit

class SplashViewController: UIViewController {
    
    let viewModel = SplashViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.fetchTags { [weak self] (error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Loading error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                //tags werent fetched so whaat shall we do
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5, execute: { 
                if UserManager.shared.hasSeenOnboarding() == false {
                    let storyboardName: String = .onboarding
                    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                    let storyboardFactory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let viewController = storyboardFactory.createOnboardingFlowViewController() else {
                        print("guard failed \(#function), \(#line)")
                        return
                    }
                    let navigationController = UINavigationController(rootViewController: viewController)
                    navigationController.navigationBar.isHidden = true
                    navigationController.automaticallyAdjustsScrollViewInsets = false
                    self?.present(navigationController, animated: false, completion: nil)
                } else {
                    self?.startMainTabBarController()
                }                
            })
        }
    }
}

extension SplashViewController: MainTabBarPresentable { }
