//
//  TrainerEventsHeaderTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/14/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class TrainerEventsHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftLabel: UILabel!
    
    var selectedHedader: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selector = #selector(didSelectHeader)
        let tap = UITapGestureRecognizer(target: self, action: selector)
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    func set(leftLabel text: String?) {
        leftLabel.text = text
    }
    
    func didSelectHeader() {
        selectedHedader?()
    }
}
