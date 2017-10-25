//
//  FollowButton.swift
//  Leaps
//
//  Created by Slav Sarafski on 18/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class FollowButton: UIButton {

    override func awakeFromNib() {
        let color = UIColor(red:0.04, green:0.66, blue:0.88, alpha:1)
        
        layer.cornerRadius = 6
        layer.borderColor = color.cgColor
        layer.borderWidth = 1
        setBackgroundColor(color: color, forState: .normal)
        setBackgroundColor(color: .white, forState: .selected)
        setTitleColor(.white, for: .normal)
        setTitleColor(color, for: .selected)
        setTitle("Follow".uppercased(), for: .normal)
        setTitle("Following".uppercased(), for: .selected)
        
//        UIFont.familyNames.forEach({ familyName in
//            let fontNames = UIFont.fontNames(forFamilyName: familyName)
//            print(familyName, fontNames)
//        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch state {
        case UIControlState.selected:
            titleLabel?.font = UIFont.leapsSFFontBold(size: 11)
        default:
            titleLabel?.font = UIFont.leapsSFFontBold(size: 14)
        }
    }
}
