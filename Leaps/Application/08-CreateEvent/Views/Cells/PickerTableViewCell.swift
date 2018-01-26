//
//  PickerTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 14/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker:UIDatePicker!
    @IBOutlet weak var customPicker:UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        datePicker.datePickerMode = .dateAndTime
    }

    func setup(type: CreateEventRowType) {
        switch type {
        default:
            datePicker.isHidden = true
            customPicker.isHidden = false
        }
    }
    
}
