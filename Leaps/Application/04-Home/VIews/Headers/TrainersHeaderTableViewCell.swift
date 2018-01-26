//
//  TrainersHeaderTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TrainersHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var rightButton: UIImageView!
    var selectedHedader: (() -> Void)?
    var numberOfTrainers: Int? 
    var type: TrainerDataType? {
        didSet {
            type.flatMap {
                switch $0 {
                case .feed:
                    rightLabel.isHidden = true
                    rightButton.isHidden = true
                    titleLabel.text = "MOST POPULAR TRAINERS"
                case .search:
                    rightLabel.isHidden = false
                    rightButton.isHidden = false
                    if let numberOfTrainers = numberOfTrainers {
                        titleLabel.text = "\(numberOfTrainers) FILTERED TRAINERS"
                    } else {
                        titleLabel.text = "FILTERED TRAINERS"
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selector = #selector(didSelectHeader)
        let tap = UITapGestureRecognizer(target: self, action: selector)
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    @objc func didSelectHeader() {
        //only do something if is search
        guard let type = type, type == .search else {
            return
        }
        
        selectedHedader?()
    }
}
