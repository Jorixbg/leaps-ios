//
//  EventCalendarTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ActivityCalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var additionalImageView: UIImageView!
    @IBOutlet weak var bottomLabel: UILabel!
    
    var viewModel: ActivityViewModel? {
        didSet {
            subtitleLabel.text = viewModel?.event.ownerName
            titleLabel.text = viewModel?.event.title.uppercased()

            bottomLabel.text = viewModel?.eventTime
            guard let imageURLString = viewModel?.event.eventImageURL,
                let url = URL(string: "\(Constants.baseURL)\(imageURLString)") else {
                    return
            }
            
            leftImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "event-placeholder"))
        }
    }
}
