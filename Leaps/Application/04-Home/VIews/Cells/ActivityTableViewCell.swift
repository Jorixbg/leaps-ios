//
//  ActivityTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/14/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var tagOne: UILabel!
    @IBOutlet weak var tagTwo: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var maskImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var followAction:((_ event:Event)->Void)?
    var shareAction:((_ event:Event, _ image:UIImage?)->Void)?
    
    //TODO: extract most of the below logic to the view model 
    var viewModel: ActivityViewModel? {
        didSet {
            nameLabel.text = viewModel?.event.ownerName
            workoutName.text = viewModel?.event.title.uppercased()
            if let priceFrom = viewModel?.event.priceFrom, priceFrom != 0 {
                fromLabel.text = "from BGN \(String(describing: priceFrom))"
                fromLabel.backgroundColor = .white
                fromLabel.textColor = .leapsOnboardingBlue
            } else {
                fromLabel.text = "FREE"
                fromLabel.backgroundColor = .leapsOnboardingRed
                fromLabel.textColor = .white
            }
            
            //follow
            followButton.isSelected = viewModel?.isUserFollow ?? false

            //setting first and last as easiest way
            if let viewModel = viewModel {
                if let firstTag = viewModel.event.specialties.first {
                    tagOne.text = firstTag
                }
                if let lastTag = viewModel.event.specialties.last {
                    tagTwo.text = lastTag
                } 
            }
            
            //date
            let formatter = DateManager.shared.activityCellDateFormatter
            if let date = viewModel?.event.date {
                dateLabel.text = formatter.string(from: date)
            }
           
            if let imageURLString = viewModel?.event.eventImageURL,
                let url = URL(string: "\(Constants.baseURL)\(imageURLString)") {
                
                eventImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "event-placeholder"), options: []) { (image, error, cacheType, url) in
                    if let _ = image {
                        self.maskImageView.isHidden = false
                    } else {
                        self.maskImageView.isHidden = true
                    }
                }
            } else {
                eventImageView.image = #imageLiteral(resourceName: "event-placeholder")
                maskImageView.isHidden = false
            }
            
            if let userProfileImageURLString = viewModel?.event.ownerImageURL, let url = URL(string: "\(Constants.baseURL)\(userProfileImageURLString)") {
                profileImageView.sd_setImage(with: url,
                                             placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
            } else {
                profileImageView.image = #imageLiteral(resourceName: "profile-placeholder")
            }
            
            locationImageView.image = viewModel?.distanceFromCurrentLocation == nil ? nil : #imageLiteral(resourceName: "feed-location")
            distanceLabel.text = viewModel?.distanceFromCurrentLocation
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        fromLabel.layer.cornerRadius = 6
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
    }
    
    @IBAction func didPressShareButton(_ sender: Any) {
        if let event = viewModel?.event {
            shareAction?(event, eventImageView?.image)
        }
    }
    
    @IBAction func didPressFollowButton(_ sender: Any) {
        if let event = viewModel?.event {
            followAction?(event)
        }
    }
}
