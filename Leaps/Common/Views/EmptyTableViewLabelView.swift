//
//  EmptyTableViewLabelView.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/7/18.
//  Copyright © 2018 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EmptyTableViewLabelView: UIView {

    @IBOutlet var messageLabel:UILabel!

    class func instanceFromNib() -> EmptyTableViewLabelView {
        return Bundle.main.loadNibNamed("EmptyTableViewLabelView", owner: self, options: nil)?.first as! EmptyTableViewLabelView
    }
}
