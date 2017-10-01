//
//  MaxDistanseSettingViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/25/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class MaxDistanseSettingViewController: UIViewController {
    typealias T = ProfileViewModel
    
    fileprivate var viewModel: ProfileViewModel?
    
    @IBOutlet weak var slider: TrackHeightEditableSlider!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.user.bindAndFire({ [weak self] (user) in
            guard let user = user else {
                return
            }
            
            let currentDistance = user.maxDistanceSetting
            self?.slider.value = Float(currentDistance)
            self?.slider.sendActions(for: .valueChanged)
        })
        setup(navigationController: navigationController)
    }
    
    private func setup(navigationController: UINavigationController?) {
        
        //the below code should be extracted to a parent view controller if there is enough time. It is used in edit profile, create event etc.
        //show navbar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        
        //back button
        let buttonSelector = #selector(self.didPressCancel)
        let cancelNavButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: buttonSelector)
        cancelNavButton.tintColor = UIColor.leapsOnboardingBlue
        navigationItem.leftBarButtonItem  = cancelNavButton
        
        //remove bottom line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //set attributed title
        title = "SETTINGS"
        guard let font = UIFont.leapsSFFont(size: 12) else {
            return
        }
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font,
                                                                        NSForegroundColorAttributeName: UIColor.leapsOnboardingBlue]
        
        //remove bottom line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //Done Button
        let doneButtonSelector = #selector(didPressDone)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: doneButtonSelector)
        doneButton.setTitleTextAttributes([NSFontAttributeName: font,
                                           NSForegroundColorAttributeName: UIColor.leapsOnboardingBlue], for: .normal)
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func didPressDone() {
        viewModel?.updateProfile() { [weak self] error in
            guard let error = error else {
                self?.navigationController?.popViewController(animated: true)
                return
            }
            
            print("settings error = \(error)")
        }
    }
    
    func didPressCancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didChangeSliderValue(_ sender: UISlider) {
        let distanceAsInt = Int(sender.value)
        distanceLabel.text = "\(String(distanceAsInt)) km"
        viewModel?.userUpdateData?.maxDistanceSetting = distanceAsInt
    }
}

extension MaxDistanseSettingViewController: Injectable {
    func inject(_ viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
}
