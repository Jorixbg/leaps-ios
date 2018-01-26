//
//  LeapsRegistrationTextField.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/4/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class LeapsRegistrationTextField: UITextField {
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        textAlignment = .left
        backgroundColor = .leapsBabyBlue
        let color: UIColor = .leapsPlaceholderGrey
        guard  let placeholder = placeholder else {
            return
        }
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor : color])

    }
}
