//
//  ReviewTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet strong var dateTopConstrain: NSLayoutConstraint?
    
    var review: Review? {
        didSet {
            guard let review = review else {
                userImageView.image = #imageLiteral(resourceName: "profile-placeholder")
                return
            }
            
            userNameLabel.text = review.userName
            cosmosView.rating = Double(review.rating)
            commentLabel.text = review.comment
            commentButton.layer.cornerRadius = Constants.General.standradCornerRadius
            
            let formatter = DateManager.shared.previewFormatter
            dateLabel.text = formatter.string(from: review.date)
            dateLabel.alpha = 0.5
            
            if let commentImageURL = review.image,
               let url = URL(string: "\(Constants.baseURL)\(commentImageURL)") {
                commentButton.sd_setImage(with: url, for: .normal)
                commentButton.isHidden = false
            }
            else {
                commentButton.isHidden = true
            }
            
            let fullUserImageURL = "\(Constants.baseURL)\(review.userImage)"
            
            userImageView.layer.cornerRadius = userImageView.frame.width/2
            guard let url = URL(string: fullUserImageURL) else {
                userImageView.image = #imageLiteral(resourceName: "profile-placeholder")
                return
            }
            userImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
        }
    }
    
}
