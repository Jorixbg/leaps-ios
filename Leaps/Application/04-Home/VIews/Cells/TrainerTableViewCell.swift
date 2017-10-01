//
//  TrainerTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/22/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class TrainerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var specialitiesLabel: UILabel!
    @IBOutlet weak var openEventsCountLabel: UILabel!
    
    @IBOutlet weak var finishedEventsCountLabel: UILabel!
    
    var viewModel: TrainerViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            nameLabel.text = viewModel.trainerFullName
            specialitiesLabel.text = viewModel.tags
            openEventsCountLabel.text = String(viewModel.hostingUpcoming.value.count)
            finishedEventsCountLabel.text = "• \(String(viewModel.hostingPast.value.count))"
            let imageURLString = viewModel.trainerImageURLString
            
            let fullURL = "\(Constants.baseURL)\(imageURLString)"
            guard let url = URL(string: fullURL) else {
                return
            }
            
            profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }
}
