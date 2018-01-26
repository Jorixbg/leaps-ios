//
//  RepeatingHeaderTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 24/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class RepeatingHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var block:(()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(day: Day, addBlock: @escaping ()->Void) {
        block = addBlock
        titleLabel.text = day.rawValue
    }

    @IBAction func addDate() {
       block?()
    }
}
