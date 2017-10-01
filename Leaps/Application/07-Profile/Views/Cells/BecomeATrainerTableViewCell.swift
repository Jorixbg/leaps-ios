//
//  BecomeATrainerTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class BecomeATrainerTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    var onButtonPressed: (() -> Void)?
    
    func configure(buttonTitle: String, infoLabelText: String, onButtonPressed: (() -> Void)? = nil) {
        button.setTitle(buttonTitle, for: .normal)
        infoLabel.text = infoLabelText
        self.onButtonPressed = onButtonPressed
    }
    
    @IBAction func didPressButton(_ sender: Any) {
        onButtonPressed?()
    }
}
