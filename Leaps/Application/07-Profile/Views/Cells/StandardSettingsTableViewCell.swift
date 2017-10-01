//
//  StandardSettingsTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class StandardSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var type: ProfileRowType? {
        didSet {
            guard let type = type else {
                return
            }
            
            titleLabel.text = type.titleForType
        }
    }
    
    
    //used for user details preview
    func setupWithText(text: String) {
        titleLabel.text = text
        selectionStyle = .none
    }
}
