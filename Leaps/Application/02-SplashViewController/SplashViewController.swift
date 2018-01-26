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
        
        fetchTags()
    }
    
    func fetchTags() {
        viewModel.fetchTags { [weak self] (error) in
            AlertManager.shared.hideAll()
            guard error == nil else {
                if let message = error?.localizedDescription, let stongSelf = self {
                    AlertManager.shared.showTryAgainMessage(message: message, block: stongSelf.fetchTags)
                }
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
