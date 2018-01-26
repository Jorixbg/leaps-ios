//
//  ChatDateTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 2/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ChatDateTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(data: MessangerDate) {
        if Calendar.current.isDateInToday(data.date) {
            dateLabel.text = "Today"
        }
        else if Calendar.current.isDateInYesterday(data.date) {
            dateLabel.text = "Yesterday"
        }
        else {
            dateLabel.text = DateManager.shared.createEventStandardCellDateFormatter.string(from: data.date)
        }
    }
}
