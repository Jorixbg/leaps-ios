//
//  EventDateTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 17/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class EventDateTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var switcher: UISwitch!
    
    var viewModel: CreateEventStepViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switcher.addTarget(self, action: #selector(switched), for: .valueChanged)
    }
    
    @objc func switched() {
        viewModel?.repeating.value = switcher.isOn
    }

    func setup(type: CreateEventRowType) {
        titleLabel.text = type.titleForRow()
        switch type {
        case .repeat(let repeating):
            switcher.isHidden = false
            infoLabel.isHidden = true
            arrow.isHidden = true
            switcher.isOn = repeating
            break
        case .frequency(let frequency):
            switcher.isHidden = true
            infoLabel.isHidden = false
            arrow.isHidden = false
            infoLabel.text = frequency.rawValue
            break
        case .activity(let activity):
            switcher.isHidden = true
            infoLabel.isHidden = true
            arrow.isHidden = false
            titleLabel.text = activity.title()
            break
        default:
            switcher.isHidden = true
        }
    }
    
}
