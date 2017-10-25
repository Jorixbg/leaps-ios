//
//  LocationsEventTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 24/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class LocationsEventTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var activeView: UIView!
    
    var viewModel: ActivityViewModel? {
        didSet {
            titleLabel.text = viewModel?.event.title.uppercased()
            if let priceFrom = viewModel?.event.priceFrom, priceFrom != 0 {
                fromLabel.text = "from BGN \(String(describing: priceFrom))"
                fromLabel.backgroundColor = .white
                fromLabel.textColor = .leapsOnboardingBlue
            } else {
                fromLabel.text = "FREE"
                fromLabel.backgroundColor = .leapsOnboardingRed
                fromLabel.textColor = .white
            }
            
            let formatter = DateManager.shared.calendarEventCellFormatter
            if let date = viewModel?.event.timeFrom,
                let address = viewModel?.event.address{
                dateLabel.text = "\(formatter.string(from: date)), \(address)"
            }
            else {
                dateLabel.text = ""
            }
            
            if let imageURLString = viewModel?.event.eventImageURL,
                let url = URL(string: "\(Constants.baseURL)\(imageURLString)") {
                
                eventImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "event-placeholder"), options: [])
            } else {
                eventImageView.image = #imageLiteral(resourceName: "event-placeholder")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        activeView.isHidden = !selected
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fromLabel.layer.cornerRadius = Constants.General.standradCornerRadius
        activeView.isHidden = true
    }
}
