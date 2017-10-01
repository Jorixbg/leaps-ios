//
//  AttendanceTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/1/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import SDWebImage
import UIKit

class AttendanceTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageVIew: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var freeSlotsLabel: UILabel!
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var unloggedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unloggedImageView: UIImageView!
    private let overlappingStep = 5
    private var lastAddedImageIndex: Int = 0
    
    var viewModel: EventViewModel? {
        didSet {
            lastAddedImageIndex = 0
            guard let viewModel = viewModel else {
                return
            }
            categoryImageVIew.image = #imageLiteral(resourceName: "nav-profile-active")
            categoryLabel.text = "Attendance"
            freeSlotsLabel.text = viewModel.freeSlots
            numberOfPeopleLabel.text = viewModel.attendeesCount
            
            stackView.isHidden = !viewModel.loggedIn
            unloggedImageView.isHidden = viewModel.loggedIn
            
            guard viewModel.loggedIn else {
                return
            }
           
            unloggedImageViewHeightConstraint.constant = 0
            
            imageContainerView.subviews.forEach({ $0.removeFromSuperview() })
            for attendee in viewModel.attendees {
                guard let imageURLAsString = attendee.userImageURL,
                        let imageURL = URL(string: "\(Constants.baseURL)\(imageURLAsString)") else {
                    continue
                }
                lastAddedImageIndex += 1
                let nextX = CGFloat(lastAddedImageIndex)*imageContainerView.frame.height - CGFloat(lastAddedImageIndex*overlappingStep)
                let rect = CGRect(x: nextX,
                                  y: 0,
                                  width: imageContainerView.frame.height,
                                  height: imageContainerView.frame.height)
                
                let imageView = UIImageView(frame: rect)
                imageView.backgroundColor = .white
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.contentMode = .scaleAspectFill
                imageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
                
                imageContainerView.addSubview(imageView)            
            }
        }
    }
}
