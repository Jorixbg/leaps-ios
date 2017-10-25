//
//  FollowerTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 26/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import SDWebImage

class FollowerTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    var followAction:(()->Void)?
    
    override func awakeFromNib() {
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        
//        followButton.layer.cornerRadius = 6
//        followButton.layer.borderColor = UIColor(red:0.04, green:0.66, blue:0.88, alpha:1).cgColor
//        followButton.layer.borderWidth = 1
//        followButton.setBackgroundColor(color: .white, forState: .normal)
//        followButton.setBackgroundColor(color: UIColor(red:0.04, green:0.66, blue:0.88, alpha:1), forState: .selected)
    }
    
    func configure(user:Attendee) {
        userNameLabel.text = user.userName
        if  let imgURL = user.userImageURL,
            let url = URL(string: "\(Constants.baseURL)\(imgURL)") {
            userImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"))
        }
        followButton.isSelected = user.followed
        
        guard let userID = UserManager.shared.userID else {
            return
        }
        followButton.isHidden = userID == String(user.userID)
    }
    
    @IBAction func didSelectFollow() {
        followAction?()
    }
    
}
