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
        
        //Set navigation controller to default look
        setupDefaultNavigationController()
        
        //Set Title
        title = "SETTINGS"
        
        guard let font = UIFont.leapsSFFont(size: 12) else {
            return
        }
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
