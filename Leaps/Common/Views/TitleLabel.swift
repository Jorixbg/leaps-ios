//
//  TitleLabel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/4/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        let oldFont = self.font
        let newFont = UIFont.leapsCervoFont(size: oldFont?.pointSize ?? 0)
        font = newFont
        textColor = .leapsOnboardingBlue
    }
}
