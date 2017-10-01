//
//  StepOne.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/28/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class StepViewController: UIViewController {
    typealias T = OnboardingStepViewModel
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var viewModel: OnboardingStepViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        viewModel?.type.bindAndFire({ [weak self] (type) in
            self?.titleLabel.text = type.titleForStep()
            self?.subtitleLabel.text = type.subtitleForStep()
            let image: UIImage
            switch type {
            case .first:
                image = #imageLiteral(resourceName: "BG1")
            case .second:
                image = #imageLiteral(resourceName: "BG2")
            case .third:
                image = #imageLiteral(resourceName: "BG3")
            case .fourth:
                image = #imageLiteral(resourceName: "BG3")
            case .fifth:
                image = #imageLiteral(resourceName: "BG3")
            }
            
            self?.backgroundImage.image = image
        })
    }
}

extension StepViewController: Injectable {
    func inject(_ viewModel: OnboardingStepViewModel) {
        self.viewModel = viewModel
    }
}
