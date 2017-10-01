//
//  TagCollectionViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/26/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: TagLabel!
    
    func setTag(text: String,
                color: UIColor,
                shouldEnableTap: Bool,
                selectedTextColor: UIColor = .leapsOnboardingBlue,
                isAlreadySelected: Bool,
                handleSelection: ((String, Bool) -> Void)? = nil) {
        tagLabel.text = text
        tagLabel.borderColor = color
        tagLabel.textColor = color
        tagLabel.backgroundColor = .clear
        tagLabel.cornerRadius = 2
        tagLabel.shouldEnableTap = shouldEnableTap
        tagLabel.didSelectTag = handleSelection
        tagLabel.selectedTextColor = selectedTextColor
        tagLabel.isSelected = isAlreadySelected
    }
}
